import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:posyandu_app/core/constant/constants.dart';

class SeamlessPattern extends StatelessWidget {
  final double offset;

  const SeamlessPattern({super.key, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF009688),
      child: CustomPaint(
        painter: _UltimateBatikPainter(offset: offset),
        child: Container(),
      ),
    );
  }
}

class _UltimateBatikPainter extends CustomPainter {
  final double offset;

  _UltimateBatikPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random fixedRnd = math.Random(42);

    canvas.save();
    canvas.translate(-size.width * offset, 0);

    final double totalWidth = size.width * 3;
    final double h = size.height;
    final Rect fullRect = Rect.fromLTWH(0, 0, totalWidth, h);

    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromARGB(255, 28, 96, 101), // Kiri
          AppColors.primary, // Kiri-Tengah
          AppColors.primary, // Tengah
          Color(0xFFFFB74D), // Tengah-Kanan
          AppColors.accent, // Kanan
        ],
        stops: [0.0, 0.3, 0.5, 0.8, 1.0],
      ).createShader(fullRect);

    canvas.drawRect(fullRect, bgPaint);

    _drawDiamondTexture(canvas, totalWidth, h);

    _drawMagicDust(canvas, totalWidth, h, fixedRnd);

    final Paint floraPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final Paint veinPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _drawFoliageZone(
      canvas,
      fixedRnd,
      floraPaint,
      veinPaint,
      0,
      size.width,
      h,
      12,
    );
    _drawFoliageZone(
      canvas,
      fixedRnd,
      floraPaint,
      veinPaint,
      size.width * 2,
      totalWidth,
      h,
      12,
    );

    _drawStylizedBird(canvas, Offset(totalWidth * 0.5, h * 0.55), h * 0.8);

    final flowPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    Path flow = Path();
    flow.moveTo(0, h * 0.8);
    flow.cubicTo(
      totalWidth * 0.3,
      h * 0.4,
      totalWidth * 0.7,
      h * 1.2,
      totalWidth,
      h * 0.3,
    );
    canvas.drawPath(flow, flowPaint);

    canvas.restore();
  }

  void _drawDiamondTexture(Canvas canvas, double width, double height) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double step = 40.0;

    for (double i = -height; i < width; i += step) {
      canvas.drawLine(Offset(i, height), Offset(i + height, 0), linePaint);
    }

    for (double i = 0; i < width + height; i += step) {
      canvas.drawLine(Offset(i, height), Offset(i - height, 0), linePaint);
    }
  }

  void _drawMagicDust(
    Canvas canvas,
    double width,
    double height,
    math.Random rnd,
  ) {
    final Paint dustPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.1);

    for (int i = 0; i < 50; i++) {
      double dx = rnd.nextDouble() * width;
      double dy = rnd.nextDouble() * height;
      double r = rnd.nextDouble() * 2 + 1;

      canvas.drawCircle(Offset(dx, dy), r, dustPaint);
    }

    final Paint sparklePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.2);

    for (int i = 0; i < 15; i++) {
      double dx = rnd.nextDouble() * width;
      double dy = rnd.nextDouble() * height;

      Path sparkle = Path();
      sparkle.moveTo(dx, dy - 4);
      sparkle.lineTo(dx + 3, dy);
      sparkle.lineTo(dx, dy + 4);
      sparkle.lineTo(dx - 3, dy);
      sparkle.close();
      canvas.drawPath(sparkle, sparklePaint);
    }
  }

  void _drawFoliageZone(
    Canvas canvas,
    math.Random rnd,
    Paint leafPaint,
    Paint veinPaint,
    double startX,
    double endX,
    double h,
    int count,
  ) {
    for (int i = 0; i < count; i++) {
      double dx = startX + rnd.nextDouble() * (endX - startX);
      double dy = rnd.nextDouble() * h;
      double scale = 0.5 + rnd.nextDouble() * 0.8;
      double rotation = rnd.nextDouble() * 2 * math.pi;

      _drawSingleLeaf(
        canvas,
        Offset(dx, dy),
        scale,
        rotation,
        leafPaint,
        veinPaint,
      );
    }
  }

  void _drawSingleLeaf(
    Canvas canvas,
    Offset pos,
    double scale,
    double rotation,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    Path leafPath = Path();
    leafPath.moveTo(0, -30);
    leafPath.quadraticBezierTo(20, -10, 0, 30);
    leafPath.quadraticBezierTo(-20, -10, 0, -30);
    leafPath.close();

    canvas.drawPath(leafPath, fillPaint);
    canvas.drawLine(const Offset(0, -25), const Offset(0, 25), strokePaint);

    canvas.restore();
  }

  void _drawStylizedBird(Canvas canvas, Offset center, double size) {
    final Paint birdFillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.4),
          const Color(0xFFFFE0B2).withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCenter(center: center, width: size, height: size))
      ..style = PaintingStyle.fill;

    final Paint birdOutlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    double scale = size / 250.0;
    canvas.scale(scale);
    canvas.translate(-50, -20);

    Path birdPath = Path();
    birdPath.moveTo(-80, -40);
    birdPath.cubicTo(-60, -60, -20, -70, 0, -50);
    birdPath.cubicTo(20, -30, 30, 0, 50, 20);
    birdPath.cubicTo(40, 50, 0, 70, -40, 50);
    birdPath.cubicTo(-80, 30, -120, 0, -150, 20);
    birdPath.cubicTo(-180, -50, -120, -120, 0, -150);
    birdPath.cubicTo(-40, -100, -80, -60, -80, -40);
    birdPath.close();

    canvas.drawPath(birdPath, birdFillPaint);
    canvas.drawPath(birdPath, birdOutlinePaint);

    Path wingDetail = Path();
    wingDetail.moveTo(-30, -10);
    wingDetail.quadraticBezierTo(0, 10, 30, 0);
    wingDetail.moveTo(-40, 10);
    wingDetail.quadraticBezierTo(-10, 30, 20, 20);
    canvas.drawPath(wingDetail, birdOutlinePaint..strokeWidth = 1.5);

    canvas.drawCircle(
      const Offset(-45, -45),
      4,
      birdFillPaint..color = Colors.white,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UltimateBatikPainter oldDelegate) =>
      oldDelegate.offset != offset;
}
