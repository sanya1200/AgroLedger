import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

class GoogleRegistrationCompletionDialog extends StatefulWidget {
  final String email;
  const GoogleRegistrationCompletionDialog({super.key, required this.email});

  @override
  State<GoogleRegistrationCompletionDialog> createState() =>
      _GoogleRegistrationCompletionDialogState();
}

class _GoogleRegistrationCompletionDialogState
    extends State<GoogleRegistrationCompletionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedRole = 'farmer_business'; // Default role

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.creamSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sagePrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 48,
                    color: AppColors.sagePrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Завершение регистрации',
                  style: AppTextStyles.h2.copyWith(fontSize: 20, letterSpacing: -0.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Укажите роль и телефон для аккаунта\n${widget.email}',
                  style: AppTextStyles.caption.copyWith(fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Role selection chips
                Text(
                  'Кто вы?',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleChip(
                        label: 'Фермер',
                        roleValue: 'farmer_business',
                        icon: Icons.agriculture_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleChip(
                        label: 'Покупатель',
                        roleValue: 'customer_buyer',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Номер телефона',
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    hintText: '+7 (999) 999-99-99',
                    filled: true,
                    fillColor: AppColors.creamBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Введите телефон';
                    }
                    // Simple check for phone length
                    if (v.replaceAll(RegExp(r'\D'), '').length < 10) {
                      return 'Неверный номер телефона';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(
                            color: AppColors.sageLight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'phone': _phoneController.text.trim(),
                              'role': _selectedRole,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Готово'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required String roleValue,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == roleValue;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sagePrimary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.sagePrimary : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.sagePrimary : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
