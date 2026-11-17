import 'dart:math' as math;

/// The glass on screen stands for a real one this tall, so the distance
/// from the line can be shown in millimetres.
const glassHeightMm = 120.0;

/// How a finished glass is judged, from the distance to the line.
enum Rating {
  perfect('🎯', 3),
  great('🟢', 2),
  good('🟡', 1),
  miss('🔴', 0),
  spilled('💦', 0);

  const Rating(this.emoji, this.stars);

  final String emoji;

  /// 0 to 3, shown as stars on the daily glass.
  final int stars;
}

/// Distances in millimetres at which each rating starts.
const perfectWithin = 1.0;
const greatWithin = 3.0;
const goodWithin = 7.0;

/// [errorMm] is null when the glass spilled.
Rating rate(double? errorMm) {
  if (errorMm == null) return Rating.spilled;
  if (errorMm <= perfectWithin) return Rating.perfect;
  if (errorMm <= greatWithin) return Rating.great;
  if (errorMm <= goodWithin) return Rating.good;
  return Rating.miss;
}

/// How far off glass number [index] (0 first) may be in endless mode.
/// The line gets stricter with every glass, down to a floor.
double endlessTolerance(int index) => math.max(2.5, 9 - 0.45 * index);

/// Points for a glass in endless mode: closer is worth more, and a long
/// run of good pours multiplies it.
int endlessPoints(double errorMm, int streak) {
  final tightness = math.max(0, 10 - errorMm) / 10;
  final base = 10 + (90 * tightness * tightness).round();
  final bonus = 1 + math.min(streak, 10) * 0.1;
  return (base * bonus).round();
}

/// Medals a player can earn. They are kept for good once won, which gives
/// something to come back for besides the score.
enum Medal {
  firstPour('🥛'),
  firstPerfect('🎯'),
  threePerfect('💎'),
  fiveInARow('🔥'),
  tenGlasses('🏅'),
  twentyGlasses('🏆'),
  everyDrink('🍹'),
  everyShape('🥂'),
  weekStreak('📅'),
  noSpillRun('🧼');

  const Medal(this.emoji);

  final String emoji;
}
