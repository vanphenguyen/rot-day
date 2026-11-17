import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../game/scoring.dart';
import 'score_store.dart';

/// Rumble and clicks while pouring.
///
/// Both can be switched off in settings. Sound uses the system click
/// sounds rather than audio files, so the app ships no media and needs no
/// extra package; it still gives the ear something on every pour.
class GameFeedback {
  GameFeedback(this.store);

  final ScoreStore store;

  bool get _rumble => store.haptics;
  bool get _click => store.sound;

  /// The stream starts.
  void pourStart() {
    if (_rumble) HapticFeedback.selectionClick();
    if (_click) SystemSound.play(SystemSoundType.click);
  }

  /// The finger came off; the stream is dying away.
  void pourStop() {
    if (_rumble) HapticFeedback.lightImpact();
  }

  /// Called repeatedly while pouring, to give the pour some texture.
  /// [sinceLast] is the seconds since the last tick was asked for.
  void pourTick(double sinceLast) {
    if (!_rumble) return;
    HapticFeedback.selectionClick();
  }

  /// A glass is done.
  void result(Rating rating) {
    switch (rating) {
      case Rating.perfect:
        if (_rumble) HapticFeedback.mediumImpact();
        if (_click) SystemSound.play(SystemSoundType.alert);
      case Rating.great:
      case Rating.good:
        if (_rumble) HapticFeedback.lightImpact();
        if (_click) SystemSound.play(SystemSoundType.click);
      case Rating.miss:
        if (_rumble) HapticFeedback.mediumImpact();
      case Rating.spilled:
        if (_rumble) HapticFeedback.heavyImpact();
        if (_click) SystemSound.play(SystemSoundType.alert);
    }
  }

  /// A medal was won.
  void medal() {
    if (_rumble) HapticFeedback.heavyImpact();
    if (_click) SystemSound.play(SystemSoundType.alert);
  }

  /// A run is over.
  void runOver() {
    if (_rumble) HapticFeedback.heavyImpact();
  }
}

/// Used in tests: records what was asked for, makes no noise.
@visibleForTesting
class SilentFeedback extends GameFeedback {
  SilentFeedback(super.store);

  final List<String> calls = [];

  @override
  void pourStart() => calls.add('start');

  @override
  void pourStop() => calls.add('stop');

  @override
  void pourTick(double sinceLast) => calls.add('tick');

  @override
  void result(Rating rating) => calls.add('result:${rating.name}');

  @override
  void medal() => calls.add('medal');

  @override
  void runOver() => calls.add('runOver');
}
