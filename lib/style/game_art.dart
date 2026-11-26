import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/drink.dart';
import '../game/glass_shape.dart';
import '../game/scoring.dart';
import '../widgets/glass_painter.dart';
import 'palette.dart';

/// The game's own pictures, drawn in code, used instead of emoji.
///
/// Emoji look different on every phone and make an app look thrown
/// together. These match the palette and the glass on the pour screen.

// ---------------------------------------------------------------- ratings

extension RatingArt on Rating {
  Color get color => switch (this) {
    Rating.perfect => Palette.gold,
    Rating.great => Palette.teal,
    Rating.good => Palette.sky,
    Rating.miss => Palette.inkSoft,
    Rating.spilled => Palette.tomato,
  };

  IconData get icon => switch (this) {
    Rating.perfect => Icons.gps_fixed_rounded,
    Rating.great => Icons.check_rounded,
    Rating.good => Icons.thumb_up_alt_rounded,
    Rating.miss => Icons.close_rounded,
    Rating.spilled => Icons.water_drop_rounded,
  };
}

/// A round coloured badge for a rating.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.size = 32});

  final Rating rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rating.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.08),
        boxShadow: [
          BoxShadow(
            color: rating.color.withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(rating.icon, color: Colors.white, size: size * 0.55),
    );
  }
}

// ----------------------------------------------------------------- medals

extension MedalArt on Medal {
  IconData get icon => switch (this) {
    Medal.firstPour => Icons.local_drink_rounded,
    Medal.firstPerfect => Icons.gps_fixed_rounded,
    Medal.threePerfect => Icons.diamond_rounded,
    Medal.fiveInARow => Icons.local_fire_department_rounded,
    Medal.tenGlasses => Icons.looks_one_rounded,
    Medal.twentyGlasses => Icons.emoji_events_rounded,
    Medal.everyDrink => Icons.restaurant_menu_rounded,
    Medal.everyShape => Icons.view_column_rounded,
    Medal.weekStreak => Icons.event_available_rounded,
    Medal.noSpillRun => Icons.verified_rounded,
  };

  Color get color => switch (this) {
    Medal.firstPour => Palette.sky,
    Medal.firstPerfect => Palette.tomato,
    Medal.threePerfect => Palette.teal,
    Medal.fiveInARow => const Color(0xFFF2762C),
    Medal.tenGlasses => Palette.amber,
    Medal.twentyGlasses => Palette.gold,
    Medal.everyDrink => const Color(0xFFE86A8C),
    Medal.everyShape => const Color(0xFF7A6BD1),
    Medal.weekStreak => Palette.mint,
    Medal.noSpillRun => const Color(0xFF2FA7C8),
  };
}

/// A medal: a coloured disc with a white rim and two ribbon tails.
/// Locked medals are drawn flat in a muted colour with a padlock.
class MedalBadge extends StatelessWidget {
  const MedalBadge({
    super.key,
    required this.medal,
    this.earned = true,
    this.size = 48,
  });

  final Medal medal;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colour = earned ? medal.color : Palette.locked;
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: CustomPaint(
        painter: _MedalPainter(colour),
        child: Align(
          alignment: const Alignment(0, -0.18),
          child: Icon(
            earned ? medal.icon : Icons.lock_rounded,
            color: Colors.white,
            size: size * 0.42,
          ),
        ),
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  _MedalPainter(this.colour);

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final centre = Offset(r, r);
    final dark = Color.lerp(colour, Colors.black, 0.25)!;

    // Ribbon tails, behind the disc.
    final ribbon = Paint()..color = dark;
    for (final side in [-1, 1]) {
      final path = Path()
        ..moveTo(r + side * r * 0.15, r)
        ..lineTo(r + side * r * 0.62, r)
        ..lineTo(r + side * r * 0.55, size.height)
        ..lineTo(r + side * r * 0.36, size.height * 0.9)
        ..lineTo(r + side * r * 0.2, size.height)
        ..close();
      canvas.drawPath(path, ribbon);
    }

    canvas.drawCircle(
      centre + Offset(0, r * 0.06),
      r * 0.86,
      Paint()..color = dark,
    );
    canvas.drawCircle(centre, r * 0.86, Paint()..color = Colors.white);
    canvas.drawCircle(centre, r * 0.74, Paint()..color = colour);
    // A soft shine across the top.
    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: r * 0.6),
      math.pi * 1.1,
      math.pi * 0.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.1
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(_MedalPainter old) => old.colour != colour;
}

// ------------------------------------------------------- drinks and glasses

/// A small glass of [drink] in the shape [shape], filled to [fill].
/// Used wherever a drink is named, instead of a drink emoji.
class DrinkGlass extends StatelessWidget {
  const DrinkGlass({
    super.key,
    required this.drink,
    this.shape = GlassShape.straight,
    this.fill = 0.68,
    this.size = 28,
    this.outline = Palette.ink,
  });

  final Drink? drink;
  final GlassShape shape;
  final double fill;
  final double size;
  final Color outline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlassIconPainter(drink, shape, fill, outline),
      ),
    );
  }
}

class _GlassIconPainter extends CustomPainter {
  _GlassIconPainter(this.drink, this.shape, this.fill, this.outline);

  final Drink? drink;
  final GlassShape shape;
  final double fill;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final d = drink;
    GlassArt(
      shape: shape,
      drink: d,
      liquid: d == null ? 0 : fill,
      foam: d != null && d.hasFoam
          ? math.min(1 - fill, 0.08 + d.foamPerHeight * 0.25)
          : 0,
      spout: false,
      rimAt: 0.1,
      floorAt: 0.84,
      widthScale: 0.5,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(_GlassIconPainter old) =>
      old.drink != drink ||
      old.shape != shape ||
      old.fill != fill ||
      old.outline != outline;
}

// ------------------------------------------------------------------ stars

/// Three stars with [filled] of them lit, drawn in gold.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.filled, this.size = 22});

  final int filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == 1 ? size * 0.25 : 0),
            child: Icon(
              Icons.star_rounded,
              size: i == 1 ? size * 1.2 : size,
              color: i < filled ? Palette.gold : Palette.locked,
            ),
          ),
      ],
    );
  }
}
