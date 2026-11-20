import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/level.dart';
import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../services/score_store.dart';
import '../style/game_art.dart';
import '../style/palette.dart';
import '../texts.dart';

/// Records and medals.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.store, required this.clock});

  final ScoreStore store;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final won = store.medals;
    final nothingYet = store.poured == 0;

    return Scaffold(
      appBar: AppBar(title: Text(t.statsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (nothingYet)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    t.statsNothingYet,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Palette.inkSoft,
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      _Row(label: t.statsPoured, value: '${store.poured}'),
                      _Row(
                        label: t.statsPerfect,
                        value: '${store.perfectPours}',
                      ),
                      _Row(label: t.statsSpills, value: '${store.spills}'),
                      _Row(
                        label: t.statsBestRun,
                        value: t.runGlasses(store.bestRun),
                      ),
                      _Row(
                        label: t.statsBestPoints,
                        value: '${store.bestPoints}',
                      ),
                      _Row(
                        label: t.statsDailyStars,
                        value: '${store.totalStars}',
                      ),
                      _Row(
                        label: t.statsStreak,
                        value: '${store.dailyStreak(dailyNumber(clock()))}',
                      ),
                      _Row(
                        label: t.statsDrinks,
                        value:
                            '${store.drinksPoured.length}/${Drink.values.length}',
                      ),
                      _Row(
                        label: t.statsShapes,
                        value:
                            '${store.shapesPoured.length}/${GlassShape.values.length}',
                        last: true,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.medalsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Text(
                    t.medalsEarned(won.length, Medal.values.length),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Palette.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final medal in Medal.values)
                      _MedalRow(
                        medal: medal,
                        earned: won.contains(medal),
                        last: medal == Medal.values.last,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _MedalRow extends StatelessWidget {
  const _MedalRow({
    required this.medal,
    required this.earned,
    this.last = false,
  });

  final Medal medal;
  final bool earned;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Row(
            children: [
              MedalBadge(medal: medal, earned: earned, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.medalName(medal),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: earned ? Palette.ink : Palette.inkSoft,
                      ),
                    ),
                    Text(
                      t.medalHow(medal),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Palette.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              // Kept for the tests and for screen readers: a clear won/not-won mark.
              Icon(
                earned ? Icons.check_circle_rounded : Icons.lock_outline,
                color: earned ? Palette.mint : Palette.locked,
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 70, endIndent: 16),
      ],
    );
  }
}
