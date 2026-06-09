import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';

class ExpenseBreakdownSegment {
  final String label;
  final double amount;
  final double fraction;
  final Color color;

  const ExpenseBreakdownSegment({
    required this.label,
    required this.amount,
    required this.fraction,
    required this.color,
  });
}

class ExpensesBreakdownChart extends StatelessWidget {
  final CalculatorSummaryModel summary;

  const ExpensesBreakdownChart({
    super.key,
    required this.summary,
  });

  static const _feedColor = Color(0xFF2C3E31);
  static const _vetColor = Color(0xFF6B8F71);
  static const _utilityColor = Color(0xFFD4C9A8);
  static const _otherColor = Color(0xFFC9A227);

  List<ExpenseBreakdownSegment> _buildSegments() {
    final total = summary.operatingExpenses;
    if (total <= 0) return [];

    double fractionOf(double value) => value / total;

    return [
      ExpenseBreakdownSegment(
        label: 'Корма',
        amount: summary.feedCost,
        fraction: fractionOf(summary.feedCost),
        color: _feedColor,
      ),
      ExpenseBreakdownSegment(
        label: 'Ветеринария',
        amount: summary.vetCost,
        fraction: fractionOf(summary.vetCost),
        color: _vetColor,
      ),
      ExpenseBreakdownSegment(
        label: 'Коммуналка',
        amount: summary.utilityCost,
        fraction: fractionOf(summary.utilityCost),
        color: _utilityColor,
      ),
      ExpenseBreakdownSegment(
        label: 'Прочее',
        amount: summary.otherCost,
        fraction: fractionOf(summary.otherCost),
        color: _otherColor,
      ),
    ].where((segment) => segment.amount > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();
    final currencyFormat = NumberFormat('#,##0', 'ru_RU');

    if (segments.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 40,
              color: AppColors.sageLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Нет операционных расходов для визуализации',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Операционные расходы',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.sageDark,
                ),
              ),
              Text(
                '${currencyFormat.format(summary.operatingExpenses)} ₸',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.sagePrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StackedExpenseBar(segments: segments),
          const SizedBox(height: 20),
          ...segments.map(
            (segment) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ExpenseCategoryRow(
                segment: segment,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedExpenseBar extends StatelessWidget {
  final List<ExpenseBreakdownSegment> segments;

  const _StackedExpenseBar({required this.segments});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 18,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, animationValue, child) {
            return CustomPaint(
              size: const Size(double.infinity, 18),
              painter: _StackedBarPainter(
                segments: segments,
                animationValue: animationValue,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StackedBarPainter extends CustomPainter {
  final List<ExpenseBreakdownSegment> segments;
  final double animationValue;

  _StackedBarPainter({
    required this.segments,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final totalFraction =
        segments.fold<double>(0, (sum, segment) => sum + segment.fraction);

    for (final segment in segments) {
      final normalizedFraction =
          totalFraction > 0 ? segment.fraction / totalFraction : 0;
      final segmentWidth = size.width * normalizedFraction * animationValue;
      if (segmentWidth <= 0) continue;

      final paint = Paint()..color = segment.color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, 0, segmentWidth, size.height),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
      startX += segmentWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _StackedBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.segments != segments;
  }
}

class _ExpenseCategoryRow extends StatelessWidget {
  final ExpenseBreakdownSegment segment;
  final NumberFormat currencyFormat;

  const _ExpenseCategoryRow({
    required this.segment,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final percentLabel = (segment.fraction * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: segment.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                segment.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
              ),
            ),
            Text(
              '$percentLabel%',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.sageDark,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${currencyFormat.format(segment.amount)} ₸',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.sagePrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: segment.fraction),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, animatedFraction, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: animatedFraction.clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.sageLight.withValues(alpha: 0.12),
                color: segment.color,
              ),
            );
          },
        ),
      ],
    );
  }
}
