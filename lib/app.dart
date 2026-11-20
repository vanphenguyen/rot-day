import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/feedback.dart';
import 'services/score_store.dart';
import 'style/palette.dart';

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
      // One look, light only: a game's colours are part of its identity.
      theme: _theme(),
      themeMode: ThemeMode.light,
      home: HomeScreen(
        store: widget.store,
        feedback: _feedback,
        clock: widget.clock,
        // Picking a language in settings has to rebuild MaterialApp.
        onSettingsChanged: () => setState(() {}),
      ),
    );
  }

  /// Hand-picked colours and the bundled Nunito font, so the app does not
  /// look like a stock Material template.
  ThemeData _theme() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: Palette.amberDeep,
      onPrimary: Colors.white,
      primaryContainer: Palette.amber,
      onPrimaryContainer: Palette.ink,
      secondary: Palette.teal,
      onSecondary: Colors.white,
      error: Palette.tomato,
      onError: Colors.white,
      surface: Palette.cream,
      onSurface: Palette.ink,
      onSurfaceVariant: Palette.inkSoft,
      surfaceContainerLowest: Palette.cream,
      surfaceContainerLow: Palette.paper,
      surfaceContainer: Palette.paper,
      surfaceContainerHigh: Palette.sand,
      surfaceContainerHighest: Palette.sand,
      outline: Palette.sand,
      outlineVariant: Palette.sand,
    );
    final base = ThemeData(colorScheme: scheme, fontFamily: 'Nunito');
    final text = base.textTheme.apply(
      bodyColor: Palette.ink,
      displayColor: Palette.ink,
    );
    return base.copyWith(
      scaffoldBackgroundColor: Palette.cream,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        bodySmall: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Palette.cream,
        foregroundColor: Palette.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Palette.ink,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Palette.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Palette.sand, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Palette.sand, thickness: 1.5),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Palette.teal : Palette.locked,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Palette.teal : Palette.inkSoft,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Palette.ink,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Palette.cream,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: Palette.locked,
      ),
    );
  }
}
