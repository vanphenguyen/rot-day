import 'package:flutter/material.dart';

/// The game's own colours.
///
/// Picked by hand instead of letting Flutter mix a scheme from one seed
/// colour: a warm café look (cream paper, coffee ink, amber drink) that
/// matches the app icon. The game has one look on purpose, so there is no
/// dark version.
abstract final class Palette {
  /// Page background: warm paper.
  static const cream = Color(0xFFFFF5E6);

  /// Cards and panels.
  static const paper = Color(0xFFFFFFFF);

  /// Borders, dividers, quiet fills.
  static const sand = Color(0xFFF1DFC2);

  /// Main text: dark coffee.
  static const ink = Color(0xFF3B2414);

  /// Secondary text.
  static const inkSoft = Color(0xFF85654C);

  /// The drink colour of the icon; main buttons.
  static const amber = Color(0xFFF2A516);

  /// The darker edge under amber buttons, and amber text on cream.
  static const amberDeep = Color(0xFFC26A00);

  /// The dashed line to stop on.
  static const tomato = Color(0xFFE34646);

  /// Second button colour and "great".
  static const teal = Color(0xFF2E8B7F);
  static const tealDeep = Color(0xFF1F6259);

  static const mint = Color(0xFF3FA66B);
  static const sky = Color(0xFF3E8ED0);
  static const gold = Color(0xFFF5B800);

  /// Medals not yet won.
  static const locked = Color(0xFFD9CBB6);
}
