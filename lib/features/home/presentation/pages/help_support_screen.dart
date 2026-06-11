import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Example links - in a real app these should come from config
  static const String _supportEmail = 'support@agroledger.kz';
  static const String _supportTelegram = 'https://t.me/agroledger_support';
  static const String _privacyPolicyUrl = 'https://agroledger-zlxo.onrender.com/legal/privacy';
  static const String _termsOfServiceUrl = 'https://agroledger-zlxo.onrender.com/legal/terms';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'AgroLedger Support Request',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Поддержка и помощь'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Частые вопросы'),
            const SizedBox(height: 12),
            const _FaqItem(
              question: 'Как работает калькулятор?',
              answer: 'Калькулятор позволяет вести учет расходов на корма, ветеринарию и содержание животных, а также фиксировать доходы от реализации продукции для расчета чистой прибыли и ROI.',
            ),
            const _FaqItem(
              question: 'Как выставить товар на маркет?',
              answer: 'Перейдите во вкладку "Маркет", нажмите на кнопку "+" и заполните информацию о товаре: название, категория, цена и остаток на складе.',
            ),
            const _FaqItem(
              question: 'Мои данные защищены?',
              answer: 'Да, AgroLedger использует шифрование для защиты ваших данных. Мы никогда не передаем финансовую информацию третьим лицам без вашего согласия.',
            ),
            
            const SizedBox(height: 28),
            _buildSectionTitle('Связаться с нами'),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _SupportActionTile(
                    icon: Icons.telegram_rounded,
                    title: 'Написать в Telegram',
                    subtitle: '@agroledger_support',
                    color: Colors.blue[600]!,
                    onTap: () => _launchUrl(_supportTelegram),
                  ),
                  const Divider(height: 1),
                  _SupportActionTile(
                    icon: Icons.email_outlined,
                    title: 'Отправить Email',
                    subtitle: _supportEmail,
                    color: AppColors.sagePrimary,
                    onTap: _sendEmail,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            _buildSectionTitle('Юридическая информация'),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _LegalTile(
                    title: 'Политика конфиденциальности',
                    onTap: () => _launchUrl(_privacyPolicyUrl),
                  ),
                  const Divider(height: 1),
                  _LegalTile(
                    title: 'Пользовательское соглашение',
                    onTap: () => _launchUrl(_termsOfServiceUrl),
                  ),
                  const Divider(height: 1),
                  _LegalTile(
                    title: 'Правила торговли на платформе',
                    onTap: () => _launchUrl('https://agroledger-zlxo.onrender.com/legal/trade'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    'AgroLedger v2.0.0',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Сделано в Казахстане для фермеров',
                    style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textLight.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h2.copyWith(fontSize: 18, color: AppColors.sageDark),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          trailing: Icon(
            _isExpanded ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: _isExpanded ? AppColors.sagePrimary : AppColors.textLight,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Text(
                widget.answer,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark.withValues(alpha: 0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SupportActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}

class _LegalTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LegalTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}
