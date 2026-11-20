import 'package:flutter/material.dart';

import '../game/scoring.dart';
import '../style/game_art.dart';
import '../style/palette.dart';

/// The panel below the glass once a pour is finished: how it went, by how
/// much, and what to do next.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    required this.rating,
    required this.detail,
    required this.actions,
    this.note,
  });

  /// The verdict in words, such as "Perfect".
  final String title;

  final Rating rating;

  /// How far off it was, in words.
  final String detail;

  /// An extra line, such as "come back tomorrow".
  final String? note;

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Palette.paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Palette.sand, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RatingBadge(rating: rating, size: 30),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    // Gold text is hard to read on white, so "perfect" uses deep amber.
                    color: switch (rating) {
                      Rating.perfect => Palette.amberDeep,
                      Rating.miss => Palette.ink,
                      _ => rating.color,
                    },
                  ),
                ),
              ),
              if (rating.stars > 0) ...[
                const SizedBox(width: 10),
                StarRow(filled: rating.stars, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (note case final note?) ...[
            const SizedBox(height: 2),
            Text(
              note,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Palette.inkSoft,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
