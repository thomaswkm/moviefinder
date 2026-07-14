import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class MovieFinderLogo extends StatelessWidget {
  const MovieFinderLogo({
    super.key,
    this.size = 260,
    this.color = AppColors.primary,
    this.opacity = 1,
    this.showLabel = false,
    this.labelColor,
  });

  final double size;
  final Color color;
  final double opacity;
  final bool showLabel;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color.withValues(alpha: opacity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: MovieFinderLogoPainter(color: effectiveColor),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: size * 0.04),
          Text(
            'MovieApp',
            style: TextStyle(
              color: labelColor ?? AppColors.primary,
              fontSize: size * 0.13,
              letterSpacing: 2,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

class MovieFinderLogoPainter extends CustomPainter {
  const MovieFinderLogoPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Dot of the "i"
    canvas.drawCircle(Offset(w * 0.126, h * 0.1843), w * 0.096, paint);

    // Slanted body of the "i" (parallelogram with a pointed top-right
    // and a pointed bottom-left, like an italic dash)
    final iBody = Path()
      ..moveTo(w * 0.2167, h * 0.3129)
      ..lineTo(w * 0.2167, h * 0.7711)
      ..lineTo(w * 0.0378, h * 0.9121)
      ..lineTo(w * 0.0378, h * 0.4160)
      ..close();
    canvas.drawPath(iBody, paint);

    // Left leg of the "M": flat top, straight outer edge, and an inner
    // edge that angles inward to meet the opposite leg at the peak.
    final leftStem = Path()
      ..moveTo(w * 0.2715, h * 0.2254)
      ..lineTo(w * 0.4321, h * 0.2254)
      ..lineTo(w * 0.6214, h * 0.5335)
      ..lineTo(w * 0.4321, h * 0.5335)
      ..lineTo(w * 0.4321, h * 0.8847)
      ..lineTo(w * 0.2715, h * 0.8847)
      ..close();
    canvas.drawPath(leftStem, paint);

    // Right leg of the "M", mirrored from the left leg.
    final rightStem = Path()
      ..moveTo(w * 0.9700, h * 0.2254)
      ..lineTo(w * 0.8094, h * 0.2254)
      ..lineTo(w * 0.6214, h * 0.5335)
      ..lineTo(w * 0.8094, h * 0.5335)
      ..lineTo(w * 0.8094, h * 0.8847)
      ..lineTo(w * 0.9700, h * 0.8847)
      ..close();
    canvas.drawPath(rightStem, paint);

    // The wedge that hangs from the peak down into the valley of the "M".
    final middleWedge = Path()
      ..moveTo(w * 0.4321, h * 0.5335)
      ..lineTo(w * 0.8094, h * 0.5335)
      ..lineTo(w * 0.6214, h * 0.8455)
      ..close();
    canvas.drawPath(middleWedge, paint);
  }

  @override
  bool shouldRepaint(MovieFinderLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}