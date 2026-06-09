import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
import 'package:agroledger/features/calculator/presentation/pages/cycle_detail_screen.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class CyclesListScreen extends StatefulWidget {
  const CyclesListScreen({super.key});

  @override
  State<CyclesListScreen> createState() => _CyclesListScreenState();
}

class _CyclesListScreenState extends State<CyclesListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CalculatorBloc>().add(LoadCyclesRequested());
  }

  void _showCreateCycleDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = 'poultry';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Новый производственный цикл', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название (напр. Партия №5)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'poultry', child: Text('Птица')),
                DropdownMenuItem(value: 'cattle', child: Text('КРС')),
                DropdownMenuItem(value: 'livestock', child: Text('МРС (Овцы, Козы)')),
              ],
              onChanged: (val) => selectedType = val!,
              decoration: const InputDecoration(
                labelText: 'Тип животных',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<CalculatorBloc>().add(
                  CreateCycleRequested(nameController.text, selectedType)
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('Учет хозяйства'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCycleDialog(context),
        backgroundColor: AppColors.sagePrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Новый цикл', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          if (state is CalculatorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CyclesLoadSuccess) {
            if (state.cycles.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: state.cycles.length,
              itemBuilder: (context, index) {
                final cycle = state.cycles[index];
                final isActive = cycle.status == 'active';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SoftCard(
                    padding: const EdgeInsets.all(0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.sagePrimary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isActive ? Icons.loop_rounded : Icons.check_circle_outline_rounded,
                          color: isActive ? AppColors.sagePrimary : Colors.grey,
                        ),
                      ),
                      title: Text(cycle.name, style: AppTextStyles.bodyMax.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${_getAnimalTypeName(cycle.animalType)} • ${DateFormat('dd.MM.yyyy').format(cycle.createdAt)}',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CycleDetailScreen(cycle: cycle)),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is CalculatorFailure) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _getAnimalTypeName(String type) {
    switch (type) {
      case 'poultry': return 'Птица';
      case 'cattle': return 'КРС';
      case 'livestock': return 'МРС';
      default: return 'Животные';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: AppColors.sagePrimary.withOpacity(0.2)),
          const SizedBox(height: 24),
          Text('Нет активных циклов', style: AppTextStyles.h2.copyWith(color: AppColors.textLight)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Начните новый цикл производства, чтобы отслеживать расходы и доходы.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            ),
          ),
        ],
      ),
    );
  }
}
