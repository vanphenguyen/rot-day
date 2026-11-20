import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../game/level.dart';
import '../game/pour_physics.dart';
import '../game/prng.dart';
import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../services/feedback.dart';
import '../services/score_store.dart';
import '../style/game_art.dart';
import '../style/palette.dart';
import '../texts.dart';
import '../widgets/glass_painter.dart';
import '../widgets/medal_sheet.dart';
import '../widgets/result_card.dart';

/// Which rules a round is played under.
enum PourMode {
  /// One glass a day, the same for everyone, one attempt.
  daily,

  /// Glass after glass; a miss or a spill ends the run.
  endless,

  /// Pour as much as you like; nothing is recorded.
  practice,
}

/// The screen where the pouring happens.
class PourScreen extends StatefulWidget {
  const PourScreen({
    super.key,
    required this.store,
    required this.feedback,
    required this.mode,
    this.dailyNumber,
    this.fixedLevel,
  });

  /// Pours this glass every time instead of a random one. Only for the
  /// store screenshots, which need the same glass on every run.
  final Level? fixedLevel;

  final ScoreStore store;
  final GameFeedback feedback;
  final PourMode mode;

  /// Which daily glass this is; only used in [PourMode.daily].
  final int? dailyNumber;

  @override
  State<PourScreen> createState() => _PourScreenState();
}

class _PourScreenState extends State<PourScreen>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late PourSim _sim;
  late Prng _rng;

  Duration _lastTick = Duration.zero;
  double _time = 0;
  double _sinceRumble = 0;
  bool _holding = false;

  /// Set once the glass is done, so the result card can be shown.
  double? _errorMm;
  bool _spilled = false;
  bool _done = false;

  /// The daily result from an earlier visit, if today was already played.
  DailyResult? _earlier;

  int _glasses = 0;
  int _points = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _runHadSpill = false;
  bool _runOver = false;
  bool _beatRecord = false;

  @override
  void initState() {
    super.initState();
    if (widget.mode == PourMode.daily) {
      _earlier = widget.store.daily(widget.dailyNumber!);
    }
    // Practice and endless glasses differ every time the app runs; the
    // daily glass must not, so only this seed is left to chance.
    _rng = Prng(DateTime.now().microsecondsSinceEpoch);
    _sim = PourSim(_newLevel(), wobbleSeed: _rng.nextInt(1000));
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Level _newLevel() =>
      widget.fixedLevel ??
      switch (widget.mode) {
        PourMode.daily => Level.daily(widget.dailyNumber!),
        PourMode.endless => Level.generate(_rng, difficulty: _glasses),
        // Practice stays at the gentlest setting on purpose.
        PourMode.practice => Level.generate(_rng, difficulty: 0),
      };

  /// How close this glass has to be, in millimetres.
  double get _allowance => switch (widget.mode) {
    PourMode.endless => endlessTolerance(_glasses),
    _ => goodWithin,
  };

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (_done || _earlier != null) return;

    final wasPouring = _sim.stream > 0;
    _sim.update(dt, holding: _holding);
    _time += dt;

    // A nudge a few times a second while the drink is running, not every
    // frame: 60 buzzes a second is just noise.
    if (_sim.stream > 0.2) {
      _sinceRumble += dt;
      if (_sinceRumble >= 0.09) {
        _sinceRumble = 0;
        widget.feedback.pourTick(0.09);
      }
    }
    if (wasPouring && _sim.stream == 0 && !_sim.released) {
      widget.feedback.pourStop();
    }

    if (_sim.outcome != RoundOutcome.playing) {
      _finish();
    } else {
      setState(() {});
    }
  }

  Future<void> _finish() async {
    final spilled = _sim.outcome == RoundOutcome.spilled;
    final error = spilled ? null : _sim.errorMm;
    setState(() {
      _done = true;
      _spilled = spilled;
      _errorMm = error;
    });
    widget.feedback.result(rate(error));

    if (widget.mode == PourMode.practice) return;

    await widget.store.addPour(
      drink: _sim.level.drink,
      shape: _sim.level.shape,
      errorMm: error,
    );

    if (widget.mode == PourMode.daily) {
      await widget.store.saveDaily(widget.dailyNumber!, error);
      await _award(
        dailyStreakNow: widget.store.dailyStreak(widget.dailyNumber!),
      );
      return;
    }

    // Endless: a spill or a glass outside the allowance ends the run.
    if (spilled || error! > _allowance) {
      if (spilled) _runHadSpill = true;
      final beaten = await widget.store.recordRun(_glasses, _points);
      widget.feedback.runOver();
      if (!mounted) return;
      setState(() {
        _runOver = true;
        _beatRecord = beaten;
      });
      await _award();
      return;
    }

    setState(() {
      _glasses++;
      _streak++;
      _bestStreak = _streak > _bestStreak ? _streak : _bestStreak;
      _points += endlessPoints(error, _streak);
    });
  }

  /// Hands out any medals just earned and shows them.
  Future<void> _award({int dailyStreakNow = 0}) async {
    final won = await widget.store.awardMedals(
      runGlasses: _glasses,
      bestStreakInRun: _bestStreak,
      runHadSpill: _runHadSpill,
      dailyStreakNow: dailyStreakNow,
    );
    if (won.isEmpty || !mounted) return;
    widget.feedback.medal();
    await showMedalSheet(context, won);
  }

  void _nextGlass() {
    setState(() {
      _sim = PourSim(_newLevel(), wobbleSeed: _rng.nextInt(1000));
      _done = false;
      _errorMm = null;
      _spilled = false;
      _time = 0;
      _holding = false;
    });
  }

  void _restartRun() {
    setState(() {
      _glasses = 0;
      _points = 0;
      _streak = 0;
      _bestStreak = 0;
      _runHadSpill = false;
      _runOver = false;
      _beatRecord = false;
    });
    _nextGlass();
  }

  void _press() {
    if (_done || _holding || _sim.released) return;
    setState(() => _holding = true);
    widget.feedback.pourStart();
  }

  void _release() {
    if (!_holding) return;
    setState(() => _holding = false);
  }

  Future<void> _copyResult() async {
    final t = AppLocalizations.of(context);
    await Clipboard.setData(
      ClipboardData(
        text: t.shareText(number: widget.dailyNumber!, errorMm: _errorMm),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.copied)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final level = _sim.level;

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.mode) {
          PourMode.daily => t.dailyNumber(widget.dailyNumber!),
          PourMode.endless => t.glassNumber(_glasses + 1),
          PourMode.practice => t.modePractice,
        }),
        actions: [
          if (widget.mode == PourMode.endless)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  t.runPoints(_points),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Banner(
              level: level,
              drink: t.drinkName(level.drink),
              shape: t.shapeName(level.shape),
              note: switch (widget.mode) {
                PourMode.endless => t.toleranceNow(t.mm(_allowance)),
                _ => t.letGoOnLine,
              },
              streak: _streak >= 2 ? t.streakOf(_streak) : null,
            ),
            Expanded(
              child: GestureDetector(
                key: const Key('pour-area'),
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _press(),
                onTapUp: (_) => _release(),
                onTapCancel: _release,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GlassPainter(
                          sim: _sim,
                          time: _time,
                          glassColor: Palette.ink,
                          lineColor: Palette.tomato,
                        ),
                      ),
                    ),
                    if (!_sim.started && _earlier == null)
                      Align(
                        alignment: const Alignment(0, 0.82),
                        child: _Hint(text: t.holdToPour),
                      ),
                  ],
                ),
              ),
            ),
            _Footer(child: _footerContent(t)),
          ],
        ),
      ),
    );
  }

  Widget _footerContent(AppLocalizations t) {
    // Today's glass was already poured on an earlier visit.
    if (_earlier case final earlier?) {
      return ResultCard(
        key: const Key('earlier-result'),
        title: t.alreadyPlayed,
        rating: earlier.rating,
        detail: t.resultLine(earlier.errorMm, short: true),
        note: t.comeBackTomorrow,
        actions: [
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home_outlined),
            label: Text(t.backHome),
          ),
        ],
      );
    }

    if (_runOver) {
      return ResultCard(
        key: const Key('run-over'),
        title: t.runOver,
        rating: _spilled ? Rating.spilled : rate(_errorMm),
        detail: '${t.runGlasses(_glasses)} · ${t.runPoints(_points)}',
        note: _beatRecord
            ? t.newRecord
            : t.resultLine(_errorMm, short: _sim.short),
        actions: [
          FilledButton.icon(
            onPressed: _restartRun,
            icon: const Icon(Icons.refresh),
            label: Text(t.playAgain),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.backHome),
          ),
        ],
      );
    }

    if (_done) {
      final rating = _spilled ? Rating.spilled : rate(_errorMm);
      return ResultCard(
        key: const Key('result'),
        title: t.ratingName(rating),
        rating: rating,
        detail: t.resultLine(_errorMm, short: _sim.short),
        note: widget.mode == PourMode.daily ? t.comeBackTomorrow : null,
        actions: [
          if (widget.mode == PourMode.daily) ...[
            FilledButton.icon(
              key: const Key('copy'),
              onPressed: _copyResult,
              icon: const Icon(Icons.copy_outlined),
              label: Text(t.copyResult),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.backHome),
            ),
          ] else
            FilledButton.icon(
              key: const Key('next'),
              onPressed: _nextGlass,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                widget.mode == PourMode.endless ? t.nextGlass : t.playAgain,
              ),
            ),
        ],
      );
    }

    return Text(
      _sim.released ? t.settling : (_sim.started ? t.pouring : t.letGoOnLine),
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

/// The strip above the glass saying what is being poured into what.
class _Banner extends StatelessWidget {
  const _Banner({
    required this.level,
    required this.drink,
    required this.shape,
    required this.note,
    this.streak,
  });

  final Level level;
  final String drink;
  final String shape;
  final String note;
  final String? streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
            decoration: BoxDecoration(
              color: Palette.paper,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Palette.sand, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DrinkGlass(drink: level.drink, shape: level.shape, size: 26),
                const SizedBox(width: 8),
                // Shrinks with an ellipsis rather than overflowing with
                // large text.
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      text: drink,
                      children: [
                        TextSpan(
                          text: '  ·  $shape',
                          style: TextStyle(color: Palette.inkSoft),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  note,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Palette.inkSoft,
                  ),
                ),
              ),
              if (streak case final streak?) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2762C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        streak,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Palette.ink,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.touch_app_rounded, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps the area below the glass a steady height, so the glass does not
/// jump about when a result appears.
class _Footer extends StatelessWidget {
  const _Footer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      alignment: Alignment.center,
      child: child,
    );
  }
}
