import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/feedback.dart';
import 'services/score_store.dart';

class RotDayApp extends StatefulWidget {
  const RotDayApp({
    super.key,
    required this.store,
    this.locale,
    this.feedback,
    this.clock = DateTime.now,
  });

  final ScoreStore store;

  /// Forces a language (used by tests); normally the phone's is followed,
  /// unless one was picked in settings.
  final Locale? locale;

  /// Rumble and clicks. Tests pass a silent one.
  final GameFeedback? feedback;

  /// Decides which daily glass is shown (tests pass a fixed day).
  final DateTime Function() clock;

  static const seedColor = Color(0xFFF2A516);

  @override
  State<RotDayApp> createState() => _RotDayAppState();
}

class _RotDayAppState extends State<RotDayApp> {
  late GameFeedback _feedback;

  @override
  void initState() {
    super.initState();
    _feedback = widget.feedback ?? GameFeedback(widget.store);
  }

  /// The language to use: the one picked in settings, else the phone's.
  Locale? get _locale {
    if (widget.locale != null) return widget.locale;
    final chosen = widget.store.language;
    return chosen == null ? null : Locale(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The phone's first language the app has, otherwise English.
      localeListResolutionCallback: (device, supported) {
        for (final d in device ?? const <Locale>[]) {
          for (final s in supported) {
            if (s.languageCode == d.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: HomeScreen(
        store: widget.store,
        feedback: _feedback,
        clock: widget.clock,
        // Picking a language in settings has to rebuild MaterialApp.
        onSettingsChanged: () => setState(() {}),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: RotDayApp.seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
