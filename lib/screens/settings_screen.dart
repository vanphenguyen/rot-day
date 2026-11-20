import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/score_store.dart';

/// Sound, vibration, language, and a plain note about what is saved.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.onChanged,
  });

  final ScoreStore store;

  /// Lets the app above rebuild, which is how a language change takes hold.
  final VoidCallback onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// The languages the app is translated into, by code.
  static const _languages = {'vi': 'Tiếng Việt', 'en': 'English'};

  Future<void> _set(Future<void> Function() write) async {
    await write();
    if (!mounted) return;
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = widget.store;

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              SwitchListTile(
                key: const Key('sound'),
                value: store.sound,
                onChanged: (on) => _set(() => store.setSound(on)),
                title: Text(t.settingsSound),
                subtitle: Text(t.settingsSoundSub),
                secondary: const Icon(Icons.volume_up_outlined),
              ),
              SwitchListTile(
                key: const Key('haptics'),
                value: store.haptics,
                onChanged: (on) => _set(() => store.setHaptics(on)),
                title: Text(t.settingsHaptics),
                subtitle: Text(t.settingsHapticsSub),
                secondary: const Icon(Icons.vibration),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  t.settingsLanguage,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              RadioListTile<String?>(
                key: const Key('lang-system'),
                value: null,
                groupValue: store.language,
                onChanged: (code) => _set(() => store.setLanguage(code)),
                title: Text(t.settingsLanguageSystem),
              ),
              for (final entry in _languages.entries)
                RadioListTile<String?>(
                  key: Key('lang-${entry.key}'),
                  value: entry.key,
                  groupValue: store.language,
                  onChanged: (code) => _set(() => store.setLanguage(code)),
                  title: Text(entry.value),
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(t.settingsAbout, style: theme.textTheme.titleSmall),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  t.settingsPrivacy,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  t.settingsVersion(appVersion),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kept in step with `version` in pubspec.yaml by hand. Reading it from the
/// bundle would mean another package for one line of text.
const appVersion = '1.0.0';
