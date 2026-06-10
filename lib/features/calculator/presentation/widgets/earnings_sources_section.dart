import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';

class EarningsSourcesSection extends StatelessWidget {
  final Map<String, double> earningsByProduct;

  const EarningsSourcesSection({
    super.key,
    required this.earningsByProduct,
  });

  @override
  Widget build(BuildContext context) {
    final entries = earningsByProduct.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(
              Icons.savings_outlined,
              color: AppColors.sageLight.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Доходы от продукции пока не зафиксированы',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat('#,##0', 'ru_RU');

    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Источники доходов',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.sageDark,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: entries.map((entry) {
              final subType = ProductSubType.fromString(entry.key);
              return _EarningsTag(
                label: _productLabel(subType),
                icon: _productIcon(subType),
                amount: '${currencyFormat.format(entry.value)} ₸',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _productLabel(ProductSubType type) {
    switch (type) {
      case ProductSubType.milk: return 'Молоко';
      case ProductSubType.eggsCommercial: return 'Яйцо тов.';
      case ProductSubType.eggsIncubation: return 'Яйцо инк.';
      case ProductSubType.meatCarcass: return 'Мясо';
      case ProductSubType.kumys: return 'Кумыс';
      case ProductSubType.shubat: return 'Шубат';
      case ProductSubType.honey: return 'Мед';
      case ProductSubType.wool: return 'Шерсть';
      case ProductSubType.liveWeight: return 'Живой вес';
      case ProductSubType.youngStock: return 'Молодняк';
      default: return 'Прочее';
    }
  }

  IconData _productIcon(ProductSubType type) {
    switch (type) {
      case ProductSubType.milk:
      case ProductSubType.shubat:
      case ProductSubType.kumys:
        return Icons.water_drop_outlined;
      case ProductSubType.eggsCommercial:
      case ProductSubType.eggsIncubation:
        return Icons.egg_outlined;
      case ProductSubType.meatCarcass:
        return Icons.restaurant_menu_rounded;
      case ProductSubType.honey:
        return Icons.hive_outlined;
      case ProductSubType.youngStock:
      case ProductSubType.liveWeight:
        return Icons.pets_outlined;
      default:
        return Icons.payments_outlined;
    }
  }
}

class _EarningsTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final String amount;

  const _EarningsTag({
    required this.label,
    required this.icon,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.accentGold),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.sageDark,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amount,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.sagePrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
