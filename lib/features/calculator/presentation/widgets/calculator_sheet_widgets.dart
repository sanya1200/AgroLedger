import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/presentation/widgets/category_selector_card.dart';

class CalculatorSheetHandle extends StatelessWidget {
  const CalculatorSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.sageLight.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

String assetCategoryLabel(String category) {
  switch (category) {
    case LivestockCategories.cattleKrs:
      return 'КРС';
    case LivestockCategories.sheepMrs:
      return 'МРС';
    case LivestockCategories.poultryBirds:
      return 'Птица';
    default:
      return category;
  }
}

String assetDropdownLabel(LivestockAssetModel asset) {
  return '${asset.breed} (${assetCategoryLabel(asset.category)})';
}

class AssetDropdownField extends StatelessWidget {
  final List<LivestockAssetModel> assets;
  final int? selectedAssetId;
  final ValueChanged<int?>? onChanged;
  final String? errorText;

  const AssetDropdownField({
    super.key,
    required this.assets,
    required this.selectedAssetId,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Группа поголовья',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.sageDark,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          key: ValueKey('asset_dropdown_$selectedAssetId'),
          initialValue: selectedAssetId,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.creamSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.errorSoft
                    : AppColors.sageLight.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.sagePrimary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.errorSoft),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.errorSoft,
                width: 1.5,
              ),
            ),
            errorText: errorText,
            prefixIcon: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.sagePrimary,
            ),
          ),
          hint: Text(
            'Выберите группу',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
          ),
          borderRadius: BorderRadius.circular(20),
          items: assets
              .where((asset) => asset.id != null)
              .map(
                (asset) => DropdownMenuItem<int>(
                  value: asset.id,
                  child: Text(
                    assetDropdownLabel(asset),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

double? parseFormDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

String? validateOptionalDouble(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = parseFormDouble(value);
  if (parsed == null) return 'Введите корректное число';
  if (parsed < 0) return 'Значение не может быть отрицательным';
  return null;
}

String? validateRequiredDouble(String? value) {
  if (value == null || value.trim().isEmpty) return 'Введите значение';
  return validateOptionalDouble(value);
}

class ProductTypes {
  ProductTypes._();

  static const String milk = 'milk';
  static const String eggs = 'eggs';
  static const String meat = 'meat';
  static const String liveAnimals = 'live_animals';

  static List<ProductTypeOption> forCategory(String? category) {
    switch (category) {
      case LivestockCategories.poultryBirds:
        return const [
          ProductTypeOption(value: eggs, label: 'Яйца', unit: 'шт.'),
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
        ];
      case LivestockCategories.cattleKrs:
        return const [
          ProductTypeOption(value: milk, label: 'Молоко', unit: 'л'),
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(
            value: liveAnimals,
            label: 'Живой вес / молодняк',
            unit: 'голов',
          ),
        ];
      case LivestockCategories.sheepMrs:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(
            value: liveAnimals,
            label: 'Живой вес / молодняк',
            unit: 'голов',
          ),
        ];
      default:
        return const [
          ProductTypeOption(value: milk, label: 'Молоко', unit: 'л'),
          ProductTypeOption(value: eggs, label: 'Яйца', unit: 'шт.'),
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(
            value: liveAnimals,
            label: 'Живой вес / молодняк',
            unit: 'голов',
          ),
        ];
    }
  }

  static String labelFor(String value) {
    for (final option in forCategory(null)) {
      if (option.value == value) return option.label;
    }
    return value;
  }
}

class ProductTypeOption {
  final String value;
  final String label;
  final String unit;

  const ProductTypeOption({
    required this.value,
    required this.label,
    required this.unit,
  });
}
