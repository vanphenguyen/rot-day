import 'package:flutter/material.dart';

import '../game/scoring.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rating.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleLarge),
            if (rating.stars > 0) ...[
              const SizedBox(width: 8),
              _Stars(filled: rating.stars),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(detail, style: theme.textTheme.bodyLarge),
        if (note case final note?) ...[
          const SizedBox(height: 2),
          Text(
            note,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: actions,
        ),
      ],
    );
  }
}

/// Three stars with [filled] of them lit.
class _Stars extends StatelessWidget {
  const _Stars({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    final colour = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 20,
            color: colour,
          ),
      ],
    );
  }
}
