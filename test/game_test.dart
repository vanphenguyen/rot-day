import 'package:flutter_test/flutter_test.dart';
import 'package:rot_day/game/drink.dart';
import 'package:rot_day/game/glass_shape.dart';
import 'package:rot_day/game/level.dart';
import 'package:rot_day/game/pour_physics.dart';
import 'package:rot_day/game/prng.dart';
import 'package:rot_day/game/scoring.dart';

/// Pours into [sim] until it is done, letting go at [releaseAt] of the
/// glass. Returns how it ended.
RoundOutcome pourUntilDone(PourSim sim, {required double releaseAt}) {
  // 40 seconds at 60 frames is far longer than any glass takes.
  for (var i = 0; i < 2400; i++) {
    if (sim.outcome != RoundOutcome.playing) break;
    sim.update(1 / 60, holding: sim.liquidHeight < releaseAt);
  }
  return sim.outcome;
}

void main() {
  group('Prng', () {
    test('gives the same numbers for the same seed', () {
      final a = [for (var i = 0; i < 5; i++) Prng(42).next()];
      final b = [for (var i = 0; i < 5; i++) Prng(42).next()];
      expect(a, b);
    });

    test('stays between 0 and 1', () {
      final rng = Prng(7);
      for (var i = 0; i < 500; i++) {
        final value = rng.next();
        expect(value, greaterThanOrEqualTo(0));
        expect(value, lessThan(1));
      }
    });

    test('nearby seeds do not start out alike', () {
      final first = [for (var seed = 1; seed <= 6; seed++) Prng(seed).next()];
      // Six draws from six seeds should not all land in the same tenth.
      expect(first.map((v) => (v * 10).floor()).toSet().length, greaterThan(2));
    });
  });

  group('GlassShape', () {
    test('volume only grows with height', () {
      for (final shape in GlassShape.values) {
        var last = -1.0;
        for (var h = 0.0; h <= 1.0; h += 0.02) {
          final volume = shape.volumeBelow(h);
          expect(volume, greaterThanOrEqualTo(last), reason: '${shape.name} at $h');
          last = volume;
        }
      }
    });

    test('the whole glass is one unit of volume', () {
      for (final shape in GlassShape.values) {
        expect(shape.volumeBelow(0), closeTo(0, 1e-9));
        expect(shape.volumeBelow(1), closeTo(1, 1e-9));
      }
    });

    test('height and volume undo each other', () {
      for (final shape in GlassShape.values) {
        for (var v = 0.05; v < 1; v += 0.05) {
          final back = shape.volumeBelow(shape.heightForVolume(v));
          expect(back, closeTo(v, 0.002), reason: '${shape.name} at $v');
        }
      }
    });

    test('a bowl fills slowly at the bottom, a tapered glass quickly', () {
      // Both hold one unit, but the first tenth of the height is worth
      // much less in a bowl than in a glass that is wide at the foot.
      expect(
        GlassShape.bowl.volumeBelow(0.1),
        lessThan(GlassShape.tapered.volumeBelow(0.1)),
      );
    });
  });

  group('Level', () {
    test('the daily glass is the same every time it is asked for', () {
      for (final number in [1, 2, 57, 365, 1000]) {
        final a = Level.daily(number);
        final b = Level.daily(number);
        expect(a.drink, b.drink);
        expect(a.shape, b.shape);
        expect(a.line, b.line);
        expect(a.flowRate, b.flowRate);
      }
    });

    test('different days give different glasses', () {
      final lines = [for (var n = 1; n <= 30; n++) Level.daily(n).line];
      expect(lines.toSet().length, greaterThan(20));
    });

    test('the line is always reachable and leaves room at the rim', () {
      final rng = Prng(3);
      for (var i = 0; i < 300; i++) {
        final level = Level.generate(rng, difficulty: i % 15);
        expect(level.line, greaterThanOrEqualTo(Level.minLine));
        expect(level.line, lessThanOrEqualTo(level.drink.highestLine));
        expect(level.line, lessThan(1));
      }
    });

    test('only the gentler drinks turn up on the first glasses', () {
      final rng = Prng(11);
      for (var i = 0; i < 100; i++) {
        expect(Level.generate(rng, difficulty: 0).drink, Drink.tea);
      }
    });

    test('later glasses pour faster', () {
      final early = [for (var i = 0; i < 40; i++) Level.generate(Prng(i), difficulty: 0).flowRate];
      final late = [for (var i = 0; i < 40; i++) Level.generate(Prng(i), difficulty: 12).flowRate];
      final earlyMean = early.reduce((a, b) => a + b) / early.length;
      final lateMean = late.reduce((a, b) => a + b) / late.length;
      expect(lateMean, greaterThan(earlyMean));
    });

    test('day numbering starts on 1 January 2026', () {
      expect(dailyNumber(DateTime.utc(2026)), 1);
      expect(dailyNumber(DateTime.utc(2026, 1, 2)), 2);
      expect(dailyNumber(DateTime.utc(2026, 12, 31)), 365);
      // The time of day must not matter.
      expect(dailyNumber(DateTime.utc(2026, 3, 5, 23, 59)),
          dailyNumber(DateTime.utc(2026, 3, 5, 0, 1)));
    });
  });

  group('PourSim', () {
    Level plain({double line = 0.6, Drink drink = Drink.tea}) => Level(
          drink: drink,
          shape: GlassShape.straight,
          line: line,
          flowRate: 0.3,
        );

    test('nothing happens until the finger goes down', () {
      final sim = PourSim(plain());
      for (var i = 0; i < 60; i++) {
        sim.update(1 / 60, holding: false);
      }
      expect(sim.started, isFalse);
      expect(sim.volume, 0);
      expect(sim.outcome, RoundOutcome.playing);
    });

    test('letting go exactly on the line overshoots, because the stream trails', () {
      final sim = PourSim(plain());
      expect(pourUntilDone(sim, releaseAt: 0.6), RoundOutcome.finished);
      // This is the whole game: aiming at the line is already too late.
      expect(sim.finalHeight, greaterThan(0.6));
    });

    test('letting go early enough lands on the line', () {
      // There is some moment to let go that lands inside a millimetre.
      // Rather than pin the exact value, which would break on every
      // tweak to the physics, look for it the way a player would.
      var best = double.infinity;
      for (var release = 0.6; release > 0.3; release -= 0.001) {
        final sim = PourSim(plain());
        if (pourUntilDone(sim, releaseAt: release) == RoundOutcome.finished) {
          best = sim.errorMm < best ? sim.errorMm : best;
        }
      }
      expect(best, lessThan(perfectWithin));
    });

    test('holding on spills the glass', () {
      final sim = PourSim(plain());
      expect(pourUntilDone(sim, releaseAt: 2), RoundOutcome.spilled);
      expect(rate(null), Rating.spilled);
    });

    test('pouring a second time is not possible', () {
      final sim = PourSim(plain());
      for (var i = 0; i < 60; i++) {
        sim.update(1 / 60, holding: true);
      }
      // Let go, and wait for the stream to stop completely.
      for (var i = 0; i < 240 && sim.stream > 0; i++) {
        sim.update(1 / 60, holding: false);
      }
      expect(sim.stream, 0);
      final after = sim.volume;
      // Holding again must add nothing.
      for (var i = 0; i < 120; i++) {
        sim.update(1 / 60, holding: true);
      }
      expect(sim.volume, closeTo(after, 1e-9));
    });

    test('a long pause does not jump the pour', () {
      final steady = PourSim(plain());
      final jumpy = PourSim(plain());
      for (var i = 0; i < 30; i++) {
        steady.update(1 / 60, holding: true);
      }
      // The app was in the background for a second; at most 0.1 s counts.
      jumpy.update(1.0, holding: true);
      expect(jumpy.volume, lessThan(steady.volume));
    });

    test('a pour plays out the same whatever the frame rate', () {
      final smooth = PourSim(plain());
      final choppy = PourSim(plain());
      for (var i = 0; i < 120; i++) {
        smooth.update(1 / 120, holding: smooth.liquidHeight < 0.55);
      }
      for (var i = 0; i < 60; i++) {
        choppy.update(1 / 60, holding: choppy.liquidHeight < 0.55);
      }
      expect(choppy.volume, closeTo(smooth.volume, 0.01));
    });

    group('foam', () {
      test('iced tea makes none', () {
        final sim = PourSim(plain());
        pourUntilDone(sim, releaseAt: 0.5);
        expect(sim.foam, 0);
      });

      test('beer builds a head while pouring', () {
        final sim = PourSim(plain(drink: Drink.beer, line: 0.55));
        for (var i = 0; i < 60; i++) {
          sim.update(1 / 60, holding: true);
        }
        expect(sim.foam, greaterThan(0.02));
      });

      test('settled foam leaves more drink than was poured', () {
        final sim = PourSim(plain(drink: Drink.beer, line: 0.55));
        pourUntilDone(sim, releaseAt: 0.4);
        // The glass settles higher than the liquid stood at the time.
        expect(sim.finalHeight, greaterThan(0.4));
        expect(sim.outcome, RoundOutcome.finished);
      });

      test('a foamy drink has to be let go of earlier than a clear one', () {
        double landedAt(Drink drink) {
          final sim = PourSim(plain(drink: drink, line: 0.55));
          pourUntilDone(sim, releaseAt: 0.5);
          return sim.finalHeight;
        }

        expect(landedAt(Drink.beer), greaterThan(landedAt(Drink.tea)));
      });
    });

    test('a thick drink trails further than a thin one', () {
      double landedAt(Drink drink) {
        final sim = PourSim(plain(drink: drink, line: 0.7));
        pourUntilDone(sim, releaseAt: 0.5);
        return sim.finalHeight;
      }

      // Both make foam, but the smoothie keeps falling for longer.
      expect(landedAt(Drink.smoothie), greaterThan(landedAt(Drink.soda)));
    });

    test('the wobble on later glasses keeps the stream within bounds', () {
      final level = Level(
        drink: Drink.tea,
        shape: GlassShape.straight,
        line: 0.6,
        flowRate: 0.3,
        wobble: 0.18,
      );
      final sim = PourSim(level, wobbleSeed: 500);
      for (var i = 0; i < 120; i++) {
        sim.update(1 / 60, holding: true);
        expect(sim.stream, greaterThanOrEqualTo(0));
        expect(sim.stream, lessThanOrEqualTo(1));
      }
    });

    test('every drink in every glass can be filled to the line', () {
      // Nothing must be impossible: for each pairing there is a moment to
      // let go that lands inside "good".
      for (final drink in Drink.values) {
        for (final shape in GlassShape.values) {
          final line = drink.highestLine - 0.05;
          var best = double.infinity;
          for (var release = line; release > 0.1; release -= 0.005) {
            final sim = PourSim(Level(
              drink: drink,
              shape: shape,
              line: line,
              flowRate: Level.minFlowRate,
            ));
            if (pourUntilDone(sim, releaseAt: release) == RoundOutcome.finished) {
              best = sim.errorMm < best ? sim.errorMm : best;
            }
          }
          expect(best, lessThan(goodWithin),
              reason: '${drink.name} in ${shape.name}');
        }
      }
    });
  });

  group('scoring', () {
    test('ratings follow the distance', () {
      expect(rate(0), Rating.perfect);
      expect(rate(perfectWithin), Rating.perfect);
      expect(rate(perfectWithin + 0.01), Rating.great);
      expect(rate(greatWithin), Rating.great);
      expect(rate(greatWithin + 0.01), Rating.good);
      expect(rate(goodWithin), Rating.good);
      expect(rate(goodWithin + 0.01), Rating.miss);
      expect(rate(null), Rating.spilled);
    });

    test('stars go from 3 down to 0', () {
      expect(Rating.perfect.stars, 3);
      expect(Rating.great.stars, 2);
      expect(Rating.good.stars, 1);
      expect(Rating.miss.stars, 0);
      expect(Rating.spilled.stars, 0);
    });

    test('the allowance tightens then stops', () {
      expect(endlessTolerance(0), 9);
      expect(endlessTolerance(5), lessThan(endlessTolerance(0)));
      expect(endlessTolerance(100), 2.5);
      // It must never go so tight that nobody could hit it.
      for (var i = 0; i < 200; i++) {
        expect(endlessTolerance(i), greaterThanOrEqualTo(2.5));
      }
    });

    test('closer is worth more, and a streak multiplies it', () {
      expect(endlessPoints(0, 1), greaterThan(endlessPoints(5, 1)));
      expect(endlessPoints(1, 5), greaterThan(endlessPoints(1, 1)));
      // The multiplier stops growing, so points cannot run away.
      expect(endlessPoints(0, 50), endlessPoints(0, 10));
    });
  });
}
