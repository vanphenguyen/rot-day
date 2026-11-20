import 'dart:math' as math;

/// The outline of a glass: how wide it is at each height.
///
/// Shape decides how fast the liquid climbs. In a bowl the first splash
/// barely shows, then the level shoots up; in a tulip the middle fills
/// slowly and the last stretch races.
enum GlassShape {
  /// A plain tumbler: the level climbs at a steady pace.
  straight,

  /// Narrow foot, wide rim. Starts fast, ends slow.
  flared,

  /// Wide foot, narrow rim. Starts slow, ends fast.
  tapered,

  /// Bulges in the middle like a tulip.
  tulip,

  /// Pinched waist: quick, slow, quick.
  hourglass,

  /// Rounded bottom like a round bowl. The hardest to read.
  bowl;

  /// How many slices the volume table uses. More slices, finer table.
  static const _slices = 256;

  static final Map<GlassShape, _ShapeTable> _tables = {};

  /// Relative width at [height] (0 at the foot, 1 at the rim).
  double widthAt(double height) {
    final h = height.clamp(0.0, 1.0);
    return switch (this) {
      GlassShape.straight => 1,
      GlassShape.flared => 0.62 + 0.38 * h,
      GlassShape.tapered => 1 - 0.34 * h,
      GlassShape.tulip => 0.58 + 0.42 * math.sin(math.pi * h),
      GlassShape.hourglass => 1 - 0.4 * math.sin(math.pi * h),
      GlassShape.bowl => 0.42 + 0.58 * math.sqrt(h),
    };
  }

  _ShapeTable get _table => _tables[this] ??= _buildTable();

  _ShapeTable _buildTable() {
    final steps = List<double>.filled(_slices + 1, 0);
    for (var i = 1; i <= _slices; i++) {
      final low = widthAt((i - 1) / _slices);
      final high = widthAt(i / _slices);
      steps[i] = steps[i - 1] + (low + high) / 2 / _slices;
    }
    final mean = steps[_slices];
    for (var i = 0; i <= _slices; i++) {
      steps[i] /= mean;
    }
    return _ShapeTable(steps, mean);
  }

  /// Average width, which is also the whole glass seen from the side.
  double get meanWidth => _table.mean;

  /// Share of the glass that is below [height].
  double volumeBelow(double height) {
    final h = height.clamp(0.0, 1.0);
    final table = _table.filled;
    final pos = h * _slices;
    final i = pos.floor().clamp(0, _slices - 1);
    return table[i] + (table[i + 1] - table[i]) * (pos - i);
  }

  /// The height the liquid reaches when [volume] of the glass is filled.
  double heightForVolume(double volume) {
    final v = volume.clamp(0.0, 1.0);
    final table = _table.filled;
    // The table only grows, so the slice holding v can be bisected.
    var low = 0, high = _slices;
    while (high - low > 1) {
      final middle = (low + high) ~/ 2;
      if (table[middle] <= v) {
        low = middle;
      } else {
        high = middle;
      }
    }
    final span = table[high] - table[low];
    final within = span <= 0 ? 0.0 : (v - table[low]) / span;
    return (low + within) / _slices;
  }
}

class _ShapeTable {
  const _ShapeTable(this.filled, this.mean);

  /// Share of the glass filled at each slice, from 0 to 1.
  final List<double> filled;

  /// Average width of the outline.
  final double mean;
}
