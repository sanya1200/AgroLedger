import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Мой профиль'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Profile Card
                SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.sagePrimary.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 60, color: AppColors.sagePrimary),
                      ),
                      const SizedBox(height: 16),
                      Text(user.fullName ?? 'Анонимный пользователь', style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sagePrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role == 'farmer_business' ? 'Фермер' : 'Покупатель',
                          style: AppTextStyles.caption.copyWith(color: AppColors.sagePrimary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Contact Info
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.email_outlined,
                        title: 'Email',
                        subtitle: user.email,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Телефон',
                        subtitle: user.phone,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.calendar_today_outlined,
                        title: 'Дата регистрации',
                        subtitle: '${user.createdAt.day}.${user.createdAt.month}.${user.createdAt.year}',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Security Info
                SoftCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.fingerprint,
                        title: 'Биометрия',
                        subtitle: user.isBiometricEnabled ? 'Включена' : 'Выключена',
                        trailing: Switch(
                          value: user.isBiometricEnabled,
                          onChanged: (val) {
                            // TODO: Implement toggle biometric
                          },
                          activeColor: AppColors.sagePrimary,
                        ),
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Статус верификации',
                        subtitle: user.isVerified ? 'Верифицирован' : 'Требуется подтверждение',
                        trailing: Icon(
                          user.isVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: user.isVerified ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorSoft,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Выйти из системы'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.errorSoft)),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.sageDark, size: 20),
      ),
      title: Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textLight)),
      subtitle: Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      trailing: trailing,
    );
  }
}
