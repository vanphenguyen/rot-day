import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../l10n/app_localizations.dart';
import '../style/game_art.dart';
import '../style/palette.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _Step(
                number: 1,
                icon: Icons.touch_app_rounded,
                colour: Palette.amberDeep,
                title: t.howToHoldTitle,
                body: t.howToHoldBody,
              ),
              _Step(
                number: 2,
                icon: Icons.water_drop_rounded,
                colour: Palette.sky,
                title: t.howToTrailTitle,
                body: t.howToTrailBody,
              ),
              _Step(
                number: 3,
                icon: Icons.bubble_chart_rounded,
                colour: Palette.teal,
                title: t.howToFoamTitle,
                body: t.howToFoamBody,
              ),
              _Step(
                number: 4,
                icon: Icons.local_drink_rounded,
                colour: const Color(0xFF7A6BD1),
                title: t.howToShapeTitle,
                body: t.howToShapeBody,
              ),
              _Step(
                number: 5,
                icon: Icons.star_rounded,
                colour: Palette.gold,
                title: t.howToScoreTitle,
                body: t.howToScoreBody,
              ),
              const SizedBox(height: 12),
              Text(t.howToDrinks, style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 14,
                children: [
                  for (final drink in Drink.values)
                    _Tile(
                      picture: DrinkGlass(drink: drink, size: 40),
                      label: t.drinkName(drink),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(t.howToShapes, style: theme.textTheme.titleLarge),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 14,
                children: [
                  for (final shape in GlassShape.values)
                    _Tile(
                      picture: DrinkGlass(drink: null, shape: shape, size: 40),
                      label: t.shapeName(shape),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.colour,
    required this.title,
    required this.body,
  });

  final int number;
  final IconData icon;
  final Color colour;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A drink or a glass shape: the picture over its name.
class _Tile extends StatelessWidget {
  const _Tile({required this.picture, required this.label});

  final Widget picture;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Palette.paper,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Palette.sand, width: 2),
      ),
      child: Column(
        children: [
          picture,
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
