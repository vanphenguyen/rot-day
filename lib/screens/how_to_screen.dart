import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../l10n/app_localizations.dart';
import '../texts.dart';

/// How to play, and the quirks worth knowing: the stream trails, foam
/// turns into drink, and the shape of the glass changes the timing.
class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.howToTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Step(
            icon: Icons.touch_app_outlined,
            title: t.howToHoldTitle,
            body: t.howToHoldBody,
          ),
          _Step(
            icon: Icons.water_drop_outlined,
            title: t.howToTrailTitle,
            body: t.howToTrailBody,
          ),
          _Step(
            icon: Icons.bubble_chart_outlined,
            title: t.howToFoamTitle,
            body: t.howToFoamBody,
          ),
          _Step(
            icon: Icons.local_bar_outlined,
            title: t.howToShapeTitle,
            body: t.howToShapeBody,
          ),
          _Step(
            icon: Icons.emoji_events_outlined,
            title: t.howToScoreTitle,
            body: t.howToScoreBody,
          ),
          const SizedBox(height: 8),
          Text(t.statsDrinks, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final drink in Drink.values)
                Chip(
                  avatar: Text(drink.emoji),
                  label: Text(t.drinkName(drink)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(t.statsShapes, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final shape in GlassShape.values)
                Chip(label: Text(t.shapeName(shape))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
