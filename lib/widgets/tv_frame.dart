import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Overlays CRT-style scanlines and a vignette effect on top of content
/// to simulate an old TV screen.
class TvFrame extends StatelessWidget {
  final Widget child;

  const TvFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        child,

        // Scanline overlay
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _ScanlinePainter())),
        ),

        // Vignette overlay
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Subtle rounded border glow
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: WeatherColors.borderGlow.withValues(alpha: 0.15),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints faint horizontal scanlines across the screen.
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = WeatherColors.scanlineColor
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
