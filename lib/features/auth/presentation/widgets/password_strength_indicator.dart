import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  bool get _hasMinLength => password.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(password);
  bool get _hasDigit => RegExp(r'\d').hasMatch(password);

  int get _strengthScore {
    if (password.isEmpty) return 0;
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasDigit) score++;
    return score;
  }

  String get _strengthText {
    switch (_strengthScore) {
      case 0:
        return 'Пусто';
      case 1:
        return 'Слабый пароль';
      case 2:
        return 'Средняя сложность';
      case 3:
        return 'Надежный пароль';
      default:
        return 'Пусто';
    }
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0:
        return AppColors.sageLight.withValues(alpha: 0.3);
      case 1:
        return AppColors.errorSoft;
      case 2:
        return Colors.amber;
      case 3:
        return AppColors.sagePrimary;
      default:
        return AppColors.sageLight.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: password.isEmpty ? 0.0 : _strengthScore / 3.0,
                  backgroundColor: AppColors.sageLight.withValues(alpha: 0.1),
                  color: _strengthColor,
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _strengthText,
              style: AppTextStyles.caption.copyWith(
                color: _strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRequirementRow('Минимум 8 символов', _hasMinLength),
        _buildRequirementRow('Минимум одна заглавная буква (A-Z)', _hasUppercase),
        _buildRequirementRow('Минимум одна цифра (0-9)', _hasDigit),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isMet ? AppColors.sagePrimary.withValues(alpha: 0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isMet ? AppColors.sagePrimary : AppColors.sageLight.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTextStyles.caption.copyWith(
                color: isMet ? AppColors.textDark : AppColors.textLight.withValues(alpha: 0.6),
                fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
