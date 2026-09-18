import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// VietnamMapBackground:
/// Proton VPN-style background featuring deep dark obsidian gradient,
/// static white line-art contour of Vietnam mainland & islands with custom opacity,
/// and a subtle static location marker over Ho Chi Minh City without any flickering/blinking.
class VietnamMapBackground extends StatelessWidget {
  final Widget? child;
  final double opacity;
  final bool showBeacon;

  const VietnamMapBackground({
    super.key,
    this.child,
    this.opacity = 0.09,
    this.showBeacon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF), // Crisp White top
            Color(0xFFFFF9F5), // Soft pastel peach/cream
            Color(0xFFF6F2EB), // Warm light base
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Static Pastel Line-Art Vietnam Map Canvas (no blinking)
          CustomPaint(
            painter: VietnamMapPainter(
              opacity: opacity,
              showBeacon: showBeacon,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

/// Custom painter rendering the S-curve contours of Vietnam and regional islands
class VietnamMapPainter extends CustomPainter {
  final double opacity;
  final bool showBeacon;

  const VietnamMapPainter({
    required this.opacity,
    required this.showBeacon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final linePaint = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: opacity * 1.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final secondaryLinePaint = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: opacity * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95;

    final fillPaint = Paint()
      ..color = const Color(0xFFFF7A45).withValues(alpha: opacity * 0.15)
      ..style = PaintingStyle.fill;

    // Normalize coordinates mapped to canvas size
    // Aspect ratio of Vietnam is approx 1:2.3 (width to height)
    final mapHeight = size.height * 0.78;
    final mapWidth = mapHeight * 0.48;
    final offsetX = size.width * 0.52 - mapWidth * 0.5;
    final offsetY = size.height * 0.08;

    // Scaled coordinate helper
    Offset pt(double xRatio, double yRatio) {
      return Offset(offsetX + xRatio * mapWidth, offsetY + yRatio * mapHeight);
    }

    // 1. VIETNAM MAINLAND S-CURVE PATH
    final sCurve = Path();
    sCurve.moveTo(pt(0.24, 0.02).dx, pt(0.24, 0.02).dy);

    // North border (Lai Chau -> Ha Giang -> Cao Bang -> Lang Son -> Mong Cai)
    sCurve.cubicTo(
      pt(0.35, 0.00).dx, pt(0.35, 0.00).dy,
      pt(0.55, 0.01).dx, pt(0.55, 0.01).dy,
      pt(0.74, 0.05).dx, pt(0.74, 0.05).dy,
    );
    sCurve.cubicTo(
      pt(0.85, 0.08).dx, pt(0.85, 0.08).dy,
      pt(0.92, 0.12).dx, pt(0.92, 0.12).dy,
      pt(0.88, 0.16).dx, pt(0.88, 0.16).dy,
    );
    // Red River Delta coast (Hai Phong, Nam Dinh)
    sCurve.cubicTo(
      pt(0.80, 0.18).dx, pt(0.80, 0.18).dy,
      pt(0.72, 0.22).dx, pt(0.72, 0.22).dy,
      pt(0.65, 0.26).dx, pt(0.65, 0.26).dy,
    );
    // Thanh Hoa - Nghe An - Ha Tinh
    sCurve.cubicTo(
      pt(0.62, 0.29).dx, pt(0.62, 0.29).dy,
      pt(0.66, 0.35).dx, pt(0.66, 0.35).dy,
      pt(0.72, 0.40).dx, pt(0.72, 0.40).dy,
    );
    // Quang Binh - Quang Tri - Hue (Narrow waist)
    sCurve.cubicTo(
      pt(0.76, 0.44).dx, pt(0.76, 0.44).dy,
      pt(0.82, 0.48).dx, pt(0.82, 0.48).dy,
      pt(0.88, 0.52).dx, pt(0.88, 0.52).dy,
    );
    // Da Nang - Quang Nam - Quang Ngai - Binh Dinh
    sCurve.cubicTo(
      pt(0.94, 0.55).dx, pt(0.94, 0.55).dy,
      pt(0.96, 0.60).dx, pt(0.96, 0.60).dy,
      pt(0.98, 0.66).dx, pt(0.98, 0.66).dy,
    );
    // Phu Yen - Khanh Hoa (Nha Trang cape)
    sCurve.cubicTo(
      pt(1.02, 0.70).dx, pt(1.02, 0.70).dy,
      pt(0.98, 0.76).dx, pt(0.98, 0.76).dy,
      pt(0.92, 0.81).dx, pt(0.92, 0.81).dy,
    );
    // Ninh Thuan - Binh Thuan (Phan Thiet)
    sCurve.cubicTo(
      pt(0.85, 0.85).dx, pt(0.85, 0.85).dy,
      pt(0.78, 0.88).dx, pt(0.78, 0.88).dy,
      pt(0.70, 0.90).dx, pt(0.70, 0.90).dy,
    );
    // Ba Ria Vung Tau -> Mekong Delta coast
    sCurve.cubicTo(
      pt(0.65, 0.92).dx, pt(0.65, 0.92).dy,
      pt(0.55, 0.96).dx, pt(0.55, 0.96).dy,
      pt(0.46, 0.99).dx, pt(0.46, 0.99).dy,
    );
    // Ca Mau Cape (Southern tip)
    sCurve.cubicTo(
      pt(0.40, 1.00).dx, pt(0.40, 1.00).dy,
      pt(0.35, 0.97).dx, pt(0.35, 0.97).dy,
      pt(0.34, 0.93).dx, pt(0.34, 0.93).dy,
    );
    // Gulf of Thailand coast (Kien Giang - Ha Tien)
    sCurve.cubicTo(
      pt(0.32, 0.90).dx, pt(0.32, 0.90).dy,
      pt(0.38, 0.87).dx, pt(0.38, 0.87).dy,
      pt(0.40, 0.84).dx, pt(0.40, 0.84).dy,
    );
    // Cambodia border (An Giang, Tay Ninh)
    sCurve.cubicTo(
      pt(0.44, 0.80).dx, pt(0.44, 0.80).dy,
      pt(0.50, 0.77).dx, pt(0.50, 0.77).dy,
      pt(0.52, 0.72).dx, pt(0.52, 0.72).dy,
    );
    // Central Highlands (Dak Nong, Dak Lak, Gia Lai, Kon Tum)
    sCurve.cubicTo(
      pt(0.58, 0.67).dx, pt(0.58, 0.67).dy,
      pt(0.62, 0.60).dx, pt(0.62, 0.60).dy,
      pt(0.64, 0.54).dx, pt(0.64, 0.54).dy,
    );
    // Laos border (Truong Son Mountain Range)
    sCurve.cubicTo(
      pt(0.58, 0.48).dx, pt(0.58, 0.48).dy,
      pt(0.52, 0.42).dx, pt(0.52, 0.42).dy,
      pt(0.44, 0.35).dx, pt(0.44, 0.35).dy,
    );
    sCurve.cubicTo(
      pt(0.38, 0.28).dx, pt(0.38, 0.28).dy,
      pt(0.30, 0.22).dx, pt(0.30, 0.22).dy,
      pt(0.26, 0.16).dx, pt(0.26, 0.16).dy,
    );
    // Northwest border (Dien Bien, Son La, Lai Chau)
    sCurve.cubicTo(
      pt(0.18, 0.12).dx, pt(0.18, 0.12).dy,
      pt(0.12, 0.07).dx, pt(0.12, 0.07).dy,
      pt(0.24, 0.02).dx, pt(0.24, 0.02).dy,
    );
    sCurve.close();

    canvas.drawPath(sCurve, fillPaint);
    canvas.drawPath(sCurve, linePaint);

    // 2. NEIGHBORING REGIONAL CONTOURS (Contextual outlines like Proton VPN)
    // Laos & Cambodia subtle hint
    final indochinaHint = Path();
    indochinaHint.moveTo(pt(0.12, 0.07).dx, pt(0.12, 0.07).dy);
    indochinaHint.cubicTo(
      pt(-0.15, 0.18).dx, pt(-0.15, 0.18).dy,
      pt(-0.10, 0.45).dx, pt(-0.10, 0.45).dy,
      pt(0.15, 0.65).dx, pt(0.15, 0.65).dy,
    );
    indochinaHint.cubicTo(
      pt(0.20, 0.74).dx, pt(0.20, 0.74).dy,
      pt(0.24, 0.85).dx, pt(0.24, 0.85).dy,
      pt(0.32, 0.90).dx, pt(0.32, 0.90).dy,
    );
    canvas.drawPath(indochinaHint, secondaryLinePaint);

    // 3. ISLANDS & ARCHIPELAGOS
    // Phu Quoc Island
    final phuQuoc = Path()
      ..addOval(Rect.fromCenter(
        center: pt(0.22, 0.91),
        width: mapWidth * 0.055,
        height: mapHeight * 0.035,
      ));
    canvas.drawPath(phuQuoc, linePaint);

    // Con Dao Island
    final conDao = Path()
      ..addOval(Rect.fromCircle(center: pt(0.66, 0.97), radius: mapWidth * 0.02));
    canvas.drawPath(conDao, linePaint);

    // Hoang Sa Archipelago (Paracel Islands)
    final hoangSaCenter = pt(1.24, 0.44);
    _drawIslandCluster(canvas, hoangSaCenter, mapWidth * 0.015, linePaint);

    // Truong Sa Archipelago (Spratly Islands)
    final truongSaCenter = pt(1.28, 0.78);
    _drawIslandCluster(canvas, truongSaCenter, mapWidth * 0.016, linePaint);

    // 4. PULSING RADAR BEACON OVER HO CHI MINH CITY (MetroGo Capital)
    if (showBeacon) {
      final hcmc = pt(0.66, 0.86); // Ho Chi Minh City approximate coordinates

      // Static subtle marker (no pulsating waves)
      final ringPaint = Paint()
        ..color = const Color(0xFFFF5277).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(hcmc, 8.0, ringPaint);

      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hcmc, 3.5, centerPaint);

      final corePaint = Paint()
        ..color = const Color(0xFFFF453A)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(hcmc, 2.0, corePaint);
    }
  }

  void _drawIslandCluster(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(Offset(center.dx - size * 1.5, center.dy + size * 0.8), size * 0.75, paint);
    canvas.drawCircle(Offset(center.dx + size * 1.6, center.dy - size * 0.6), size * 0.85, paint);
    canvas.drawCircle(Offset(center.dx + size * 0.8, center.dy + size * 1.8), size * 0.7, paint);
    canvas.drawCircle(Offset(center.dx - size * 0.9, center.dy + size * 2.1), size * 0.65, paint);
  }

  @override
  bool shouldRepaint(covariant VietnamMapPainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.showBeacon != showBeacon;
  }
}
