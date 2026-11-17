// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pour Perfect';

  @override
  String get appTagline => 'Hold to pour. Let go on the line.';

  @override
  String get modeDaily => 'Glass of the day';

  @override
  String get modeDailySub => 'One glass, same for everyone, one try';

  @override
  String get modeEndless => 'Keep pouring';

  @override
  String get modeEndlessSub => 'Glass after glass until you miss';

  @override
  String get modePractice => 'Practice';

  @override
  String get modePracticeSub => 'Pour as much as you like, nothing counted';

  @override
  String dailyNumber(int number) {
    return 'Glass #$number';
  }

  @override
  String glassNumber(int number) {
    return 'Glass $number';
  }

  @override
  String get holdToPour => 'Hold anywhere to pour';

  @override
  String get letGoOnLine => 'Let go on the dashed line';

  @override
  String get pouring => 'Pouring…';

  @override
  String get settling => 'Settling…';

  @override
  String get ratingPerfect => 'Perfect';

  @override
  String get ratingGreat => 'Great';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingMiss => 'Missed';

  @override
  String get ratingSpilled => 'Spilled!';

  @override
  String offBy(String mm) {
    return 'Off by $mm mm';
  }

  @override
  String offByShort(String mm) {
    return '$mm mm short';
  }

  @override
  String offByOver(String mm) {
    return '$mm mm over';
  }

  @override
  String get spilledOver => 'It went over the rim';

  @override
  String get drinkTea => 'Iced tea';

  @override
  String get drinkCoffee => 'Coffee';

  @override
  String get drinkSugarcane => 'Sugarcane juice';

  @override
  String get drinkSmoothie => 'Smoothie';

  @override
  String get drinkSoda => 'Soda';

  @override
  String get drinkBeer => 'Beer';

  @override
  String get shapeStraight => 'Tumbler';

  @override
  String get shapeFlared => 'Flared';

  @override
  String get shapeTapered => 'Tapered';

  @override
  String get shapeTulip => 'Tulip';

  @override
  String get shapeHourglass => 'Hourglass';

  @override
  String get shapeBowl => 'Bowl';

  @override
  String get playAgain => 'Pour again';

  @override
  String get nextGlass => 'Next glass';

  @override
  String get backHome => 'Home';

  @override
  String get copyResult => 'Copy result';

  @override
  String get copied => 'Copied. Paste it anywhere.';

  @override
  String get comeBackTomorrow => 'Come back tomorrow for a new glass.';

  @override
  String get alreadyPlayed => 'You have already poured today\'s glass.';

  @override
  String get yourResult => 'Your result';

  @override
  String get runOver => 'Run over';

  @override
  String runGlasses(int count) {
    return '$count glasses';
  }

  @override
  String runPoints(int points) {
    return '$points points';
  }

  @override
  String get newRecord => 'New record!';

  @override
  String streakOf(int count) {
    return '$count in a row';
  }

  @override
  String toleranceNow(String mm) {
    return 'Within $mm mm to go on';
  }

  @override
  String get statsTitle => 'Records';

  @override
  String get statsPoured => 'Glasses poured';

  @override
  String get statsPerfect => 'Perfect pours';

  @override
  String get statsSpills => 'Spills';

  @override
  String get statsBestRun => 'Longest run';

  @override
  String get statsBestPoints => 'Most points';

  @override
  String get statsDailyStars => 'Stars from daily glasses';

  @override
  String get statsStreak => 'Days in a row';

  @override
  String get statsDrinks => 'Drinks tried';

  @override
  String get statsShapes => 'Glasses tried';

  @override
  String get statsNothingYet => 'Pour a glass and your records show up here.';

  @override
  String get medalsTitle => 'Medals';

  @override
  String medalsEarned(int won, int total) {
    return '$won of $total';
  }

  @override
  String get medalWon => 'Medal won!';

  @override
  String get medalFirstPour => 'First glass';

  @override
  String get medalFirstPourHow => 'Finish one glass';

  @override
  String get medalFirstPerfect => 'Dead on';

  @override
  String get medalFirstPerfectHow => 'Land within 1 mm of the line';

  @override
  String get medalThreePerfect => 'Steady hand';

  @override
  String get medalThreePerfectHow => 'Land within 1 mm three times';

  @override
  String get medalFiveInARow => 'On a roll';

  @override
  String get medalFiveInARowHow => 'Five good pours in a row in one run';

  @override
  String get medalTenGlasses => 'Ten up';

  @override
  String get medalTenGlassesHow => 'Fill ten glasses in one run';

  @override
  String get medalTwentyGlasses => 'Bartender';

  @override
  String get medalTwentyGlassesHow => 'Fill twenty glasses in one run';

  @override
  String get medalEveryDrink => 'Whole menu';

  @override
  String get medalEveryDrinkHow => 'Pour every drink at least once';

  @override
  String get medalEveryShape => 'Whole shelf';

  @override
  String get medalEveryShapeHow => 'Pour into every shape of glass';

  @override
  String get medalWeekStreak => 'Seven days';

  @override
  String get medalWeekStreakHow => 'Play the daily glass seven days running';

  @override
  String get medalNoSpillRun => 'Not a drop';

  @override
  String get medalNoSpillRunHow => 'Five glasses in one run without spilling';

  @override
  String get howToTitle => 'How to play';

  @override
  String get howToHoldTitle => 'Hold, then let go';

  @override
  String get howToHoldBody =>
      'Press anywhere and the pour starts. Lift your finger and it stops. You only get one hold per glass.';

  @override
  String get howToTrailTitle => 'The stream keeps falling';

  @override
  String get howToTrailBody =>
      'What is already in the air still lands after you let go, so let go a little before the line. A thick drink trails further than a thin one.';

  @override
  String get howToFoamTitle => 'Foam turns into drink';

  @override
  String get howToFoamBody =>
      'Beer and soda build a head of foam, and about a quarter of it settles into liquid. Aim lower on a foamy drink.';

  @override
  String get howToShapeTitle => 'Shape changes everything';

  @override
  String get howToShapeBody =>
      'In a bowl the first splash hardly shows, then the level races. In an hourglass the middle fills fastest. Read the glass before you pour.';

  @override
  String get howToScoreTitle => 'Scoring';

  @override
  String get howToScoreBody =>
      'Within 1 mm is perfect, 3 mm great, 7 mm good. Going over the rim ends the glass. In Keep pouring the allowance shrinks with every glass.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsSoundSub =>
      'Clicks when you pour and when a glass is done';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsSub => 'A nudge while the drink is pouring';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Same as phone';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsPrivacy =>
      'No account, no ads, no tracking. Everything you pour is saved on this phone only.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String shareLine(int number, String emoji) {
    return 'Pour Perfect #$number $emoji';
  }

  @override
  String get shareSpilled => '💦 Spilled it';

  @override
  String shareError(String emoji, String mm) {
    return '$emoji Off by $mm mm';
  }
}
