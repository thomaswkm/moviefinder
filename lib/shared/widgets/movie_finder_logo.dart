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

    canvas.drawCircle(Offset(w * 0.13, h * 0.16), w * 0.1, paint);

    final iBody = Path()
      ..moveTo(w * 0.03, h * 0.42)
      ..lineTo(w * 0.23, h * 0.30)
      ..lineTo(w * 0.23, h * 0.78)
      ..lineTo(w * 0.03, h * 0.92)
      ..close();
    canvas.drawPath(iBody, paint);

    final leftStem = Path()
      ..moveTo(w * 0.28, h * 0.22)
      ..lineTo(w * 0.46, h * 0.22)
      ..lineTo(w * 0.56, h * 0.56)
      ..lineTo(w * 0.47, h * 0.74)
      ..lineTo(w * 0.38, h * 0.43)
      ..lineTo(w * 0.38, h * 0.90)
      ..lineTo(w * 0.28, h * 0.90)
      ..close();
    canvas.drawPath(leftStem, paint);

    final middle = Path()
      ..moveTo(w * 0.46, h * 0.22)
      ..lineTo(w * 0.66, h * 0.22)
      ..lineTo(w * 0.53, h * 0.78)
      ..lineTo(w * 0.47, h * 0.74)
      ..lineTo(w * 0.56, h * 0.56)
      ..close();
    canvas.drawPath(middle, paint);

    final rightStem = Path()
      ..moveTo(w * 0.66, h * 0.22)
      ..lineTo(w * 0.97, h * 0.22)
      ..lineTo(w * 0.97, h * 0.90)
      ..lineTo(w * 0.78, h * 0.90)
      ..lineTo(w * 0.78, h * 0.44)
      ..lineTo(w * 0.53, h * 0.78)
      ..close();
    canvas.drawPath(rightStem, paint);
  }

  @override
  bool shouldRepaint(MovieFinderLogoPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
