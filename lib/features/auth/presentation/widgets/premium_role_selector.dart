import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

class PremiumRoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleSelected;

  const PremiumRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите вашу роль:',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.sageDark),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _RoleItem(
                title: 'Фермер',
                description: 'Управление хозяйством',
                icon: Icons.agriculture_outlined,
                roleValue: 'farmer_business',
                isSelected: selectedRole == 'farmer_business',
                onTap: () => onRoleSelected('farmer_business'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleItem(
                title: 'Покупатель',
                description: 'Поиск продукции',
                icon: Icons.shopping_basket_outlined,
                roleValue: 'customer_buyer',
                isSelected: selectedRole == 'customer_buyer',
                onTap: () => onRoleSelected('customer_buyer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String roleValue;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.roleValue,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.sagePrimary.withOpacity(0.05) : AppColors.creamSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withOpacity(0.2),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColors.sagePrimary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.sagePrimary : AppColors.textLight,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.bodyMax.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.sagePrimary : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.sagePrimary.withOpacity(0.7) : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
