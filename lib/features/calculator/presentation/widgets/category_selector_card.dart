import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

class LivestockCategories {
  LivestockCategories._();

  static const String cattleMilk = 'cattle_milk';
  static const String cattleMeat = 'cattle_meat';
  static const String sheep = 'sheep';
  static const String goats = 'goats';
  static const String poultryBroilers = 'poultry_broilers';
  static const String poultryLayers = 'poultry_layers';
  static const String horses = 'horses';
  static const String pigs = 'pigs';
  static const String rabbits = 'rabbits';
  static const String camels = 'camels';
  static const String bees = 'bees';

  static const List<CategoryOption> options = [
    CategoryOption(
      value: cattleMilk,
      title: 'Молочный КРС',
      subtitle: 'Коровы, телки',
      icon: Icons.water_drop_outlined,
    ),
    CategoryOption(
      value: cattleMeat,
      title: 'Мясной КРС',
      subtitle: 'Бычки, нагул',
      icon: Icons.grass_outlined,
    ),
    CategoryOption(
      value: sheep,
      title: 'Овцеводство',
      subtitle: 'Бараны, ягнята',
      icon: Icons.pets_outlined,
    ),
    CategoryOption(
      value: goats,
      title: 'Козоводство',
      subtitle: 'Козы, козлята',
      icon: Icons.gesture_outlined,
    ),
    CategoryOption(
      value: poultryLayers,
      title: 'Птица (Яйцо)',
      subtitle: 'Куры-несушки',
      icon: Icons.egg_outlined,
    ),
    CategoryOption(
      value: poultryBroilers,
      title: 'Птица (Мясо)',
      subtitle: 'Бройлеры, индейки',
      icon: Icons.restaurant_menu_outlined,
    ),
    CategoryOption(
      value: horses,
      title: 'Коневодство',
      subtitle: 'Лошади, жеребята',
      icon: Icons.directions_run_outlined,
    ),
    CategoryOption(
      value: camels,
      title: 'Верблюды',
      subtitle: 'Шубат, мясо',
      icon: Icons.landscape_outlined,
    ),
    CategoryOption(
      value: pigs,
      title: 'Свиноводство',
      subtitle: 'Свиньи, поросята',
      icon: Icons.savings_outlined,
    ),
    CategoryOption(
      value: rabbits,
      title: 'Кролиководство',
      subtitle: 'Мясо, мех',
      icon: Icons.cruelty_free_outlined,
    ),
    CategoryOption(
      value: bees,
      title: 'Пчеловодство',
      subtitle: 'Мед, прополис',
      icon: Icons.hive_outlined,
    ),
  ];
}

class CategoryOption {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const CategoryOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class CategorySelectorCard extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategorySelectorCard({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          for (var i = 0; i < LivestockCategories.options.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: _CategoryTile(
                option: LivestockCategories.options[i],
                isSelected: selectedCategory == LivestockCategories.options[i].value,
                onTap: () {
                  final value = LivestockCategories.options[i].value;
                  if (selectedCategory == value) {
                    onCategorySelected(null);
                  } else {
                    onCategorySelected(value);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final CategoryOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final scale = _isPressed ? 1.03 : (isSelected ? 1.02 : 1.0);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sagePrimary.withValues(alpha: 0.08)
                : AppColors.creamSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.sagePrimary
                  : AppColors.sageLight.withValues(alpha: 0.25),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.sagePrimary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.sagePrimary.withValues(alpha: 0.12)
                      : AppColors.sageLight.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.option.icon,
                  size: 22,
                  color: isSelected ? AppColors.sagePrimary : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.option.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isSelected ? AppColors.sagePrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.option.subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9,
                  color: isSelected
                      ? AppColors.sagePrimary.withValues(alpha: 0.75)
                      : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
