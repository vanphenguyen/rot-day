import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pour Perfect'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Hold to pour. Let go on the line.'**
  String get appTagline;

  /// No description provided for @modeDaily.
  ///
  /// In en, this message translates to:
  /// **'Glass of the day'**
  String get modeDaily;

  /// No description provided for @modeDailySub.
  ///
  /// In en, this message translates to:
  /// **'One glass, same for everyone, one try'**
  String get modeDailySub;

  /// No description provided for @modeEndless.
  ///
  /// In en, this message translates to:
  /// **'Keep pouring'**
  String get modeEndless;

  /// No description provided for @modeEndlessSub.
  ///
  /// In en, this message translates to:
  /// **'Glass after glass until you miss'**
  String get modeEndlessSub;

  /// No description provided for @modePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get modePractice;

  /// No description provided for @modePracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Pour as much as you like, nothing counted'**
  String get modePracticeSub;

  /// No description provided for @dailyNumber.
  ///
  /// In en, this message translates to:
  /// **'Glass #{number}'**
  String dailyNumber(int number);

  /// No description provided for @glassNumber.
  ///
  /// In en, this message translates to:
  /// **'Glass {number}'**
  String glassNumber(int number);

  /// No description provided for @holdToPour.
  ///
  /// In en, this message translates to:
  /// **'Hold anywhere to pour'**
  String get holdToPour;

  /// No description provided for @letGoOnLine.
  ///
  /// In en, this message translates to:
  /// **'Let go on the dashed line'**
  String get letGoOnLine;

  /// No description provided for @pouring.
  ///
  /// In en, this message translates to:
  /// **'Pouring…'**
  String get pouring;

  /// No description provided for @settling.
  ///
  /// In en, this message translates to:
  /// **'Settling…'**
  String get settling;

  /// No description provided for @ratingPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get ratingPerfect;

  /// No description provided for @ratingGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get ratingGreat;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingMiss.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get ratingMiss;

  /// No description provided for @ratingSpilled.
  ///
  /// In en, this message translates to:
  /// **'Spilled!'**
  String get ratingSpilled;

  /// No description provided for @offBy.
  ///
  /// In en, this message translates to:
  /// **'Off by {mm} mm'**
  String offBy(String mm);

  /// No description provided for @offByShort.
  ///
  /// In en, this message translates to:
  /// **'{mm} mm short'**
  String offByShort(String mm);

  /// No description provided for @offByOver.
  ///
  /// In en, this message translates to:
  /// **'{mm} mm over'**
  String offByOver(String mm);

  /// No description provided for @spilledOver.
  ///
  /// In en, this message translates to:
  /// **'It went over the rim'**
  String get spilledOver;

  /// No description provided for @drinkTea.
  ///
  /// In en, this message translates to:
  /// **'Iced tea'**
  String get drinkTea;

  /// No description provided for @drinkCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get drinkCoffee;

  /// No description provided for @drinkSugarcane.
  ///
  /// In en, this message translates to:
  /// **'Sugarcane juice'**
  String get drinkSugarcane;

  /// No description provided for @drinkSmoothie.
  ///
  /// In en, this message translates to:
  /// **'Smoothie'**
  String get drinkSmoothie;

  /// No description provided for @drinkSoda.
  ///
  /// In en, this message translates to:
  /// **'Soda'**
  String get drinkSoda;

  /// No description provided for @drinkBeer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get drinkBeer;

  /// No description provided for @shapeStraight.
  ///
  /// In en, this message translates to:
  /// **'Tumbler'**
  String get shapeStraight;

  /// No description provided for @shapeFlared.
  ///
  /// In en, this message translates to:
  /// **'Flared'**
  String get shapeFlared;

  /// No description provided for @shapeTapered.
  ///
  /// In en, this message translates to:
  /// **'Tapered'**
  String get shapeTapered;

  /// No description provided for @shapeTulip.
  ///
  /// In en, this message translates to:
  /// **'Tulip'**
  String get shapeTulip;

  /// No description provided for @shapeHourglass.
  ///
  /// In en, this message translates to:
  /// **'Hourglass'**
  String get shapeHourglass;

  /// No description provided for @shapeBowl.
  ///
  /// In en, this message translates to:
  /// **'Bowl'**
  String get shapeBowl;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Pour again'**
  String get playAgain;

  /// No description provided for @nextGlass.
  ///
  /// In en, this message translates to:
  /// **'Next glass'**
  String get nextGlass;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get backHome;

  /// No description provided for @copyResult.
  ///
  /// In en, this message translates to:
  /// **'Copy result'**
  String get copyResult;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied. Paste it anywhere.'**
  String get copied;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for a new glass.'**
  String get comeBackTomorrow;

  /// No description provided for @alreadyPlayed.
  ///
  /// In en, this message translates to:
  /// **'You have already poured today\'s glass.'**
  String get alreadyPlayed;

  /// No description provided for @yourResult.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get yourResult;

  /// No description provided for @runOver.
  ///
  /// In en, this message translates to:
  /// **'Run over'**
  String get runOver;

  /// No description provided for @runGlasses.
  ///
  /// In en, this message translates to:
  /// **'{count} glasses'**
  String runGlasses(int count);

  /// No description provided for @runPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String runPoints(int points);

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New record!'**
  String get newRecord;

  /// No description provided for @streakOf.
  ///
  /// In en, this message translates to:
  /// **'{count} in a row'**
  String streakOf(int count);

  /// No description provided for @toleranceNow.
  ///
  /// In en, this message translates to:
  /// **'Within {mm} mm to go on'**
  String toleranceNow(String mm);

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get statsTitle;

  /// No description provided for @statsPoured.
  ///
  /// In en, this message translates to:
  /// **'Glasses poured'**
  String get statsPoured;

  /// No description provided for @statsPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect pours'**
  String get statsPerfect;

  /// No description provided for @statsSpills.
  ///
  /// In en, this message translates to:
  /// **'Spills'**
  String get statsSpills;

  /// No description provided for @statsBestRun.
  ///
  /// In en, this message translates to:
  /// **'Longest run'**
  String get statsBestRun;

  /// No description provided for @statsBestPoints.
  ///
  /// In en, this message translates to:
  /// **'Most points'**
  String get statsBestPoints;

  /// No description provided for @statsDailyStars.
  ///
  /// In en, this message translates to:
  /// **'Stars from daily glasses'**
  String get statsDailyStars;

  /// No description provided for @statsStreak.
  ///
  /// In en, this message translates to:
  /// **'Days in a row'**
  String get statsStreak;

  /// No description provided for @statsDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks tried'**
  String get statsDrinks;

  /// No description provided for @statsShapes.
  ///
  /// In en, this message translates to:
  /// **'Glasses tried'**
  String get statsShapes;

  /// No description provided for @statsNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Pour a glass and your records show up here.'**
  String get statsNothingYet;

  /// No description provided for @medalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Medals'**
  String get medalsTitle;

  /// No description provided for @medalsEarned.
  ///
  /// In en, this message translates to:
  /// **'{won} of {total}'**
  String medalsEarned(int won, int total);

  /// No description provided for @medalWon.
  ///
  /// In en, this message translates to:
  /// **'Medal won!'**
  String get medalWon;

  /// No description provided for @medalFirstPour.
  ///
  /// In en, this message translates to:
  /// **'First glass'**
  String get medalFirstPour;

  /// No description provided for @medalFirstPourHow.
  ///
  /// In en, this message translates to:
  /// **'Finish one glass'**
  String get medalFirstPourHow;

  /// No description provided for @medalFirstPerfect.
  ///
  /// In en, this message translates to:
  /// **'Dead on'**
  String get medalFirstPerfect;

  /// No description provided for @medalFirstPerfectHow.
  ///
  /// In en, this message translates to:
  /// **'Land within 1 mm of the line'**
  String get medalFirstPerfectHow;

  /// No description provided for @medalThreePerfect.
  ///
  /// In en, this message translates to:
  /// **'Steady hand'**
  String get medalThreePerfect;

  /// No description provided for @medalThreePerfectHow.
  ///
  /// In en, this message translates to:
  /// **'Land within 1 mm three times'**
  String get medalThreePerfectHow;

  /// No description provided for @medalFiveInARow.
  ///
  /// In en, this message translates to:
  /// **'On a roll'**
  String get medalFiveInARow;

  /// No description provided for @medalFiveInARowHow.
  ///
  /// In en, this message translates to:
  /// **'Five good pours in a row in one run'**
  String get medalFiveInARowHow;

  /// No description provided for @medalTenGlasses.
  ///
  /// In en, this message translates to:
  /// **'Ten up'**
  String get medalTenGlasses;

  /// No description provided for @medalTenGlassesHow.
  ///
  /// In en, this message translates to:
  /// **'Fill ten glasses in one run'**
  String get medalTenGlassesHow;

  /// No description provided for @medalTwentyGlasses.
  ///
  /// In en, this message translates to:
  /// **'Bartender'**
  String get medalTwentyGlasses;

  /// No description provided for @medalTwentyGlassesHow.
  ///
  /// In en, this message translates to:
  /// **'Fill twenty glasses in one run'**
  String get medalTwentyGlassesHow;

  /// No description provided for @medalEveryDrink.
  ///
  /// In en, this message translates to:
  /// **'Whole menu'**
  String get medalEveryDrink;

  /// No description provided for @medalEveryDrinkHow.
  ///
  /// In en, this message translates to:
  /// **'Pour every drink at least once'**
  String get medalEveryDrinkHow;

  /// No description provided for @medalEveryShape.
  ///
  /// In en, this message translates to:
  /// **'Whole shelf'**
  String get medalEveryShape;

  /// No description provided for @medalEveryShapeHow.
  ///
  /// In en, this message translates to:
  /// **'Pour into every shape of glass'**
  String get medalEveryShapeHow;

  /// No description provided for @medalWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Seven days'**
  String get medalWeekStreak;

  /// No description provided for @medalWeekStreakHow.
  ///
  /// In en, this message translates to:
  /// **'Play the daily glass seven days running'**
  String get medalWeekStreakHow;

  /// No description provided for @medalNoSpillRun.
  ///
  /// In en, this message translates to:
  /// **'Not a drop'**
  String get medalNoSpillRun;

  /// No description provided for @medalNoSpillRunHow.
  ///
  /// In en, this message translates to:
  /// **'Five glasses in one run without spilling'**
  String get medalNoSpillRunHow;

  /// No description provided for @howToTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToTitle;

  /// No description provided for @howToHoldTitle.
  ///
  /// In en, this message translates to:
  /// **'Hold, then let go'**
  String get howToHoldTitle;

  /// No description provided for @howToHoldBody.
  ///
  /// In en, this message translates to:
  /// **'Press anywhere and the pour starts. Lift your finger and it stops. You only get one hold per glass.'**
  String get howToHoldBody;

  /// No description provided for @howToTrailTitle.
  ///
  /// In en, this message translates to:
  /// **'The stream keeps falling'**
  String get howToTrailTitle;

  /// No description provided for @howToTrailBody.
  ///
  /// In en, this message translates to:
  /// **'What is already in the air still lands after you let go, so let go a little before the line. A thick drink trails further than a thin one.'**
  String get howToTrailBody;

  /// No description provided for @howToFoamTitle.
  ///
  /// In en, this message translates to:
  /// **'Foam turns into drink'**
  String get howToFoamTitle;

  /// No description provided for @howToFoamBody.
  ///
  /// In en, this message translates to:
  /// **'Beer and soda build a head of foam, and about a quarter of it settles into liquid. Aim lower on a foamy drink.'**
  String get howToFoamBody;

  /// No description provided for @howToShapeTitle.
  ///
  /// In en, this message translates to:
  /// **'Shape changes everything'**
  String get howToShapeTitle;

  /// No description provided for @howToShapeBody.
  ///
  /// In en, this message translates to:
  /// **'In a bowl the first splash hardly shows, then the level races. In an hourglass the middle fills fastest. Read the glass before you pour.'**
  String get howToShapeBody;

  /// No description provided for @howToScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get howToScoreTitle;

  /// No description provided for @howToScoreBody.
  ///
  /// In en, this message translates to:
  /// **'Within 1 mm is perfect, 3 mm great, 7 mm good. Going over the rim ends the glass. In Keep pouring the allowance shrinks with every glass.'**
  String get howToScoreBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsSoundSub.
  ///
  /// In en, this message translates to:
  /// **'Clicks when you pour and when a glass is done'**
  String get settingsSoundSub;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsSub.
  ///
  /// In en, this message translates to:
  /// **'A nudge while the drink is pouring'**
  String get settingsHapticsSub;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as phone'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no tracking. Everything you pour is saved on this phone only.'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @shareLine.
  ///
  /// In en, this message translates to:
  /// **'Pour Perfect #{number} {emoji}'**
  String shareLine(int number, String emoji);

  /// No description provided for @shareSpilled.
  ///
  /// In en, this message translates to:
  /// **'💦 Spilled it'**
  String get shareSpilled;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'{emoji} Off by {mm} mm'**
  String shareError(String emoji, String mm);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
