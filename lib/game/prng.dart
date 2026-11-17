/// A small random number generator that gives the same numbers on every
/// phone and in the browser, so everyone gets the same glass each day.
/// `dart:math`'s Random does not promise that across platforms.
class Prng {
  Prng(int seed) : _state = seed.abs() % _modulus {
    // Numbers from nearby seeds start out alike; throw the first few away.
    for (var i = 0; i < 6; i++) {
      next();
    }
  }

  static const _modulus = 4294967296; // 2^32

  int _state;

  /// A number in [0, 1).
  double next() {
    // Products stay below 2^53, so this is exact in JavaScript too.
    _state = (1664525 * _state + 1013904223) % _modulus;
    return _state / _modulus;
  }

  /// A number in [low, high).
  double range(double low, double high) => low + (high - low) * next();

  int nextInt(int max) => (next() * max).floor();

  /// One of [items], each equally likely.
  T pick<T>(List<T> items) => items[nextInt(items.length)];
}
