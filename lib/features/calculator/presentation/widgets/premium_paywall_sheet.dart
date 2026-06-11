import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';

class PremiumPaywallSheet extends StatelessWidget {
  final String title;
  final String message;

  const PremiumPaywallSheet({
    super.key,
    required this.title,
    required this.message,
  });

  static Future<void> show(BuildContext context, {required String title, required String message}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PremiumPaywallSheet(title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.sageDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -10)),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const _PremiumHeader(),
                    const SizedBox(height: 32),
                    Text(title, style: AppTextStyles.h1.copyWith(color: Colors.white, fontSize: 26)),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 40),
                    const _ValueCard(
                      icon: Icons.auto_graph_rounded,
                      title: 'Умный ИИ-Прогноз',
                      description: 'Автоматический расчет конверсии корма и даты идеального убоя.',
                    ),
                    const SizedBox(height: 16),
                    const _ValueCard(
                      icon: Icons.all_inclusive_rounded,
                      title: 'Безлимитное хозяйство',
                      description: 'Ведение неограниченного количества групп учета одновременно.',
                    ),
                    const SizedBox(height: 16),
                    const _ValueCard(
                      icon: Icons.description_rounded,
                      title: 'Отчеты для субсидий',
                      description: 'Экспорт PDF/Excel документов с печатью для банков и МинСельхоза.',
                    ),
                    const SizedBox(height: 48),
                    _ActionButton(onTap: () {
                      Navigator.pop(context);
                      context.read<CalculatorBloc>().add(ActivatePremiumDebugEvent());
                      context.read<AuthBloc>().add(AuthCheckStatusRequested());
                    }),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Оставить как есть', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.accentGold.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
            ],
          ),
        ),
        const Icon(Icons.stars_rounded, size: 80, color: AppColors.accentGold),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValueCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.accentGold, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ActionButton({required this.onTap});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: ElevatedButton(
        onPressed: widget.onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.sageDark,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: AppColors.accentGold.withValues(alpha: 0.4),
        ),
        child: const Text('Активировать AgroLedger Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
