import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rot_day/app.dart';
import 'package:rot_day/game/drink.dart';
import 'package:rot_day/game/level.dart';
import 'package:rot_day/game/scoring.dart';
import 'package:rot_day/services/feedback.dart';
import 'package:rot_day/services/score_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fixed day, so the daily glass never changes under the tests.
final _today = DateTime.utc(2026, 3, 14);

/// Pumps for [duration] in small steps. The pour screen draws every frame,
/// so `pumpAndSettle` would wait for ever there.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  const frame = Duration(milliseconds: 16);
  for (var left = duration; left > Duration.zero; left -= frame) {
    await tester.pump(frame);
  }
}

Future<(ScoreStore, SilentFeedback)> _freshStore() async {
  SharedPreferences.setMockInitialValues({});
  final store = await ScoreStore.load();
  return (store, SilentFeedback(store));
}

Future<void> _start(
  WidgetTester tester,
  ScoreStore store,
  SilentFeedback fb,
) async {
  // A phone-sized screen (393 x 852 points), not the 800 x 600 test default.
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RotDayApp(
      store: store,
      feedback: fb,
      locale: const Locale('vi'),
      clock: () => _today,
    ),
  );
  await tester.pumpAndSettle();
}

/// Holds the pour area until the drink reaches [until] of the glass, then
/// lets go and waits for it to settle.
Future<void> _pourThenRelease(
  WidgetTester tester, {
  Duration hold = const Duration(milliseconds: 600),
}) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(const Key('pour-area'))),
  );
  await pumpFor(tester, hold);
  await gesture.up();
  await pumpFor(tester, const Duration(seconds: 5));
}

void main() {
  testWidgets('the home screen offers all three modes', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    expect(find.text('Rót Đầy'), findsOneWidget);
    expect(find.byKey(const Key('daily')), findsOneWidget);
    expect(find.byKey(const Key('endless')), findsOneWidget);
    expect(find.byKey(const Key('practice')), findsOneWidget);
  });

  testWidgets('the daily glass is saved once poured', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('daily')));
    await pumpFor(tester, const Duration(milliseconds: 600));
    expect(find.byKey(const Key('pour-area')), findsOneWidget);

    await _pourThenRelease(tester);

    // However it went, the day is recorded and the result is shown.
    expect(find.byKey(const Key('result')), findsOneWidget);
    expect(store.daily(2999), isNull, reason: 'only today is written');
    expect(store.daily(_dayNumber), isNotNull);
    expect(store.poured, 1);
    expect(fb.calls, contains('start'));
    expect(fb.calls.any((c) => c.startsWith('result:')), isTrue);
  });

  testWidgets('the daily glass cannot be poured twice', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await ScoreStore.load();
    await store.saveDaily(_dayNumber, 2.0);
    final fb = SilentFeedback(store);
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('daily')));
    await pumpFor(tester, const Duration(milliseconds: 600));

    expect(find.byKey(const Key('earlier-result')), findsOneWidget);
    expect(find.text('Bạn đã rót ly hôm nay rồi.'), findsOneWidget);

    // Holding must not start a new pour.
    await _pourThenRelease(tester, hold: const Duration(milliseconds: 300));
    expect(find.byKey(const Key('earlier-result')), findsOneWidget);
    expect(store.daily(_dayNumber)!.errorMm, 2.0);
  });

  testWidgets('practice records nothing', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('practice')));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await _pourThenRelease(tester);

    expect(find.byKey(const Key('result')), findsOneWidget);
    expect(store.poured, 0, reason: 'practice is not counted');
    expect(store.daily(_dayNumber), isNull);
  });

  testWidgets('endless mode can be poured and offers the next glass', (
    tester,
  ) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('endless')));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await _pourThenRelease(tester);

    // Either it went well enough to carry on, or the run is over. Both are
    // valid; what matters is that one of the two shows up.
    final carryOn = find.byKey(const Key('result')).evaluate().isNotEmpty;
    final over = find.byKey(const Key('run-over')).evaluate().isNotEmpty;
    expect(carryOn || over, isTrue);
    expect(store.poured, 1);
  });

  testWidgets('how to play opens and explains the quirks', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('how-to')));
    await tester.pumpAndSettle();

    expect(find.text('Cách chơi'), findsOneWidget);
    expect(find.text('Thả tay rồi nước vẫn chảy'), findsOneWidget);
    expect(find.text('Bọt sẽ thành nước'), findsOneWidget);
  });

  testWidgets('records screen lists the medals', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.ensureVisible(find.byKey(const Key('stats')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('stats')));
    await tester.pumpAndSettle();

    expect(find.text('Thành tích'), findsOneWidget);
    expect(find.text('Huy chương'), findsOneWidget);
    // Nothing poured yet, so the empty note shows.
    expect(
      find.text('Rót một ly là thành tích hiện ra ở đây.'),
      findsOneWidget,
    );
    // None won yet. The list builds as it scrolls, so count the label
    // rather than the rows on screen.
    expect(find.text('Được 0 trên ${Medal.values.length}'), findsOneWidget);
    expect(find.text('Ly đầu tiên'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsWidgets);
  });

  testWidgets('settings switch sound and vibration off', (tester) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('settings')));
    await tester.pumpAndSettle();

    expect(store.sound, isTrue);
    await tester.tap(find.byKey(const Key('sound')));
    await tester.pumpAndSettle();
    expect(store.sound, isFalse);

    await tester.tap(find.byKey(const Key('haptics')));
    await tester.pumpAndSettle();
    expect(store.haptics, isFalse);
  });

  testWidgets('picking English changes the interface language', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await ScoreStore.load();
    final fb = SilentFeedback(store);
    // No forced locale here: the app must follow what settings say.
    await tester.pumpWidget(
      RotDayApp(store: store, feedback: fb, clock: () => _today),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lang-en')));
    await tester.pumpAndSettle();

    expect(store.language, 'en');
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('the daily glass shown is the one everyone else gets', (
    tester,
  ) async {
    final (store, fb) = await _freshStore();
    await _start(tester, store, fb);

    await tester.tap(find.byKey(const Key('daily')));
    await pumpFor(tester, const Duration(milliseconds: 300));

    // The screen must show the drink that Level.daily decides on, which
    // game_test proves is the same number on every phone.
    final expected = Level.daily(_dayNumber).drink;
    final names = {
      Drink.tea: 'Trà đá',
      Drink.coffee: 'Cà phê',
      Drink.sugarcane: 'Nước mía',
      Drink.smoothie: 'Sinh tố',
      Drink.soda: 'Nước ngọt',
      Drink.milkTea: 'Trà sữa kem',
    };
    expect(
      find.textContaining(names[expected]!, findRichText: true),
      findsOneWidget,
      reason: 'the glass of the day must be the one Level.daily picks',
    );
  });
}

/// The daily number for the fixed test day.
final _dayNumber =
    DateTime.utc(2026, 3, 14).difference(DateTime.utc(2026)).inDays + 1;
