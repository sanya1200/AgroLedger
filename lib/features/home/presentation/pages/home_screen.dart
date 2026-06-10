import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToCalculator;
  final VoidCallback? onNavigateToMarket;
  final VoidCallback? onNavigateToHelp;

  const HomeScreen({
    super.key,
    this.onNavigateToCalculator,
    this.onNavigateToMarket,
    this.onNavigateToHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('AgroLedger'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Добро пожаловать!', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('Ваше цифровое сельское хозяйство', 
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
            const SizedBox(height: 28),
            
            // News/Updates Section
            Text('Новости и советы', style: AppTextStyles.h2.copyWith(fontSize: 20)),
            const SizedBox(height: 14),
            _buildNewsItem(
              'Как повысить удойность',
              'Советы по кормлению КРС в весенний период для достижения лучших результатов.',
              Icons.tips_and_updates_outlined,
              'https://agroledger.kz/tips/1',
            ),
            const SizedBox(height: 12),
            _buildNewsItem(
              'Цены на рынке',
              'Обзор цен на мясо и молоко в вашем регионе за прошедшую неделю.',
              Icons.trending_up_rounded,
              'https://agroledger.kz/market-trends',
            ),
            
            const SizedBox(height: 28),
            
            // Features Section
            Text('Быстрый доступ', style: AppTextStyles.h2.copyWith(fontSize: 20)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildQuickAction(
                  'Калькулятор',
                  'Учет расходов',
                  Icons.calculate_outlined,
                  AppColors.sagePrimary,
                  onNavigateToCalculator,
                ),
                _buildQuickAction(
                  'Маркетплейс',
                  'Купля-продажа',
                  Icons.shopping_bag_outlined,
                  AppColors.accentGold,
                  onNavigateToMarket,
                ),
                _buildQuickAction(
                  'Мои заказы',
                  'История сделок',
                  Icons.assignment_outlined,
                  AppColors.sageDark,
                  () {},
                ),
                _buildQuickAction(
                  'Помощь',
                  'Служба поддержки',
                  Icons.help_outline_rounded,
                  AppColors.errorSoft,
                  onNavigateToHelp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(String title, String subtitle, IconData icon, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.sagePrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.sagePrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, String description, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(description, 
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}
