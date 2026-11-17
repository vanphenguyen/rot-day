import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/level.dart';
import '../game/pour_physics.dart';

/// Draws the glass, the drink in it, the foam, the falling stream and the
/// line to aim for.
///
/// Everything is worked out from the level's outline, so a new glass shape
/// needs no change here.
class GlassPainter extends CustomPainter {
  GlassPainter({
    required this.sim,
    required this.glassColor,
    required this.lineColor,
    this.time = 0,
  });

  final PourSim sim;

  /// Colour of the rim and the outline.
  final Color glassColor;

  /// Colour of the dashed line to aim for.
  final Color lineColor;

  /// Seconds since the round began, for the ripples and the stream.
  final double time;

  Level get level => sim.level;

  @override
  void paint(Canvas canvas, Size size) {
    // Room above the glass for the stream to fall through.
    final glassTop = size.height * 0.16;
    final glassBottom = size.height * 0.96;
    final glassHeight = glassBottom - glassTop;
    final halfWidth = math.min(size.width * 0.3, glassHeight * 0.26);
    final centre = size.width / 2;

    double xAt(double height, int side) =>
        centre + side * level.widthAt(height) * halfWidth;
    double yAt(double height) => glassBottom - height * glassHeight;

    final inside = _glassPath(xAt, yAt);

    _paintStream(canvas, size, centre, glassTop, xAt, yAt);

    // Everything in the glass is clipped to its outline.
    canvas.save();
    canvas.clipPath(inside);
    _paintDrink(canvas, xAt, yAt, glassBottom);
    canvas.restore();

    _paintLine(canvas, size, centre, halfWidth, xAt, yAt);
    _paintGlass(canvas, inside, xAt, yAt);
  }

  /// The inside of the glass as a closed shape.
  Path _glassPath(double Function(double, int) xAt, double Function(double) yAt) {
    const steps = 40;
    final path = Path()..moveTo(xAt(0, -1), yAt(0));
    for (var i = 1; i <= steps; i++) {
      path.lineTo(xAt(i / steps, -1), yAt(i / steps));
    }
    for (var i = steps; i >= 0; i--) {
      path.lineTo(xAt(i / steps, 1), yAt(i / steps));
    }
    return path..close();
  }

  void _paintDrink(
    Canvas canvas,
    double Function(double, int) xAt,
    double Function(double) yAt,
    double glassBottom,
  ) {
    final liquid = sim.liquidHeight;
    if (liquid <= 0 && sim.foam <= 0) return;
    final colour = Color(level.drink.color);

    // The drink, with a slightly darker bottom so it reads as a volume.
    if (liquid > 0) {
      final top = yAt(liquid);
      canvas.drawRect(
        Rect.fromLTRB(0, top, 4000, glassBottom),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colour, Color.lerp(colour, Colors.black, 0.22)!],
          ).createShader(Rect.fromLTRB(0, top, 4000, glassBottom)),
      );
      _paintSurface(canvas, xAt, yAt, liquid, colour);
    }

    // Foam sits on top of the drink.
    if (sim.foam > 0.001) {
      final top = yAt(math.min(1, liquid + sim.foam));
      final bottom = yAt(liquid);
      canvas.drawRect(
        Rect.fromLTRB(0, top, 4000, bottom),
        Paint()..color = Color(level.drink.foamColor),
      );
      // Bubbles, so foam does not look like a flat slab. The seed is fixed,
      // so they stay put instead of flickering every frame.
      final rng = math.Random(level.drink.index * 7 + 13);
      final bubbles = Paint()..color = Colors.white.withValues(alpha: 0.5);
      for (var i = 0; i < 18; i++) {
        final height = liquid + sim.foam * rng.nextDouble();
        // Somewhere across the glass at that height.
        final left = xAt(height, -1);
        final right = xAt(height, 1);
        final x = left + (right - left) * rng.nextDouble();
        canvas.drawCircle(
          Offset(x, yAt(height)),
          1.2 + rng.nextDouble() * 1.8,
          bubbles,
        );
      }
    }
  }

  /// A rippling line where the drink meets the air, strongest while pouring.
  void _paintSurface(
    Canvas canvas,
    double Function(double, int) xAt,
    double Function(double) yAt,
    double liquid,
    Color colour,
  ) {
    final y = yAt(liquid);
    final left = xAt(liquid, -1);
    final right = xAt(liquid, 1);
    final strength = sim.stream > 0 ? 1.6 : 0.4;
    final path = Path()..moveTo(left, y);
    const steps = 24;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final wave = math.sin(t * math.pi * 3 + time * 9) * strength;
      path.lineTo(left + (right - left) * t, y + wave);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Color.lerp(colour, Colors.white, 0.45)!,
    );
  }

  /// The stream falling from above into the glass.
  void _paintStream(
    Canvas canvas,
    Size size,
    double centre,
    double glassTop,
    double Function(double, int) xAt,
    double Function(double) yAt,
  ) {
    if (sim.stream <= 0.01) return;
    final surface = yAt(sim.surfaceHeight);
    final width = 5 + 7 * sim.stream;
    final colour = Color(level.drink.color);

    // The spout, so the drink comes from something.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centre, glassTop * 0.34), width: 54, height: 16),
        const Radius.circular(8),
      ),
      Paint()..color = glassColor.withValues(alpha: 0.55),
    );

    final path = Path()..moveTo(centre - width / 2, glassTop * 0.42);
    const steps = 18;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = glassTop * 0.42 + (surface - glassTop * 0.42) * t;
      // The stream narrows as it speeds up falling, and sways a little.
      final narrow = width * (1 - 0.3 * t) / 2;
      final sway = math.sin(t * 5 - time * 14) * 1.5 * sim.stream;
      path.lineTo(centre + sway - narrow, y);
    }
    for (var i = steps; i >= 0; i--) {
      final t = i / steps;
      final y = glassTop * 0.42 + (surface - glassTop * 0.42) * t;
      final narrow = width * (1 - 0.3 * t) / 2;
      final sway = math.sin(t * 5 - time * 14) * 1.5 * sim.stream;
      path.lineTo(centre + sway + narrow, y);
    }
    canvas.drawPath(path..close(), Paint()..color = colour);

    // Splash where the stream lands.
    final splash = Paint()..color = Color.lerp(colour, Colors.white, 0.5)!;
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.42;
      final reach = 7 + 5 * sim.stream + math.sin(time * 11 + i) * 2;
      canvas.drawCircle(
        Offset(centre + math.cos(angle) * reach * 1.6, surface + math.sin(angle) * reach * 0.5),
        1.6,
        splash,
      );
    }
  }

  /// The dashed line to let go on, with the glass's rim.
  void _paintLine(
    Canvas canvas,
    Size size,
    double centre,
    double halfWidth,
    double Function(double, int) xAt,
    double Function(double) yAt,
  ) {
    final y = yAt(level.line);
    final reach = level.widthAt(level.line) * halfWidth + halfWidth * 0.34;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const dash = 9.0, gap = 6.0;
    for (var x = centre - reach; x < centre + reach; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, centre + reach), y), paint);
    }
    // A small arrow on the right, so the line reads as a target.
    final tip = centre + reach + 3;
    canvas.drawPath(
      Path()
        ..moveTo(tip + 7, y - 5)
        ..lineTo(tip, y)
        ..lineTo(tip + 7, y + 5)
        ..close(),
      Paint()..color = lineColor,
    );
  }

  /// The glass itself: outline up both sides plus the rim.
  void _paintGlass(
    Canvas canvas,
    Path inside,
    double Function(double, int) xAt,
    double Function(double) yAt,
  ) {
    canvas.drawPath(
      inside,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.round
        ..color = glassColor,
    );
    // A highlight down the left, the way light sits on real glass.
    final highlight = Path()..moveTo(xAt(0.06, -1) + 6, yAt(0.06));
    for (var i = 1; i <= 20; i++) {
      final h = 0.06 + 0.86 * i / 20;
      highlight.lineTo(xAt(h, -1) + 6, yAt(h));
    }
    canvas.drawPath(
      highlight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.sim != sim ||
      old.time != time ||
      old.glassColor != glassColor ||
      old.lineColor != lineColor;
}
