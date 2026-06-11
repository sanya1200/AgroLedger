import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'dart:math' as math;

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.creamSurface,
          foregroundColor: AppColors.textDark,
          side: BorderSide(
            color: AppColors.sageLight.withValues(alpha: 0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.sagePrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogoWidget(size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Войти через Google',
                    style: AppTextStyles.bodyMax.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  const GoogleLogoWidget({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleGLogoPainter(),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = w / 2;
    final Offset center = Offset(w / 2, h / 2);
    final double strokeWidth = w * 0.26;
    final Rect rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red: top arc from 220 to 315 degrees
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 220 * math.pi / 180, 95 * math.pi / 180, false, paint);

    // Yellow: left arc from 140 to 220 degrees
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 140 * math.pi / 180, 80 * math.pi / 180, false, paint);

    // Green: bottom arc from 45 to 140 degrees
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 45 * math.pi / 180, 95 * math.pi / 180, false, paint);

    // Blue: right arc from -45 to 45 degrees
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -45 * math.pi / 180, 90 * math.pi / 180, false, paint);

    // Blue horizontal bar: from center of circle to right edge
    final Paint fillPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    final double barLeft = center.dx;
    final double barRight = center.dx + radius;
    final double barTop = center.dy - strokeWidth / 2;
    final double barBottom = center.dy + strokeWidth / 2;
    canvas.drawRect(Rect.fromLTRB(barLeft, barTop, barRight, barBottom), fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
