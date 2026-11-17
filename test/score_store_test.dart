import 'package:flutter_test/flutter_test.dart';
import 'package:rot_day/game/drink.dart';
import 'package:rot_day/game/glass_shape.dart';
import 'package:rot_day/game/scoring.dart';
import 'package:rot_day/services/score_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ScoreStore> freshStore() async {
  SharedPreferences.setMockInitialValues({});
  return ScoreStore.load();
}

void main() {
  test('a day with no result reads as not played', () async {
    final store = await freshStore();
    expect(store.daily(10), isNull);
    expect(store.dailiesPlayed, 0);
  });

  test('a spilled day is kept apart from a day with a distance', () async {
    final store = await freshStore();
    await store.saveDaily(1, null);
    await store.saveDaily(2, 0.0);

    expect(store.daily(1)!.spilled, isTrue);
    expect(store.daily(1)!.rating, Rating.spilled);
    // A distance of zero is a perfect pour, not a missing result.
    expect(store.daily(2)!.spilled, isFalse);
    expect(store.daily(2)!.rating, Rating.perfect);
  });

  test('the streak counts back from today and stops at a gap', () async {
    final store = await freshStore();
    for (final day in [10, 9, 8, 6]) {
      await store.saveDaily(day, 1.0);
    }
    expect(store.dailyStreak(10), 3);
    // Not played today: the streak is nothing, however long it was.
    expect(store.dailyStreak(11), 0);
  });

  test('stars add up across the days played', () async {
    final store = await freshStore();
    await store.saveDaily(1, 0.5); // perfect, 3
    await store.saveDaily(2, 2.0); // great, 2
    await store.saveDaily(3, 20.0); // miss, 0
    await store.saveDaily(4, null); // spilled, 0
    expect(store.totalStars, 5);
    expect(store.dailiesPlayed, 4);
  });

  test('records only move up', () async {
    final store = await freshStore();
    expect(await store.recordRun(5, 400), isTrue);
    expect(store.bestRun, 5);
    expect(store.bestPoints, 400);

    // Worse on both counts changes nothing.
    expect(await store.recordRun(3, 100), isFalse);
    expect(store.bestRun, 5);
    expect(store.bestPoints, 400);

    // Better on one count alone still counts as a record.
    expect(await store.recordRun(3, 900), isTrue);
    expect(store.bestRun, 5);
    expect(store.bestPoints, 900);
  });

  test('pours are counted by kind', () async {
    final store = await freshStore();
    await store.addPour(drink: Drink.beer, shape: GlassShape.tulip, errorMm: 0.4);
    await store.addPour(drink: Drink.beer, shape: GlassShape.bowl, errorMm: null);
    await store.addPour(drink: Drink.tea, shape: GlassShape.tulip, errorMm: 9.0);

    expect(store.poured, 3);
    expect(store.perfectPours, 1);
    expect(store.spills, 1);
    expect(store.drinksPoured, {'beer', 'tea'});
    expect(store.shapesPoured, {'tulip', 'bowl'});
  });

  group('medals', () {
    test('the first pour earns one, and only once', () async {
      final store = await freshStore();
      await store.addPour(drink: Drink.tea, shape: GlassShape.straight, errorMm: 5);

      expect(await store.awardMedals(), contains(Medal.firstPour));
      expect(store.medals, contains(Medal.firstPour));
      // Asking again must not announce it a second time.
      expect(await store.awardMedals(), isEmpty);
    });

    test('three perfect pours earn both perfect medals', () async {
      final store = await freshStore();
      for (var i = 0; i < 3; i++) {
        await store.addPour(drink: Drink.tea, shape: GlassShape.straight, errorMm: 0.2);
      }
      final won = await store.awardMedals();
      expect(won, containsAll([Medal.firstPerfect, Medal.threePerfect]));
    });

    test('a clean run of five earns the no-spill medal', () async {
      final store = await freshStore();
      expect(
        await store.awardMedals(runGlasses: 5, runHadSpill: false),
        contains(Medal.noSpillRun),
      );
    });

    test('a run with a spill does not', () async {
      final store = await freshStore();
      expect(
        await store.awardMedals(runGlasses: 9, runHadSpill: true),
        isNot(contains(Medal.noSpillRun)),
      );
    });

    test('pouring every drink and every shape earns the two collections', () async {
      final store = await freshStore();
      for (final drink in Drink.values) {
        for (final shape in GlassShape.values) {
          await store.addPour(drink: drink, shape: shape, errorMm: 4);
        }
      }
      final won = await store.awardMedals();
      expect(won, containsAll([Medal.everyDrink, Medal.everyShape]));
    });

    test('seven days running earns the week medal', () async {
      final store = await freshStore();
      expect(
        await store.awardMedals(dailyStreakNow: 7),
        contains(Medal.weekStreak),
      );
    });

    test('medals survive being read back from storage', () async {
      final store = await freshStore();
      await store.awardMedals(runGlasses: 20, bestStreakInRun: 5);
      final again = await ScoreStore.load();
      expect(again.medals, containsAll([Medal.tenGlasses, Medal.twentyGlasses]));
    });
  });

  group('settings', () {
    test('sound and vibration start on', () async {
      final store = await freshStore();
      expect(store.sound, isTrue);
      expect(store.haptics, isTrue);
    });

    test('settings are kept', () async {
      final store = await freshStore();
      await store.setSound(false);
      await store.setHaptics(false);
      await store.setLanguage('en');

      final again = await ScoreStore.load();
      expect(again.sound, isFalse);
      expect(again.haptics, isFalse);
      expect(again.language, 'en');
    });

    test('going back to the phone language clears the choice', () async {
      final store = await freshStore();
      await store.setLanguage('vi');
      expect(store.language, 'vi');
      await store.setLanguage(null);
      expect(store.language, isNull);
    });
  });
}
