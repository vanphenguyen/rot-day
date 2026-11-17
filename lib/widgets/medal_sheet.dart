import 'package:flutter/material.dart';

import '../game/scoring.dart';
import '../l10n/app_localizations.dart';
import '../texts.dart';

/// Announces medals that were just won, from the bottom of the screen.
Future<void> showMedalSheet(BuildContext context, Set<Medal> won) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => MedalSheet(won: won),
  );
}

class MedalSheet extends StatelessWidget {
  const MedalSheet({super.key, required this.won});

  final Set<Medal> won;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.medalWon, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final medal in won)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(medal.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.medalName(medal), style: theme.textTheme.titleMedium),
                          Text(
                            t.medalHow(medal),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
