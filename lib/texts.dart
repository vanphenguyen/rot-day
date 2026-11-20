import 'package:intl/intl.dart';

import 'game/drink.dart';
import 'game/glass_shape.dart';
import 'game/scoring.dart';
import 'l10n/app_localizations.dart';

/// Turns the game's values into words. Kept apart from the screens so the
/// same wording is used everywhere and can be tested on its own.
extension GameTexts on AppLocalizations {
  /// A distance with one decimal, in the reader's own number format
  /// (1,5 in Vietnamese, 1.5 in English).
  String mm(double value) => NumberFormat('0.#', localeName).format(value);

  String drinkName(Drink drink) => switch (drink) {
    Drink.tea => drinkTea,
    Drink.coffee => drinkCoffee,
    Drink.sugarcane => drinkSugarcane,
    Drink.smoothie => drinkSmoothie,
    Drink.soda => drinkSoda,
    Drink.milkTea => drinkMilkTea,
  };

  String shapeName(GlassShape shape) => switch (shape) {
    GlassShape.straight => shapeStraight,
    GlassShape.flared => shapeFlared,
    GlassShape.tapered => shapeTapered,
    GlassShape.tulip => shapeTulip,
    GlassShape.hourglass => shapeHourglass,
    GlassShape.bowl => shapeBowl,
  };

  String ratingName(Rating rating) => switch (rating) {
    Rating.perfect => ratingPerfect,
    Rating.great => ratingGreat,
    Rating.good => ratingGood,
    Rating.miss => ratingMiss,
    Rating.spilled => ratingSpilled,
  };

  String medalName(Medal medal) => switch (medal) {
    Medal.firstPour => medalFirstPour,
    Medal.firstPerfect => medalFirstPerfect,
    Medal.threePerfect => medalThreePerfect,
    Medal.fiveInARow => medalFiveInARow,
    Medal.tenGlasses => medalTenGlasses,
    Medal.twentyGlasses => medalTwentyGlasses,
    Medal.everyDrink => medalEveryDrink,
    Medal.everyShape => medalEveryShape,
    Medal.weekStreak => medalWeekStreak,
    Medal.noSpillRun => medalNoSpillRun,
  };

  String medalHow(Medal medal) => switch (medal) {
    Medal.firstPour => medalFirstPourHow,
    Medal.firstPerfect => medalFirstPerfectHow,
    Medal.threePerfect => medalThreePerfectHow,
    Medal.fiveInARow => medalFiveInARowHow,
    Medal.tenGlasses => medalTenGlassesHow,
    Medal.twentyGlasses => medalTwentyGlassesHow,
    Medal.everyDrink => medalEveryDrinkHow,
    Medal.everyShape => medalEveryShapeHow,
    Medal.weekStreak => medalWeekStreakHow,
    Medal.noSpillRun => medalNoSpillRunHow,
  };

  /// How a glass went, in one line. [short] tells whether the pour stopped
  /// below the line or went past it.
  String resultLine(double? errorMm, {bool short = true}) {
    if (errorMm == null) return spilledOver;
    final text = mm(errorMm);
    if (errorMm <= perfectWithin) return offBy(text);
    return short ? offByShort(text) : offByOver(text);
  }

  /// The text the share button puts on the clipboard.
  String shareText({required int number, required double? errorMm}) {
    final rating = rate(errorMm);
    final first = shareLine(number, rating.emoji);
    final second = errorMm == null
        ? shareSpilled
        : shareError(rating.emoji, mm(errorMm));
    return '$first\n$second';
  }
}
