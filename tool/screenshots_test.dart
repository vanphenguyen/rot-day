// ignore_for_file: invalid_use_of_visible_for_testing_member
// Draws the app's screens to PNG files with the real fonts, for checking the
// look without a phone and as the raw material for the App Store pictures.
// Not part of the normal test run. Run it with:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//   flutter test tool/screenshots_test.dart --update-goldens --dart-define=DEVICE=ipad
//
// The pictures land in tool/screenshots/raw/. Then run
// `python tool/make_store_shots.py` to put them in an iPhone frame.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rot_day/app.dart';
import 'package:rot_day/game/drink.dart';
import 'package:rot_day/game/glass_shape.dart';
import 'package:rot_day/game/level.dart';
import 'package:rot_day/game/pour_physics.dart';
import 'package:rot_day/game/scoring.dart';
import 'package:rot_day/screens/pour_screen.dart';
import 'package:rot_day/services/feedback.dart';
import 'package:rot_day/services/score_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _today = DateTime.utc(2026, 11, 20);

/// Which screen to draw for: 'phone' (default) or 'ipad'. Set it with
/// --dart-define=DEVICE=ipad.
const _device = String.fromEnvironment('DEVICE', defaultValue: 'phone');
const _frame = Duration(milliseconds: 16);

/// The glasses shown in the pictures: foamy milk tea in a tulip glass,
/// and a clean tea in a flared one. No wobble, so every run is the same.
const _pourGlass = Level(
  drink: Drink.milkTea,
  shape: GlassShape.tulip,
  line: 0.6,
  flowRate: 0.24,
);
const _resultGlass = Level(
  drink: Drink.smoothie,
  shape: GlassShape.flared,
  line: 0.62,
  flowRate: 0.24,
);

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File(f).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  for (var left = d; left > Duration.zero; left -= _frame) {
    await tester.pump(_frame);
  }
}

/// Frames to hold for the glass to settle closest to its line, found by
/// running the same pour, frame by frame, without the screen.
int _bestHold(Level level) {
  var best = 0;
  var bestError = double.infinity;
  for (var frames = 10; frames < 400; frames++) {
    final sim = PourSim(level);
    for (var i = 0; i < frames; i++) {
      sim.update(_frame.inMicroseconds / 1e6, holding: true);
    }
    for (var i = 0; i < 600 && sim.outcome == RoundOutcome.playing; i++) {
      sim.update(_frame.inMicroseconds / 1e6, holding: false);
    }
    if (sim.outcome != RoundOutcome.finished) continue;
    if (sim.errorMm < bestError) {
      bestError = sim.errorMm;
      best = frames;
    }
  }
  return best;
}

void main() {
  setUpAll(() async {
    await _loadFont('Nunito', [
      for (final w in [400, 600, 700, 800, 900]) 'assets/fonts/Nunito-$w.ttf',
    ]);
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _loadFont('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    ]);
  });

  /// A player who has been at it for a week: some records and medals.
  Future<ScoreStore> store({bool played = false}) async {
    SharedPreferences.setMockInitialValues({});
    final s = await ScoreStore.load();
    if (played) {
      for (var i = 0; i < 6; i++) {
        await s.addPour(
          drink: Drink.values[i],
          shape: GlassShape.values[i],
          errorMm: i == 5 ? null : 0.3 + 0.2 * i,
        );
      }
      final today = dailyNumber(_today);
      for (var d = 0; d <= 4; d++) {
        await s.saveDaily(today - d, [0.4, 0.6, 2.1, 0.8, 4.0][d]);
      }
      await s.recordRun(14, 1180);
      await s.awardMedals(
        runGlasses: 14,
        bestStreakInRun: 9,
        runHadSpill: false,
        dailyStreakNow: 4,
      );
    }
    return s;
  }

  Future<void> shoot(
    WidgetTester tester,
    String name, {
    required String lang,
    bool played = false,
    Future<void> Function()? then,
  }) async {
    final ipad = _device == 'ipad';
    if (ipad) {
      // A 13-inch iPad Pro screen: 1032 x 1376 points at 2x, which is the
      // 2064 x 2752 size App Store Connect asks for.
      tester.view.physicalSize = const Size(2064, 2752);
      tester.view.devicePixelRatio = 2;
      tester.view.padding = const FakeViewPadding(top: 24 * 2, bottom: 20 * 2);
      tester.view.viewPadding = const FakeViewPadding(
        top: 24 * 2,
        bottom: 20 * 2,
      );
    } else {
      // An iPhone 15/16 Pro screen: 393 x 852 points, with the notch and
      // home bar areas the real phone keeps clear.
      tester.view.physicalSize = const Size(1179, 2556);
      tester.view.devicePixelRatio = 3;
      tester.view.padding = const FakeViewPadding(top: 59 * 3, bottom: 34 * 3);
      tester.view.viewPadding = const FakeViewPadding(
        top: 59 * 3,
        bottom: 34 * 3,
      );
    }
    addTearDown(tester.view.reset);
    final s = await store(played: played);
    await tester.pumpWidget(
      RotDayApp(
        store: s,
        feedback: SilentFeedback(s),
        locale: Locale(lang),
        clock: () => _today,
      ),
    );
    await pumpFor(tester, const Duration(seconds: 2));
    if (then != null) await then();
    await expectLater(
      find.byType(RotDayApp),
      matchesGoldenFile(
        ipad
            ? 'screenshots/raw/ipad-$lang-$name.png'
            : 'screenshots/raw/$lang-$name.png',
      ),
    );
  }

  Future<void> openGlass(
    WidgetTester tester,
    ScoreStore? s,
    Level level,
  ) async {
    final store = s ?? await ScoreStore.load();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute(
            builder: (_) => PourScreen(
              store: store,
              feedback: SilentFeedback(store),
              mode: PourMode.practice,
              fixedLevel: level,
            ),
          ),
        );
    await pumpFor(tester, const Duration(milliseconds: 700));
  }

  for (final lang in ['vi', 'en']) {
    testWidgets(
      'home $lang',
      (tester) => shoot(tester, '1-home', lang: lang, played: true),
    );

    testWidgets(
      'pouring $lang',
      (tester) => shoot(
        tester,
        '2-pouring',
        lang: lang,
        then: () async {
          await openGlass(tester, null, _pourGlass);
          final g = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('pour-area'))),
          );
          await pumpFor(tester, const Duration(milliseconds: 1900));
          await g.up();
          await tester.pump(_frame);
        },
      ),
    );

    testWidgets(
      'result $lang',
      (tester) => shoot(
        tester,
        '3-result',
        lang: lang,
        then: () async {
          await openGlass(tester, null, _resultGlass);
          final hold = _bestHold(_resultGlass);
          final g = await tester.startGesture(
            tester.getCenter(find.byKey(const Key('pour-area'))),
          );
          for (var i = 0; i < hold; i++) {
            await tester.pump(_frame);
          }
          await g.up();
          await pumpFor(tester, const Duration(seconds: 5));
          // The picture is meant to show a perfect pour; stop if it is not.
          expect(
            find.text(lang == 'vi' ? 'Hoàn hảo' : 'Perfect'),
            findsOneWidget,
          );
        },
      ),
    );

    testWidgets(
      'stats $lang',
      (tester) => shoot(
        tester,
        '4-stats',
        lang: lang,
        played: true,
        then: () async {
          await tester.ensureVisible(find.byKey(const Key('stats')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('stats')));
          await tester.pumpAndSettle();
          // Medals first: they are what the picture is about.
          await tester.drag(find.byType(ListView), const Offset(0, -700));
          await tester.pumpAndSettle();
        },
      ),
    );

    testWidgets(
      'howto $lang',
      (tester) => shoot(
        tester,
        '5-howto',
        lang: lang,
        then: () async {
          await tester.tap(find.byKey(const Key('how-to')));
          await tester.pumpAndSettle();
          // The list cannot scroll far enough to put the drinks at the top,
          // so start at the whole scoring card instead of half a card.
          final title = find.text(lang == 'vi' ? 'Cách tính' : 'Scoring');
          await tester.scrollUntilVisible(
            title,
            300,
            scrollable: find.byType(Scrollable).last,
          );
          final card = find.ancestor(of: title, matching: find.byType(Card));
          await Scrollable.ensureVisible(tester.element(card), alignment: 0.0);
          await tester.pumpAndSettle();
        },
      ),
    );

    testWidgets(
      'settings $lang',
      (tester) => shoot(
        tester,
        '6-settings',
        lang: lang,
        then: () async {
          await tester.tap(find.byKey(const Key('settings')));
          await tester.pumpAndSettle();
        },
      ),
    );
  }

  test('ratings used in the pictures exist', () {
    expect(Rating.perfect.stars, 3);
  });
}
