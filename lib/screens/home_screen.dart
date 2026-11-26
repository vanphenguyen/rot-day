import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/level.dart';
import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../services/feedback.dart';
import '../services/score_store.dart';
import '../style/game_art.dart';
import '../style/game_button.dart';
import '../style/palette.dart';
import '../texts.dart';
import '../widgets/glass_painter.dart';
import 'how_to_screen.dart';
import 'pour_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// The first screen: a big glass, the game's name, and one button per mode.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.feedback,
    required this.clock,
    required this.onSettingsChanged,
  });

  final ScoreStore store;
  final GameFeedback feedback;

  /// Supplies "now", so tests can decide which daily glass is current.
  final DateTime Function() clock;

  /// Called when sound, vibration or the language is changed.
  final VoidCallback onSettingsChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    // Records and settings may have changed while away.
    if (!mounted) return;
    await widget.store.reload();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = dailyNumber(widget.clock());
    final done = widget.store.daily(today);
    final streak = widget.store.dailyStreak(today);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('how-to'),
          tooltip: t.howToTitle,
          onPressed: () => _open(const HowToScreen()),
          icon: const Icon(Icons.help_outline_rounded),
        ),
        actions: [
          IconButton(
            key: const Key('settings'),
            tooltip: t.settingsTitle,
            onPressed: () => _open(
              SettingsScreen(
                store: widget.store,
                onChanged: widget.onSettingsChanged,
              ),
            ),
            icon: const Icon(Icons.settings_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          // Keeps the buttons a sensible width on an iPad.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            // Not a lazy list: the screen is short, and every part must exist.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeroGlass(),
                  const SizedBox(height: 8),
                  Text(
                    t.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 38,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Palette.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GameButton(
                    key: const Key('daily'),
                    large: true,
                    icon: Icons.today_rounded,
                    label: t.modeDaily,
                    subtitle: done == null
                        ? Text('${t.dailyNumber(today)} · ${t.modeDailySub}')
                        : Row(
                            children: [
                              RatingBadge(rating: done.rating, size: 16),
                              const SizedBox(width: 6),
                              Flexible(child: Text(t.resultLine(done.errorMm))),
                            ],
                          ),
                    onPressed: () => _open(
                      PourScreen(
                        store: widget.store,
                        feedback: widget.feedback,
                        mode: PourMode.daily,
                        dailyNumber: today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GameButton(
                    key: const Key('endless'),
                    icon: Icons.all_inclusive_rounded,
                    label: t.modeEndless,
                    color: Palette.teal,
                    edge: Palette.tealDeep,
                    foreground: Colors.white,
                    subtitle: Text(
                      widget.store.bestRun > 0
                          ? '${t.statsBestRun}: ${t.runGlasses(widget.store.bestRun)}'
                          : t.modeEndlessSub,
                    ),
                    onPressed: () => _open(
                      PourScreen(
                        store: widget.store,
                        feedback: widget.feedback,
                        mode: PourMode.endless,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GameButton(
                    key: const Key('practice'),
                    icon: Icons.local_cafe_rounded,
                    label: t.modePractice,
                    color: Palette.paper,
                    edge: Palette.sand,
                    subtitle: Text(t.modePracticeSub),
                    onPressed: () => _open(
                      PourScreen(
                        store: widget.store,
                        feedback: widget.feedback,
                        mode: PourMode.practice,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _StatsStrip(
                    stars: widget.store.totalStars,
                    streak: streak,
                    medals: widget.store.medals.length,
                    total: Medal.values.length,
                    onTap: () => _open(
                      StatsScreen(store: widget.store, clock: widget.clock),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The big glass at the top. It fills to the line once when the screen
/// opens, then stays still (a looping animation would keep the phone busy
/// for nothing).
class _HeroGlass extends StatefulWidget {
  const _HeroGlass();

  @override
  State<_HeroGlass> createState() => _HeroGlassState();
}

class _HeroGlassState extends State<_HeroGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: AnimatedBuilder(
        animation: _fill,
        builder: (context, _) => CustomPaint(
          painter: _HeroPainter(Curves.easeOutCubic.transform(_fill.value)),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.progress);

  /// 0 when empty, 1 when the drink has reached the line.
  final double progress;

  static const _line = 0.62;

  @override
  void paint(Canvas canvas, Size size) {
    final level = _line * progress;
    GlassArt(
      shape: GlassShape.tulip,
      drink: Drink.milkTea,
      liquid: level,
      foam: 0.07 * progress,
      stream: progress < 0.98 ? 1 - progress * 0.6 : 0,
      line: _line,
      spout: false,
      rimAt: 0.12,
      floorAt: 0.86,
      widthScale: 0.34,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_HeroPainter old) => old.progress != progress;
}

/// The row of totals at the bottom, which opens the records screen.
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.stars,
    required this.streak,
    required this.medals,
    required this.total,
    required this.onTap,
  });

  final int stars;
  final int streak;
  final int medals;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const Key('stats'),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              _Tally(
                icon: Icons.star_rounded,
                colour: Palette.gold,
                value: '$stars',
              ),
              _Tally(
                icon: Icons.event_available_rounded,
                colour: Palette.mint,
                value: '$streak',
              ),
              _Tally(
                icon: Icons.military_tech_rounded,
                colour: Palette.amberDeep,
                value: '$medals/$total',
              ),
              // Gives way first on a narrow phone or with large text.
              Expanded(
                child: Text(
                  t.statsTitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Palette.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tally extends StatelessWidget {
  const _Tally({required this.icon, required this.colour, required this.value});

  final IconData icon;
  final Color colour;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        children: [
          Icon(icon, color: colour, size: 22),
          const SizedBox(width: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
