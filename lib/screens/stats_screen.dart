import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/level.dart';
import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../services/score_store.dart';
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (nothingYet)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                t.statsNothingYet,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  _Row(label: t.statsPoured, value: '${store.poured}'),
                  _Row(label: t.statsPerfect, value: '${store.perfectPours}'),
                  _Row(label: t.statsSpills, value: '${store.spills}'),
                  _Row(label: t.statsBestRun, value: t.runGlasses(store.bestRun)),
                  _Row(label: t.statsBestPoints, value: '${store.bestPoints}'),
                  _Row(label: t.statsDailyStars, value: '${store.totalStars}'),
                  _Row(
                    label: t.statsStreak,
                    value: '${store.dailyStreak(dailyNumber(clock()))}',
                  ),
                  _Row(
                    label: t.statsDrinks,
                    value: '${store.drinksPoured.length}/${Drink.values.length}',
                  ),
                  _Row(
                    label: t.statsShapes,
                    value: '${store.shapesPoured.length}/${GlassShape.values.length}',
                    last: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(t.medalsTitle, style: theme.textTheme.titleMedium),
              const Spacer(),
              Text(
                t.medalsEarned(won.length, Medal.values.length),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final medal in Medal.values)
            _MedalRow(medal: medal, earned: won.contains(medal)),
        ],
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
        if (!last) const Divider(height: 1),
      ],
    );
  }
}

class _MedalRow extends StatelessWidget {
  const _MedalRow({required this.medal, required this.earned});

  final Medal medal;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Opacity(
      // Medals not yet won are dimmed but still readable, so they read as
      // something to go after rather than something hidden.
      opacity: earned ? 1 : 0.45,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Text(medal.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(t.medalName(medal)),
        subtitle: Text(t.medalHow(medal)),
        trailing: earned
            ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
            : const Icon(Icons.lock_outline),
      ),
    );
  }
}
