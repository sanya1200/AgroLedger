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
    case LivestockCategories.cattleMilk:
      return 'Молочный КРС';
    case LivestockCategories.cattleMeat:
      return 'Мясной КРС';
    case LivestockCategories.sheep:
      return 'Овцеводство';
    case LivestockCategories.goats:
      return 'Козоводство';
    case LivestockCategories.poultryLayers:
      return 'Птица (Яйцо)';
    case LivestockCategories.poultryBroilers:
      return 'Птица (Мясо)';
    case LivestockCategories.horses:
      return 'Коневодство';
    case LivestockCategories.pigs:
      return 'Свиноводство';
    case LivestockCategories.rabbits:
      return 'Кролиководство';
    case LivestockCategories.camels:
      return 'Верблюды';
    case LivestockCategories.bees:
      return 'Пчеловодство';
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
  static const String wool = 'wool';
  static const String honey = 'honey';
  static const String shubat = 'shubat';
  static const String kumys = 'kumys';

  static List<ProductTypeOption> forCategory(String? category) {
    switch (category) {
      case LivestockCategories.poultryLayers:
        return const [
          ProductTypeOption(value: eggs, label: 'Яйца', unit: 'шт.'),
          ProductTypeOption(value: liveAnimals, label: 'Молодняк', unit: 'голов'),
        ];
      case LivestockCategories.poultryBroilers:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Молодняк', unit: 'голов'),
        ];
      case LivestockCategories.cattleMilk:
        return const [
          ProductTypeOption(value: milk, label: 'Молоко', unit: 'л'),
          ProductTypeOption(value: liveAnimals, label: 'Телята', unit: 'голов'),
        ];
      case LivestockCategories.cattleMeat:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо (говядина)', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Живой вес', unit: 'кг'),
        ];
      case LivestockCategories.sheep:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо (баранина)', unit: 'кг'),
          ProductTypeOption(value: wool, label: 'Шерсть', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Ягнята/Живой вес', unit: 'голов'),
        ];
      case LivestockCategories.goats:
        return const [
          ProductTypeOption(value: milk, label: 'Молоко (козье)', unit: 'л'),
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Козлята', unit: 'голов'),
        ];
      case LivestockCategories.horses:
        return const [
          ProductTypeOption(value: kumys, label: 'Кумыс', unit: 'л'),
          ProductTypeOption(value: meat, label: 'Мясо (конина)', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Жеребята', unit: 'голов'),
        ];
      case LivestockCategories.camels:
        return const [
          ProductTypeOption(value: shubat, label: 'Шубат', unit: 'л'),
          ProductTypeOption(value: meat, label: 'Мясо (верблюжатина)', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Верблюжата', unit: 'голов'),
        ];
      case LivestockCategories.bees:
        return const [
          ProductTypeOption(value: honey, label: 'Мед', unit: 'кг'),
          ProductTypeOption(value: 'propolis', label: 'Прополис', unit: 'г'),
          ProductTypeOption(value: 'pollen', label: 'Пыльца', unit: 'г'),
        ];
      case LivestockCategories.pigs:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо (свинина)', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Поросята', unit: 'голов'),
        ];
      case LivestockCategories.rabbits:
        return const [
          ProductTypeOption(value: meat, label: 'Мясо кролика', unit: 'кг'),
          ProductTypeOption(value: 'fur', label: 'Шкурки', unit: 'шт.'),
        ];
      default:
        return const [
          ProductTypeOption(value: milk, label: 'Молоко', unit: 'л'),
          ProductTypeOption(value: eggs, label: 'Яйца', unit: 'шт.'),
          ProductTypeOption(value: meat, label: 'Мясо', unit: 'кг'),
          ProductTypeOption(value: liveAnimals, label: 'Живой вес', unit: 'кг'),
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
