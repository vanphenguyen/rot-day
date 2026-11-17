import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/scoring.dart';

/// How a daily glass went. [errorMm] is null when it spilled.
class DailyResult {
  const DailyResult(this.errorMm);

  final double? errorMm;

  bool get spilled => errorMm == null;

  Rating get rating => rate(errorMm);
}

/// Results, records and medals, saved on the phone only.
class ScoreStore {
  ScoreStore(this._prefs);

  static Future<ScoreStore> load() async =>
      ScoreStore(await SharedPreferences.getInstance());

  static const _dailyPrefix = 'daily.';
  static const _bestRunKey = 'bestRun';
  static const _bestPointsKey = 'bestPoints';
  static const _pouredKey = 'poured';
  static const _perfectKey = 'perfect';
  static const _spilledKey = 'spilledCount';
  static const _drinksKey = 'drinksPoured';
  static const _shapesKey = 'shapesPoured';
  static const _medalsKey = 'medals';
  static const _soundKey = 'sound';
  static const _hapticsKey = 'haptics';
  static const _languageKey = 'language';

  /// Stored in place of a distance when the glass spilled.
  static const _spilledMark = -1.0;

  final SharedPreferences _prefs;

  /// Picks up anything written since this object was made.
  Future<void> reload() => _prefs.reload();

  // ---- the daily glass ----

  DailyResult? daily(int number) {
    final value = _prefs.getDouble('$_dailyPrefix$number');
    if (value == null) return null;
    return DailyResult(value < 0 ? null : value);
  }

  Future<void> saveDaily(int number, double? errorMm) =>
      _prefs.setDouble('$_dailyPrefix$number', errorMm ?? _spilledMark);

  /// Days in a row up to and including [number] that were played.
  int dailyStreak(int number) {
    var streak = 0;
    for (var n = number; n > 0 && daily(n) != null; n--) {
      streak++;
    }
    return streak;
  }

  /// Stars collected from every daily glass played, 3 at most each.
  int get totalStars {
    var stars = 0;
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith(_dailyPrefix)) continue;
      final value = _prefs.getDouble(key);
      if (value != null && value >= 0) stars += rate(value).stars;
    }
    return stars;
  }

  /// How many daily glasses have been played at all.
  int get dailiesPlayed =>
      _prefs.getKeys().where((k) => k.startsWith(_dailyPrefix)).length;

  // ---- endless mode ----

  /// Most glasses filled in one run.
  int get bestRun => _prefs.getInt(_bestRunKey) ?? 0;

  /// Most points scored in one run.
  int get bestPoints => _prefs.getInt(_bestPointsKey) ?? 0;

  /// Keeps a finished run. Returns whether either record was beaten.
  Future<bool> recordRun(int glasses, int points) async {
    var beaten = false;
    if (glasses > bestRun) {
      await _prefs.setInt(_bestRunKey, glasses);
      beaten = true;
    }
    if (points > bestPoints) {
      await _prefs.setInt(_bestPointsKey, points);
      beaten = true;
    }
    return beaten;
  }

  // ---- lifetime counts ----

  int get poured => _prefs.getInt(_pouredKey) ?? 0;
  int get perfectPours => _prefs.getInt(_perfectKey) ?? 0;
  int get spills => _prefs.getInt(_spilledKey) ?? 0;

  Set<String> get drinksPoured =>
      (_prefs.getStringList(_drinksKey) ?? const []).toSet();

  Set<String> get shapesPoured =>
      (_prefs.getStringList(_shapesKey) ?? const []).toSet();

  /// Records one finished glass, whatever the mode.
  Future<void> addPour({
    required Drink drink,
    required GlassShape shape,
    required double? errorMm,
  }) async {
    await _prefs.setInt(_pouredKey, poured + 1);
    if (errorMm == null) {
      await _prefs.setInt(_spilledKey, spills + 1);
    } else if (rate(errorMm) == Rating.perfect) {
      await _prefs.setInt(_perfectKey, perfectPours + 1);
    }
    await _prefs.setStringList(_drinksKey, {...drinksPoured, drink.name}.toList());
    await _prefs.setStringList(_shapesKey, {...shapesPoured, shape.name}.toList());
  }

  // ---- medals ----

  Set<Medal> get medals {
    final names = (_prefs.getStringList(_medalsKey) ?? const []).toSet();
    return {
      for (final m in Medal.values)
        if (names.contains(m.name)) m,
    };
  }

  Future<void> _saveMedals(Set<Medal> medals) =>
      _prefs.setStringList(_medalsKey, [for (final m in medals) m.name]);

  /// Works out which medals are newly earned and keeps them.
  /// Returns only the ones won just now, so they can be announced.
  Future<Set<Medal>> awardMedals({
    int runGlasses = 0,
    int bestStreakInRun = 0,
    bool runHadSpill = true,
    int dailyStreakNow = 0,
  }) async {
    final had = medals;
    final won = <Medal>{};

    void check(Medal medal, bool earned) {
      if (earned && !had.contains(medal)) won.add(medal);
    }

    check(Medal.firstPour, poured >= 1);
    check(Medal.firstPerfect, perfectPours >= 1);
    check(Medal.threePerfect, perfectPours >= 3);
    check(Medal.fiveInARow, bestStreakInRun >= 5);
    check(Medal.tenGlasses, runGlasses >= 10);
    check(Medal.twentyGlasses, runGlasses >= 20);
    check(Medal.everyDrink, drinksPoured.length >= Drink.values.length);
    check(Medal.everyShape, shapesPoured.length >= GlassShape.values.length);
    check(Medal.weekStreak, dailyStreakNow >= 7);
    check(Medal.noSpillRun, runGlasses >= 5 && !runHadSpill);

    if (won.isNotEmpty) await _saveMedals({...had, ...won});
    return won;
  }

  // ---- settings ----

  bool get sound => _prefs.getBool(_soundKey) ?? true;

  Future<void> setSound(bool on) => _prefs.setBool(_soundKey, on);

  bool get haptics => _prefs.getBool(_hapticsKey) ?? true;

  Future<void> setHaptics(bool on) => _prefs.setBool(_hapticsKey, on);

  /// The language picked in the app; null means "same as the phone".
  String? get language => _prefs.getString(_languageKey);

  Future<void> setLanguage(String? code) => code == null
      ? _prefs.remove(_languageKey)
      : _prefs.setString(_languageKey, code);

  /// Everything in one map, for the "what is saved" note in settings.
  String debugDump() => jsonEncode({
        'poured': poured,
        'perfect': perfectPours,
        'spills': spills,
        'bestRun': bestRun,
        'bestPoints': bestPoints,
        'medals': [for (final m in medals) m.name],
      });
}
