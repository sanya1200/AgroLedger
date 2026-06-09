import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/calculator/data/models/calculation_cycle_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:intl/intl.dart';

class CycleDetailScreen extends StatefulWidget {
  final CalculationCycleModel cycle;
  const CycleDetailScreen({super.key, required this.cycle});

  @override
  State<CycleDetailScreen> createState() => _CycleDetailScreenState();
}

class _CycleDetailScreenState extends State<CycleDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CalculatorBloc>().add(LoadAnalyticsRequested(widget.cycle.id));
  }

  void _showAddTransactionDialog(BuildContext context, bool isExpense) {
    final amountController = TextEditingController();
    final nameController = TextEditingController();
    String category = 'feed';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isExpense ? 'Расход' : 'Доход', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Сумма (₸)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: isExpense ? 'На что потрачено' : 'За что получено',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount > 0 && nameController.text.isNotEmpty) {
                if (isExpense) {
                  context.read<CalculatorBloc>().add(AddExpenseRequested(
                    widget.cycle.id, category, amount, nameController.text
                  ));
                } else {
                  context.read<CalculatorBloc>().add(AddIncomeRequested(
                    widget.cycle.id, nameController.text, 1.0, amount
                  ));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'kk_KZ', symbol: '₸', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(widget.cycle.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<CalculatorBloc>().add(LoadAnalyticsRequested(widget.cycle.id)),
          )
        ],
      ),
      body: BlocConsumer<CalculatorBloc, CalculatorState>(
        listener: (context, state) {
          if (state is CalculatorFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.errorSoft),
            );
          }
        },
        builder: (context, state) {
          if (state is CalculatorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsLoadSuccess) {
            final analytics = state.analytics;
            final isArchived = analytics.status == 'archived';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMainAnalytics(analytics, currencyFormat),
                  const SizedBox(height: 24),
                  
                  if (!isArchived)
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            onPressed: () => _showAddTransactionDialog(context, true),
                            icon: Icons.remove_circle_outline,
                            label: 'Расход',
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionButton(
                            onPressed: () => _showAddTransactionDialog(context, false),
                            icon: Icons.add_circle_outline,
                            label: 'Доход',
                            color: AppColors.sagePrimary,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 32),
                  _buildDetailsList(analytics, currencyFormat),
                  
                  const SizedBox(height: 48),
                  if (!isArchived)
                    OutlinedButton.icon(
                      onPressed: () => _showCloseConfirmation(context),
                      icon: const Icon(Icons.archive_outlined),
                      label: const Text('Завершить цикл'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textLight,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Не удалось загрузить данные'),
                TextButton(
                  onPressed: () => context.read<CalculatorBloc>().add(LoadAnalyticsRequested(widget.cycle.id)),
                  child: const Text('Повторить'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCloseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершение цикла'),
        content: const Text('Вы уверены, что хотите завершить и архивировать этот цикл? Данные станут доступны только для чтения.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              context.read<CalculatorBloc>().add(CloseCycleRequested(widget.cycle.id));
              Navigator.pop(context);
            },
            child: const Text('Завершить', style: TextStyle(color: AppColors.errorSoft)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAnalytics(dynamic analytics, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.sagePrimary, AppColors.sageDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.sagePrimary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Text('ЧИСТАЯ ПРИБЫЛЬ', style: AppTextStyles.caption.copyWith(color: Colors.white70, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            formatter.format(analytics.netProfit),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 28),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(analytics.totalExpenses, 'Расходы', formatter, Colors.white),
              Container(width: 1, height: 40, color: Colors.white12),
              _buildStat(analytics.totalIncomes, 'Доходы', formatter, Colors.white),
              Container(width: 1, height: 40, color: Colors.white12),
              _buildStat(analytics.roi, 'ROI', null, AppColors.accentGold, isPercentage: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(dynamic value, String label, NumberFormat? formatter, Color valColor, {bool isPercentage = false}) {
    String displayValue = isPercentage ? '${value.toStringAsFixed(1)}%' : formatter!.format(value);
    return Column(
      children: [
        Text(displayValue, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildDetailsList(dynamic analytics, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Детализация', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        SoftCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              _DetailRow(label: 'Животных', value: '50 шт', icon: Icons.pets_outlined),
              const Divider(height: 1),
              _DetailRow(label: 'Срок цикла', value: '45 дней', icon: Icons.timer_outlined),
              const Divider(height: 1),
              _DetailRow(
                label: 'Средний доход / ед', 
                value: formatter.format(analytics.totalIncomes / 50), 
                icon: Icons.trending_up_rounded
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
