import 'dart:math' as math;

import 'level.dart';
import 'scoring.dart';

enum RoundOutcome { playing, finished, spilled }

/// The pour itself. Kept apart from the screen so it can be tested.
///
/// Hold to pour, once. After letting go the stream keeps falling for a
/// moment, and foam settles into a little more liquid. Both are what make
/// the game hard: you have to let go before the line, not on it.
class PourSim {
  PourSim(this.level, {int wobbleSeed = 0}) : _wobblePhase = wobbleSeed % 1000 / 1000 * 6.283;

  final Level level;

  /// How quickly the stream reaches full strength, in seconds.
  static const riseTime = 0.04;

  /// How long it takes to die away. A thick drink trails for longer.
  static const baseFallTime = 0.12;

  /// Foam is mostly air: this much of it turns into liquid.
  static const foamLiquidRatio = 0.25;

  /// Below this the foam counts as gone.
  static const foamGone = 0.004;

  /// The round ends at the latest this long after the stream stops.
  static const settleTimeout = 3.5;

  /// Fixed step, so a pour plays out the same on every phone.
  static const step = 1 / 240;

  /// Share of the glass filled with liquid.
  double volume = 0;

  /// Foam thickness above the liquid, as a share of the glass height.
  double foam = 0;

  /// Stream strength from 0 to 1.
  double stream = 0;

  bool started = false;
  bool released = false;
  RoundOutcome outcome = RoundOutcome.playing;

  /// Seconds the finger was held down, for showing how it went.
  double heldFor = 0;

  final double _wobblePhase;
  double _elapsed = 0;
  double _sinceStop = 0;
  double _carry = 0;

  double get fallTime => baseFallTime * level.drink.thickness;

  double get liquidHeight => level.heightForVolume(volume);

  /// Where the top of the drink is right now, foam included.
  double get surfaceHeight => math.min(1, liquidHeight + foam);

  /// The liquid height once the foam still sitting there has settled.
  double get finalHeight => level.heightForVolume(volume + _foamAsVolume(foam));

  /// How far the settled liquid is from the line, in millimetres.
  double get errorMm => (finalHeight - level.line).abs() * glassHeightMm;

  /// True when the pour stopped short of the line rather than past it.
  bool get short => finalHeight < level.line;

  /// Advances the pour by [dt] seconds, with the finger down or not.
  void update(double dt, {required bool holding}) {
    // A long pause (the app was in the background) must not jump the pour.
    _carry += dt.clamp(0.0, 0.1);
    while (_carry >= step && outcome == RoundOutcome.playing) {
      _carry -= step;
      _tick(holding);
    }
  }

  void _tick(bool holding) {
    _elapsed += step;
    if (holding && !released) started = true;
    if (started && !holding) released = true;
    final pouring = started && !released;
    if (pouring) heldFor += step;

    final aim = pouring ? _aimedStream() : 0.0;
    final time = pouring ? riseTime : fallTime;
    stream += (aim - stream) * (1 - math.exp(-step / time));
    if (!pouring && stream < 1e-3) stream = 0;

    final before = liquidHeight;
    volume += level.flowRate * stream * step;
    final climbed = liquidHeight - before;

    final settled = foam * (1 - math.exp(-level.drink.settleRate * step));
    foam += level.drink.foamPerHeight * climbed - settled;
    volume += _foamAsVolume(settled);

    if (volume >= 1 || liquidHeight + foam > 1) {
      outcome = RoundOutcome.spilled;
      return;
    }
    if (released && stream == 0) {
      _sinceStop += step;
      if (foam < foamGone || _sinceStop >= settleTimeout) {
        outcome = RoundOutcome.finished;
      }
    }
  }

  /// Full strength, or drifting around it on the harder glasses.
  double _aimedStream() {
    if (level.wobble <= 0) return 1;
    final drift = math.sin(_elapsed * 2.7 + _wobblePhase) * level.wobble;
    return (1 - level.wobble + drift).clamp(0.3, 1.0);
  }

  /// Liquid volume that a layer of foam [height] thick settles into.
  double _foamAsVolume(double height) =>
      foamLiquidRatio * height * level.widthAt(liquidHeight) / level.meanWidth;
}
