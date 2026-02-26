import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Overlays CRT-style scanlines, phosphor dot pattern, screen curvature,
/// chromatic aberration, and vignette to simulate a low-res analog TV.
class TvFrame extends StatefulWidget {
  final Widget child;

  const TvFrame({super.key, required this.child});

  @override
  State<TvFrame> createState() => _TvFrameState();
}

class _TvFrameState extends State<TvFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _flicker;

  @override
  void initState() {
    super.initState();
    // Subtle brightness flicker to mimic CRT refresh
    _flicker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Main content with flicker
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _flicker,
              builder: (context, child) {
                return Opacity(opacity: _flicker.value, child: child);
              },
              child: widget.child,
            ),
          ),

          // Scanline overlay (denser lines for more CRT effect)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScanlinePainter()),
            ),
          ),

          // Phosphor dot / RGB pixel grid
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PixelGridPainter()),
            ),
          ),

          // Heavy vignette — dark corners like a curved CRT
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.55, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Inner screen glow (very faint blue)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      WeatherColors.borderGlow.withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Rounded bezel border
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF333333), width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Inner edge highlight
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: WeatherColors.borderGlow.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints dense horizontal scanlines — every other pixel row is darkened.
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    // Draw scanlines every 2 pixels for a tight CRT look.
    for (double y = 0; y < size.height; y += 2) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints a faint RGB sub-pixel grid to emulate phosphor dots.
class _PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    // Vertical lines every 3 pixels (mimics R-G-B phosphor columns)
    for (double x = 0; x < size.width; x += 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
