import 'package:flutter/material.dart';

import '../game/level.dart';
import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../services/feedback.dart';
import '../services/score_store.dart';
import '../texts.dart';
import 'how_to_screen.dart';
import 'pour_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// The first screen: pick a mode, or go and read the records.
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
        title: Text(t.appName),
        actions: [
          IconButton(
            key: const Key('how-to'),
            tooltip: t.howToTitle,
            onPressed: () => _open(const HowToScreen()),
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            key: const Key('settings'),
            tooltip: t.settingsTitle,
            onPressed: () => _open(SettingsScreen(
              store: widget.store,
              onChanged: widget.onSettingsChanged,
            )),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              t.appTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              key: const Key('daily'),
              icon: Icons.today_outlined,
              title: t.modeDaily,
              subtitle: t.modeDailySub,
              trailing: done == null
                  ? Text(t.dailyNumber(today), style: theme.textTheme.labelLarge)
                  : Text(
                      '${done.rating.emoji} ${t.resultLine(done.errorMm)}',
                      style: theme.textTheme.labelLarge,
                    ),
              onTap: () => _open(PourScreen(
                store: widget.store,
                feedback: widget.feedback,
                mode: PourMode.daily,
                dailyNumber: today,
              )),
            ),
            _ModeCard(
              key: const Key('endless'),
              icon: Icons.all_inclusive,
              title: t.modeEndless,
              subtitle: t.modeEndlessSub,
              trailing: widget.store.bestRun > 0
                  ? Text(
                      '🏆 ${t.runGlasses(widget.store.bestRun)}',
                      style: theme.textTheme.labelLarge,
                    )
                  : null,
              onTap: () => _open(PourScreen(
                store: widget.store,
                feedback: widget.feedback,
                mode: PourMode.endless,
              )),
            ),
            _ModeCard(
              key: const Key('practice'),
              icon: Icons.sports_bar_outlined,
              title: t.modePractice,
              subtitle: t.modePracticeSub,
              onTap: () => _open(PourScreen(
                store: widget.store,
                feedback: widget.feedback,
                mode: PourMode.practice,
              )),
            ),
            const SizedBox(height: 8),
            _StatsStrip(
              stars: widget.store.totalStars,
              streak: streak,
              medals: widget.store.medals.length,
              total: Medal.values.length,
              onTap: () => _open(StatsScreen(store: widget.store, clock: widget.clock)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (trailing case final trailing?) ...[
                      const SizedBox(height: 6),
                      trailing,
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Tally(label: '⭐', value: '$stars'),
                    _Tally(label: '📅', value: '$streak'),
                    _Tally(label: '🏅', value: '$medals/$total'),
                  ],
                ),
              ),
              Text(t.statsTitle, style: theme.textTheme.labelLarge),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tally extends StatelessWidget {
  const _Tally({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
