import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/calculator/data/models/calculation_cycle_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';

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
        title: Text(isExpense ? 'Добавить расход' : 'Добавить доход'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: isExpense ? 'Описание' : 'Название продукта'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
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
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cycle.name)),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          if (state is CalculatorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsLoadSuccess) {
            final analytics = state.analytics;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAnalyticsCard(analytics),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: analytics.status == 'archived' ? null : () => _showAddTransactionDialog(context, true),
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('Расход'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: analytics.status == 'archived' ? null : () => _showAddTransactionDialog(context, false),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Доход'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[50], foregroundColor: Colors.green),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (analytics.status == 'active')
                    OutlinedButton(
                      onPressed: () {
                        context.read<CalculatorBloc>().add(CloseCycleRequested(widget.cycle.id));
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[700]),
                      child: const Text('Завершить и архивировать цикл'),
                    ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(dynamic analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Чистая прибыль', style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            '${analytics.netProfit.toStringAsFixed(0)} ₸',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Расходы', '${analytics.totalExpenses.toStringAsFixed(0)} ₸'),
              _buildStatItem('Доходы', '${analytics.totalIncomes.toStringAsFixed(0)} ₸'),
              _buildStatItem('ROI', '${analytics.roi}%', isRoi: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isRoi = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: isRoi ? Colors.orangeAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
