import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_sign_in_button.dart';

class GoogleAccountPickerDialog extends StatefulWidget {
  const GoogleAccountPickerDialog({super.key});

  @override
  State<GoogleAccountPickerDialog> createState() => _GoogleAccountPickerDialogState();
}

class _GoogleAccountPickerDialogState extends State<GoogleAccountPickerDialog> {
  bool _isAddingCustom = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  final List<Map<String, String>> _accounts = [
    {
      'name': 'Алексей Иванов',
      'email': 'agro.farmer@gmail.com',
      'initials': 'АИ',
    },
    {
      'name': 'Екатерина Петрова',
      'email': 'buyer.agro@gmail.com',
      'initials': 'ЕП',
    },
    {
      'name': 'Новый Пользователь',
      'email': 'new.user@gmail.com',
      'initials': 'НП',
    },
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
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
      child: Container(
        width: 340,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: SingleChildScrollView(
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: _isAddingCustom
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildAccountList(context),
            secondChild: _buildCustomAccountForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const GoogleLogoWidget(size: 32),
        const SizedBox(height: 16),
        Text(
          'Выбор аккаунта',
          style: AppTextStyles.h2.copyWith(fontSize: 22, letterSpacing: -0.2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'для перехода в приложение AgroLedger',
          style: AppTextStyles.caption.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.sageLight.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ..._accounts.map((acc) => _buildAccountTile(context, acc)),
              const Divider(height: 1, thickness: 0.5),
              _buildAddAccountTile(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Чтобы продолжить, Google предоставит приложению AgroLedger ваше имя, адрес электронной почты и фото профиля.',
          style: AppTextStyles.caption.copyWith(fontSize: 11, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccountTile(BuildContext context, Map<String, String> acc) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(acc);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.sagePrimary.withValues(alpha: 0.1),
              child: Text(
                acc['initials']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.sagePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acc['name']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    acc['email']!,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountTile() {
    return InkWell(
      onTap: () {
        setState(() {
          _isAddingCustom = true;
        });
      },
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person_add_alt_1_outlined,
                color: AppColors.textDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Использовать другой аккаунт',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAccountForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
                onPressed: () {
                  setState(() {
                    _isAddingCustom = false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Добавить аккаунт',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Spacing to balance the back button
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Имя и Фамилия',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: AppColors.creamBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите имя' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Google',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.creamBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Введите email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                return 'Некорректный email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final email = _emailController.text.trim();
                final name = _nameController.text.trim();
                final initials = name.isNotEmpty
                    ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                    : 'G';
                Navigator.of(context).pop({
                  'name': name,
                  'email': email,
                  'initials': initials,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }
}
