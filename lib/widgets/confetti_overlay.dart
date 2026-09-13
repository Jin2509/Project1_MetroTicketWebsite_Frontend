import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight Confetti Celebration Effect Overlay
/// Produces a vibrant shower of falling and rotating confetti pieces.
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final Duration duration;

  const ConfettiOverlay({
    super.key,
    required this.child,
    required this.isPlaying,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  final List<Color> _colors = const [
    Color(0xFF2F6FED), // Primary Blue
    Color(0xFF34C759), // Green
    Color(0xFFFF9F0A), // Orange
    Color(0xFFFF3B30), // Red
    Color(0xFFA50064), // Magenta/Purple
    Color(0xFF00C7BE), // Cyan
    Color(0xFFFFD60A), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
        });
      });

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < 65; i++) {
      _particles.add(
        _ConfettiParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.4,
          y: 0.35,
          vx: (_random.nextDouble() - 0.5) * 0.035,
          vy: -0.015 - _random.nextDouble() * 0.035,
          size: 6 + _random.nextDouble() * 8,
          color: _colors[_random.nextInt(_colors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.25,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x; // 0.0 to 1.0 (relative width)
  double y; // 0.0 to 1.0 (relative height)
  double vx;
  double vy;
  final double size;
  final Color color;
  double rotation;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.0012; // Gravity
    rotation += rotationSpeed;
    vx *= 0.99; // Air drag
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - (progress - 0.65) / 0.35).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      if (py > size.height || px < -20 || px > size.width + 20) continue;

      paint.color = p.color.withValues(alpha: opacity);

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation);

      // Draw small rectangle or circle
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.55,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
