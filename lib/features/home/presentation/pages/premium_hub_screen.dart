import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';

class PremiumHubScreen extends StatefulWidget {
  const PremiumHubScreen({super.key});

  @override
  State<PremiumHubScreen> createState() => _PremiumHubScreenState();
}

class _PremiumHubScreenState extends State<PremiumHubScreen> {
  int _selectedTariffIndex = 0;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _tariffs = [
    {
      'name': '1 Месяц',
      'price': '2 500 ₸',
      'subprice': '2 500 ₸ / месяц',
      'badge': null,
    },
    {
      'name': '1 Год',
      'price': '18 000 ₸',
      'subprice': '1 500 ₸ / месяц',
      'badge': 'Скидка 40%',
    },
  ];

  void _simulatePayment() {
    setState(() => _isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: AppColors.creamBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text(
                'Оплата подписки',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(color: AppColors.sagePrimary),
                  const SizedBox(height: 24),
                  Text(
                    'Соединение с банком...',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сумма к оплате: ${_tariffs[_selectedTariffIndex]['price']}',
                    style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // Simulate payment transaction
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pop(context); // Close bank connection dialog

      // Show success screen dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.creamBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Оплата прошла успешно!', style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Статус AgroLedger Premium успешно активирован на 30 дней. Все функции разблокированы!',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  // Trigger premium activation events
                  context.read<CalculatorBloc>().add(ActivatePremiumDebugEvent());
                  context.read<AuthBloc>().add(AuthCheckStatusRequested());
                  Navigator.pop(context); // Return to Profile Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sagePrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Начать работу'),
              ),
            ],
          ),
        ),
      );

      setState(() => _isProcessing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isPremium = authState.user?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.sageDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AgroLedger Premium', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Emblem header
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.stars_rounded, size: 72, color: AppColors.accentGold),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Разблокируйте весь потенциал',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Профессиональные инструменты учета для вашего хозяйства',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Benefits list
              _buildBenefitRow(
                icon: Icons.all_inclusive_rounded,
                title: 'Безлимитные группы учета',
                description: 'Снимите ограничение бесплатной версии (до 5 групп) и ведите учет неограниченно.',
              ),
              const SizedBox(height: 16),
              _buildBenefitRow(
                icon: Icons.psychology_rounded,
                title: 'ИИ-Ветеринар & Корма',
                description: 'Задавайте ИИ-консультанту неограниченные вопросы по уходу за животными.',
              ),
              const SizedBox(height: 16),
              _buildBenefitRow(
                icon: Icons.auto_graph_rounded,
                title: 'Предиктивная аналитика',
                description: 'Узнавайте точные прогнозы окупаемости и коэффициента конверсии корма (FCR).',
              ),
              const SizedBox(height: 16),
              _buildBenefitRow(
                icon: Icons.picture_as_pdf_rounded,
                title: 'PDF-Отчеты с графиками',
                description: 'Экспортируйте детальные финансовые отчеты хозяйства для банков и субсидий.',
              ),
              
              const SizedBox(height: 40),

              if (isPremium) ...[
                // Already Premium Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.accentGold, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.accentGold, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'Ваша подписка активна',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Спасибо, что используете AgroLedger Premium!',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Tariff selection
                // In Development Warning
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.errorSoft.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.errorSoft),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Модуль подписок находится в разработке. Оплата в данный момент происходит в тестовом режиме.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tariff selection
                Text(
                  'Выберите подходящий тариф:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(_tariffs.length, (index) {
                    final tariff = _tariffs[index];
                    final isSelected = _selectedTariffIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTariffIndex = index),
                        child: Container(
                          margin: EdgeInsets.only(
                            left: index == 0 ? 0 : 8,
                            right: index == _tariffs.length - 1 ? 0 : 8,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.accentGold.withValues(alpha: 0.1) 
                                : Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.accentGold : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tariff['name'],
                                    style: TextStyle(
                                      color: isSelected ? AppColors.accentGold : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    tariff['price'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tariff['subprice'],
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (tariff['badge'] != null)
                                Positioned(
                                  top: -30,
                                  right: -10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tariff['badge'],
                                      style: const TextStyle(
                                        color: AppColors.sageDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 36),

                // Order Action Button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _simulatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.sageDark,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    'Активировать за ${_tariffs[_selectedTariffIndex]['price']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white12),
          ),
          child: Icon(icon, color: AppColors.accentGold, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
