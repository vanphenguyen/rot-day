import 'dart:math' as math;

import 'drink.dart';
import 'glass_shape.dart';
import 'prng.dart';

/// One glass to fill.
///
/// Heights are fractions of the glass height (0 at the foot, 1 at the rim).
class Level {
  const Level({
    required this.drink,
    required this.shape,
    required this.line,
    required this.flowRate,
    this.wobble = 0,
  });

  /// A random glass. Higher [difficulty] pours faster, offers more drinks
  /// and eventually makes the stream waver.
  factory Level.generate(Prng rng, {int difficulty = 0}) {
    final drink = rng.pick(Drink.unlockedAfter(difficulty));
    final shape = rng.pick(GlassShape.values);
    final line = rng.range(minLine, drink.highestLine);
    // The pour gets quicker for the first 12 glasses, then holds.
    final speedUp = 1 + 0.045 * math.min(difficulty, 12);
    final flow = rng.range(minFlowRate, maxBaseFlowRate) * speedUp;
    // From the 7th glass the stream starts to waver.
    final wobble = difficulty < 6 ? 0.0 : math.min(0.18, 0.03 * (difficulty - 5));
    return Level(
      drink: drink,
      shape: shape,
      line: line,
      flowRate: flow,
      wobble: wobble,
    );
  }

  /// The glass of the day with this [number]; the same on every phone.
  factory Level.daily(int number) {
    final rng = Prng(number * 2654435761);
    // Early days stay gentle so a first-time player can finish one.
    final difficulty = math.min(10, number % 13);
    return Level.generate(rng, difficulty: difficulty);
  }

  static const minLine = 0.42;
  static const minFlowRate = 0.2;
  static const maxBaseFlowRate = 0.32;

  final Drink drink;
  final GlassShape shape;

  /// Where the line is, as a share of the glass height.
  final double line;

  /// Share of the glass filled per second at full stream.
  final double flowRate;

  /// How much the stream strength drifts on its own, 0 for not at all.
  final double wobble;

  double widthAt(double height) => shape.widthAt(height);

  double get meanWidth => shape.meanWidth;

  double volumeBelow(double height) => shape.volumeBelow(height);

  double heightForVolume(double volume) => shape.heightForVolume(volume);

  /// Roughly how long a perfect pour takes, for showing a hint.
  double get secondsToLine => volumeBelow(line) / flowRate;
}

/// The number of the daily glass for [now]: #1 is 1 January 2026.
int dailyNumber(DateTime now) =>
    DateTime.utc(now.year, now.month, now.day).difference(DateTime.utc(2026)).inDays + 1;
