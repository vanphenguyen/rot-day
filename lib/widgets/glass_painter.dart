import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/level.dart';
import '../game/pour_physics.dart';

/// Draws the pour: the glass, the drink in it, the foam, the falling stream
/// and the line to aim for.
class GlassPainter extends CustomPainter {
  GlassPainter({required this.sim, required this.lineColor, this.time = 0});

  final PourSim sim;

  /// Colour of the line to aim for.
  final Color lineColor;

  /// Seconds since the round began, for the ripples and the stream.
  final double time;

  Level get level => sim.level;

  @override
  void paint(Canvas canvas, Size size) {
    GlassArt(
      shape: level.shape,
      drink: level.drink,
      liquid: sim.liquidHeight,
      foam: sim.foam,
      stream: sim.stream,
      line: level.line,
      lineColor: lineColor,
      time: time,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.sim != sim || old.time != time || old.lineColor != lineColor;
}

/// A glass of drink drawn the way it looks on a table: clear walls with
/// some thickness, a solid glass foot, the rim and the drink's surface seen
/// as ovals from a little above, and light catching the left side.
///
/// Everything is worked out from the glass outline, so a new glass shape
/// needs no change here.
class GlassArt {
  const GlassArt({
    required this.shape,
    this.drink,
    this.liquid = 0,
    this.foam = 0,
    this.stream = 0,
    this.line,
    this.lineColor = const Color(0xFFE34646),
    this.time = 0,
    this.spout = true,
    this.rimAt = 0.16,
    this.floorAt = 0.84,
    this.widthScale = 0.27,
  });

  final GlassShape shape;
  final Drink? drink;

  /// Liquid height and foam thickness, as shares of the glass height.
  final double liquid;
  final double foam;

  /// Stream strength from 0 to 1.
  final double stream;

  /// Where the line to aim for is, or null for no line.
  final double? line;
  final Color lineColor;
  final double time;

  /// Whether to draw the jug spout the stream comes out of.
  final bool spout;

  /// Where the rim and the inside floor sit, as shares of the canvas height,
  /// and how wide the glass is for its height.
  final double rimAt;
  final double floorAt;
  final double widthScale;

  double get _surface => math.min(1, liquid + foam);

  void paint(Canvas canvas, Size size) {
    final g = _Geo(shape, size, rimAt, floorAt, widthScale);
    final inside = _inside(g);

    _shadow(canvas, g);
    _glassBody(canvas, g);
    _stream(canvas, g);

    canvas.save();
    canvas.clipPath(inside);
    _drink(canvas, g);
    canvas.restore();

    _walls(canvas, g);
    _foot(canvas, g);
    _rim(canvas, g);
    _highlights(canvas, g);
    _line(canvas, g);
  }

  // ------------------------------------------------------------- outlines

  /// The inside of the glass: up the left wall, over the back of the rim,
  /// down the right wall and round the front of the floor.
  Path _inside(_Geo g) {
    final p = Path()..moveTo(g.x(0, -1), g.y(0));
    g.side(p, -1, 0);
    p.arcTo(g.oval(1), math.pi, math.pi, false);
    g.side(p, 1, 0, down: true);
    p.arcTo(g.oval(0), 0, math.pi, false);
    return p..close();
  }

  /// The whole glass seen from outside, foot included.
  Path _outside(_Geo g) {
    final p = Path()
      ..moveTo(g.x(0, -1) - g.wall, g.footY)
      ..lineTo(g.x(0, -1) - g.wall, g.y(0));
    g.side(p, -1, g.wall);
    p.arcTo(g.oval(1, grow: g.wall), math.pi, math.pi, false);
    g.side(p, 1, g.wall, down: true);
    p
      ..lineTo(g.x(0, 1) + g.wall, g.footY)
      ..arcTo(g.footOval, 0, math.pi, false);
    return p..close();
  }

  /// The band of glass that makes up one wall.
  Path _wall(_Geo g, int s) {
    final p = Path()..moveTo(g.x(0, s), g.y(0));
    g.side(p, s, 0);
    g.side(p, s, g.wall, down: true);
    return p..close();
  }

  /// One edge line, from the foot to the rim.
  Path _edge(_Geo g, int s, double grow, {double from = 0}) {
    final p = Path()..moveTo(g.x(from, s) + s * grow, g.y(from));
    g.side(p, s, grow, from: from);
    return p;
  }

  // ------------------------------------------------------------- the glass

  void _shadow(Canvas canvas, _Geo g) {
    final r = g.rx(0) + g.wall;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(g.cx + r * 0.18, g.footY + r * 0.02),
        width: r * 2.7,
        height: r * 0.5,
      ),
      Paint()
        ..color = const Color(0x333B2414)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          math.max(1.0, r * 0.1),
        ),
    );
  }

  /// A faint cool tint over the whole glass, darker at the edges where you
  /// look through more glass.
  void _glassBody(Canvas canvas, _Geo g) {
    final left = g.cx - g.half - g.wall;
    final right = g.cx + g.half + g.wall;
    canvas.drawPath(
      _outside(g),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(left, 0),
          Offset(right, 0),
          const [
            Color(0x38A3B8C3),
            Color(0x14FFFFFF),
            Color(0x0AFFFFFF),
            Color(0x2EA3B8C3),
          ],
          const [0, 0.3, 0.7, 1],
        ),
    );
    // The back of the rim, seen through the glass.
    canvas.drawArc(
      g.oval(1),
      math.pi,
      math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x667A8C96),
    );
  }

  void _walls(Canvas canvas, _Geo g) {
    final band = Paint()..color = const Color(0x339DB2BD);
    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xA04E5C64);
    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x554E5C64);
    for (final s in [-1, 1]) {
      canvas.drawPath(_wall(g, s), band);
      canvas.drawPath(_edge(g, s, 0), inner);
      final path = Path()
        ..moveTo(g.x(0, s) + s * g.wall, g.footY)
        ..lineTo(g.x(0, s) + s * g.wall, g.y(0));
      g.side(path, s, g.wall);
      canvas.drawPath(path, outer);
    }
  }

  /// The solid glass foot under the floor.
  void _foot(Canvas canvas, _Geo g) {
    final left = g.x(0, -1) - g.wall;
    final right = g.x(0, 1) + g.wall;
    final foot = Path()
      ..moveTo(left, g.y(0))
      ..lineTo(left, g.footY)
      ..arcTo(g.footOval, math.pi, -math.pi, false)
      ..lineTo(right, g.y(0))
      ..arcTo(g.oval(0), 0, math.pi, false)
      ..close();
    canvas.drawPath(
      foot,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, g.y(0)),
          Offset(0, g.footY + g.footOval.height / 2),
          const [Color(0x40C4D3DA), Color(0x80A2B4BE)],
        ),
    );
    // Thick glass picks up the colour of the drink above it.
    if (drink case final d? when liquid > 0.002) {
      canvas.drawPath(
        foot,
        Paint()..color = Color(d.color).withValues(alpha: 0.28),
      );
    }
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xA04E5C64);
    canvas.drawArc(g.footOval, 0, math.pi, false, edge);
    // The floor seen through the foot.
    canvas.drawArc(
      g.oval(0),
      0,
      math.pi,
      false,
      edge..color = const Color(0x664E5C64),
    );
    // Light caught inside the foot.
    canvas.drawArc(
      g.footOval.deflate(g.wall * 0.8).translate(0, -g.base * 0.35),
      math.pi * 0.6,
      math.pi * 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.5, g.wall * 0.6)
        ..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  void _rim(Canvas canvas, _Geo g) {
    final outer = g.oval(1, grow: g.wall);
    final inner = g.oval(1);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(outer),
        Path()..addOval(inner),
      ),
      Paint()..color = const Color(0x40FFFFFF),
    );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xA04E5C64);
    canvas.drawOval(outer, edge);
    canvas.drawArc(
      inner,
      0,
      math.pi,
      false,
      edge
        ..strokeWidth = 1
        ..color = const Color(0x664E5C64),
    );
    // Light running along the front of the rim.
    canvas.drawArc(
      outer.deflate(g.wall * 0.4),
      math.pi * 0.55,
      math.pi * 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(1.5, g.wall * 0.6)
        ..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  /// Streaks of reflected light: a broad one down the left, a thin one on
  /// the right.
  void _highlights(Canvas canvas, _Geo g) {
    void streak(double at, double from, double to, double width, double a) {
      final p = Path()..moveTo(g.cx + g.rx(from) * at, g.y(from));
      for (var i = 1; i <= 32; i++) {
        final h = from + (to - from) * i / 32;
        p.lineTo(g.cx + g.rx(h) * at, g.y(h));
      }
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width
          ..shader = ui.Gradient.linear(
            Offset(0, g.y(to)),
            Offset(0, g.y(from)),
            [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: a),
              Colors.white.withValues(alpha: a * 0.8),
              Colors.white.withValues(alpha: 0),
            ],
            const [0, 0.25, 0.7, 1],
          ),
      );
    }

    streak(-0.76, 0.06, 0.94, math.max(1.0, g.half * 0.085), 0.55);
    streak(-0.6, 0.2, 0.8, math.max(0.5, g.half * 0.018), 0.35);
    streak(0.84, 0.18, 0.78, math.max(0.6, g.half * 0.03), 0.4);
  }

  // ------------------------------------------------------------- the drink

  void _drink(Canvas canvas, _Geo g) {
    final d = drink;
    if (d == null || (liquid <= 0.002 && foam <= 0.001)) return;
    final colour = Color(d.color);
    final deep = Color.lerp(colour, Colors.black, 0.3)!;
    final light = Color.lerp(colour, Colors.white, 0.2)!;
    final left = g.cx - g.half - g.wall;
    final right = g.cx + g.half + g.wall;

    if (liquid > 0.002) {
      final body = Rect.fromLTRB(
        left,
        g.y(liquid),
        right,
        g.floor + g.ry(0) + 1,
      );
      // Darker at the sides, where light travels through more drink.
      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(left, 0),
            Offset(right, 0),
            [deep, colour, light, colour, deep],
            const [0.04, 0.24, 0.42, 0.74, 0.96],
          ),
      );
      canvas.drawRect(
        body,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, body.top),
            Offset(0, body.bottom),
            [Colors.transparent, Colors.black.withValues(alpha: 0.2)],
          ),
      );
      if (d == Drink.soda) _fizz(canvas, g);

      // The top of the drink, seen from a little above.
      final top = g.oval(liquid);
      canvas.drawOval(top, Paint()..color = Color.lerp(colour, deep, 0.25)!);
      canvas.drawOval(
        top.deflate(top.height * 0.12).translate(0, -top.height * 0.08),
        Paint()
          ..shader = ui.Gradient.linear(top.topCenter, top.bottomCenter, [
            Color.lerp(colour, Colors.white, 0.35)!,
            colour,
          ]),
      );
      canvas.drawArc(
        top,
        0.15,
        math.pi - 0.3,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.4),
      );
    }

    if (foam > 0.001) _foam(canvas, g, d, left, right);
    if (stream > 0.01) _ripples(canvas, g);
  }

  void _foam(Canvas canvas, _Geo g, Drink d, double left, double right) {
    final low = liquid;
    final high = _surface;
    final foamColour = Color(d.foamColor);
    final shade = Color.lerp(foamColour, Color(d.color), 0.35)!;
    final bright = Color.lerp(foamColour, Colors.white, 0.45)!;

    canvas.drawOval(g.oval(low), Paint()..color = shade);
    canvas.drawRect(
      Rect.fromLTRB(left, g.y(high), right, g.y(low)),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, g.y(high)),
          Offset(0, g.y(low) + g.ry(low)),
          [bright, foamColour, shade],
          const [0, 0.55, 1],
        ),
    );
    final top = g.oval(high);
    canvas.drawOval(top, Paint()..color = bright);

    // Bubbles of many sizes. The seed is fixed, so they stay put instead of
    // flickering every frame.
    final rng = math.Random(d.index * 7 + 13);
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = shade.withValues(alpha: 0.55);
    final scale = g.half / 110;
    for (var i = 0; i < (g.half < 40 ? 10 : 70); i++) {
      final h = low + (high - low) * rng.nextDouble();
      final across = rng.nextDouble() * 2 - 1;
      final r = (0.7 + math.pow(rng.nextDouble(), 3) * 3.2) * scale;
      // Spread over the front of the foam and over its top.
      final onTop = i.isEven;
      final centre = onTop
          ? Offset(
              g.cx + across * top.width / 2 * 0.92,
              top.center.dy +
                  (rng.nextDouble() * 2 - 1) *
                      top.height /
                      2 *
                      math.sqrt(1 - across * across) *
                      0.9,
            )
          : Offset(g.cx + across * g.rx(h) * 0.95, g.y(h));
      canvas.drawCircle(centre, r, fill);
      canvas.drawCircle(centre, r, ring);
    }
  }

  /// Bubbles rising through a fizzy drink.
  void _fizz(Canvas canvas, _Geo g) {
    final rng = math.Random(29);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i < 18; i++) {
      final across = rng.nextDouble() * 1.7 - 0.85;
      final speed = 0.18 + rng.nextDouble() * 0.25;
      final h = ((rng.nextDouble() + time * speed) % 1) * liquid;
      canvas.drawCircle(
        Offset(g.cx + across * g.rx(h), g.y(h)),
        (1 + rng.nextDouble() * 1.4) * g.half / 110,
        paint,
      );
    }
  }

  /// Rings spreading out from where the stream lands.
  void _ripples(Canvas canvas, _Geo g) {
    final h = _surface;
    final centre = Offset(g.cx, g.y(h));
    for (var i = 0; i < 3; i++) {
      final t = (time * 1.4 + i / 3) % 1;
      final w = g.rx(h) * (0.2 + 1.5 * t);
      canvas.drawOval(
        Rect.fromCenter(center: centre, width: w, height: w * _Geo.tilt * 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: (1 - t) * 0.45 * stream),
      );
    }
  }

  // ------------------------------------------------------------ the stream

  void _stream(Canvas canvas, _Geo g) {
    final from = spout ? g.rim * 0.5 : 0.0;
    if (spout) _spout(canvas, g, Offset(g.cx + 1, from));
    final d = drink;
    if (stream <= 0.01 || d == null) return;
    final colour = Color(d.color);
    final scale = g.half / 110;
    final width = (5 + 7 * stream) * scale;
    final to = g.y(_surface);

    double sway(double t) => math.sin(t * 5 - time * 14) * 1.5 * stream;
    final path = Path()..moveTo(g.cx - width / 2, from);
    const steps = 18;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      // The stream narrows as it speeds up falling, and sways a little.
      final narrow = width * (1 - 0.3 * t) / 2;
      path.lineTo(g.cx + sway(t) - narrow, from + (to - from) * t);
    }
    for (var i = steps; i >= 0; i--) {
      final t = i / steps;
      final narrow = width * (1 - 0.3 * t) / 2;
      path.lineTo(g.cx + sway(t) + narrow, from + (to - from) * t);
    }
    canvas.drawPath(
      path..close(),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(g.cx - width / 2, 0),
          Offset(g.cx + width / 2, 0),
          [
            Color.lerp(colour, Colors.black, 0.25)!,
            Color.lerp(colour, Colors.white, 0.3)!,
            colour,
            Color.lerp(colour, Colors.black, 0.3)!,
          ],
          const [0, 0.3, 0.6, 1],
        ),
    );

    // Drops thrown up where the stream lands.
    final splash = Paint()..color = Color.lerp(colour, Colors.white, 0.4)!;
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + (i - 2.5) * 0.38;
      final reach =
          (7 + 5 * stream + math.sin(time * 11 + i * 1.7) * 2.5) * scale;
      canvas.drawCircle(
        Offset(
          g.cx + math.cos(angle) * reach * 1.6,
          to + math.sin(angle) * reach * 0.6,
        ),
        (1.1 + (i % 3) * 0.4) * scale,
        splash,
      );
    }
  }

  /// A small steel milk jug, tipped over the glass. It turns about the tip
  /// of its spout, so the stream always starts from the same place, and it
  /// tips further while pouring.
  void _spout(Canvas canvas, _Geo g, Offset tip) {
    final s = math.min(g.rim * 0.62, g.half * 0.55);
    final tilt = (45 + 17 * stream) * math.pi / 180;
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(tilt);

    // Drawn upright, with the tip of the spout at (0, 0).
    final top = 0.12 * s, bottom = 1.12 * s;
    final body = Path()
      ..moveTo(-0.81 * s, top)
      ..lineTo(-0.19 * s, top)
      ..quadraticBezierTo(-0.08 * s, 0.7 * s, -0.1 * s, bottom - 0.08 * s)
      ..quadraticBezierTo(-0.1 * s, bottom, -0.18 * s, bottom)
      ..lineTo(-0.82 * s, bottom)
      ..quadraticBezierTo(-0.9 * s, bottom, -0.9 * s, bottom - 0.08 * s)
      ..quadraticBezierTo(-0.92 * s, 0.7 * s, -0.81 * s, top)
      ..close();
    final lip = Path()
      ..moveTo(-0.34 * s, top)
      ..quadraticBezierTo(-0.12 * s, top - 0.02 * s, 0, 0)
      ..quadraticBezierTo(-0.06 * s, 0.2 * s, -0.17 * s, 0.34 * s)
      ..close();
    final steel = Paint()
      ..shader = ui.Gradient.linear(
        Offset(-0.92 * s, 0),
        Offset(-0.08 * s, 0),
        const [
          Color(0xFF8A959C),
          Color(0xFFDDE3E6),
          Color(0xFFF4F6F7),
          Color(0xFFA7B1B7),
          Color(0xFF6F7B83),
        ],
        const [0, 0.22, 0.34, 0.7, 1],
      );
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF5E6A71);

    // The handle, behind the body.
    final handle = Path()
      ..moveTo(-0.86 * s, 0.26 * s)
      ..cubicTo(-1.2 * s, 0.28 * s, -1.18 * s, 0.78 * s, -0.88 * s, 0.84 * s);
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.1 * s
        ..color = const Color(0xFF7D8990),
    );
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 0.03 * s
        ..color = const Color(0xFFD5DBDF),
    );

    canvas.drawPath(body, steel);
    canvas.drawPath(lip, steel);
    // A sharp band of light down the body, the way polished steel shines.
    canvas.drawRect(
      Rect.fromLTRB(-0.66 * s, top + 0.06 * s, -0.6 * s, bottom - 0.1 * s),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawPath(body, edge);
    canvas.drawPath(lip, edge);
    // The opening at the top, dark inside.
    canvas.drawOval(
      Rect.fromLTRB(-0.8 * s, top - 0.05 * s, -0.2 * s, top + 0.05 * s),
      Paint()..color = const Color(0xFF4A555C),
    );
    canvas.restore();
  }

  // -------------------------------------------------------------- the line

  /// The line to stop on, drawn round the glass the same way the drink's
  /// surface is, so a perfect pour sits exactly on it. Short ticks outside
  /// the walls and an arrow make it easy to find.
  void _line(Canvas canvas, _Geo g) {
    final at = line;
    if (at == null) return;
    final oval = g.oval(at, grow: g.wall * 0.5);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = lineColor;
    _dashed(
      canvas,
      Path()..addArc(oval, math.pi, math.pi),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = lineColor.withValues(alpha: 0.4),
    );
    _dashed(canvas, Path()..addArc(oval, 0, math.pi), paint);

    final y = g.y(at);
    final edge = g.rx(at) + g.wall;
    final reach = g.half * 0.28;
    canvas.drawLine(
      Offset(g.cx - edge - reach, y),
      Offset(g.cx - edge - 5, y),
      paint,
    );
    canvas.drawLine(
      Offset(g.cx + edge + 5, y),
      Offset(g.cx + edge + reach, y),
      paint,
    );
    final tip = g.cx + edge + reach + 3;
    canvas.drawPath(
      Path()
        ..moveTo(tip + 8, y - 6)
        ..lineTo(tip, y)
        ..lineTo(tip + 8, y + 6)
        ..close(),
      Paint()..color = lineColor,
    );
  }

  static void _dashed(Canvas canvas, Path path, Paint paint) {
    const dash = 8.0, gap = 6.0;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += dash + gap) {
        canvas.drawPath(m.extractPath(d, math.min(d + dash, m.length)), paint);
      }
    }
  }
}

/// Where everything sits on the canvas.
class _Geo {
  _Geo(this.shape, Size size, double rimAt, double floorAt, double widthScale)
    : cx = size.width / 2,
      rim = size.height * rimAt,
      floor = size.height * floorAt {
    height = floor - rim;
    half = math.min(size.width * 0.3, height * widthScale);
    wall = math.max(1.2, half * 0.05);
    base = math.max(2.0, height * 0.07);
  }

  /// How flat the ovals are: how far above the glass we are looking from.
  static const tilt = 0.12;

  final GlassShape shape;
  final double cx, rim, floor;
  late final double height, half, wall, base;

  double rx(double h) => shape.widthAt(h) * half;
  double ry(double h) => rx(h) * tilt;
  double x(double h, int side) => cx + side * rx(h);
  double y(double h) => floor - h * height;

  /// The glass's cross-section at height [h], as seen from a little above.
  Rect oval(double h, {double grow = 0}) => Rect.fromCenter(
    center: Offset(cx, y(h)),
    width: 2 * (rx(h) + grow),
    height: 2 * (rx(h) + grow) * tilt,
  );

  double get footY => floor + base;

  Rect get footOval => Rect.fromCenter(
    center: Offset(cx, footY),
    width: 2 * (rx(0) + wall),
    height: 2 * (rx(0) + wall) * tilt,
  );

  /// Adds one wall to [p], from the foot to the rim (or back down), moved
  /// [grow] outward.
  void side(Path p, int s, double grow, {bool down = false, double from = 0}) {
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final h = down ? 1 - t : from + (1 - from) * t;
      p.lineTo(x(h, s) + s * grow, y(h));
    }
  }
}
