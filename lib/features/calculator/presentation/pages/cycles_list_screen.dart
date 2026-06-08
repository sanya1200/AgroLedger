import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';
import 'package:agroledger/features/calculator/presentation/pages/cycle_detail_screen.dart';

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
        title: const Text('Новый цикл'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Название (напр. Партия №5)'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: 'poultry', child: Text('Птица')),
                DropdownMenuItem(value: 'cattle', child: Text('КРС')),
                DropdownMenuItem(value: 'livestock', child: Text('Мелкий скот')),
              ],
              onChanged: (val) => selectedType = val!,
              decoration: const InputDecoration(labelText: 'Тип'),
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
      appBar: AppBar(title: const Text('Мои Хозяйства')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCycleDialog(context),
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<CalculatorBloc, CalculatorState>(
        builder: (context, state) {
          if (state is CalculatorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CyclesLoadSuccess) {
            if (state.cycles.isEmpty) {
              return const Center(child: Text('У вас еще нет активных циклов'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cycles.length,
              itemBuilder: (context, index) {
                final cycle = state.cycles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Icon(Icons.analytics_outlined, color: Colors.green[800]),
                    ),
                    title: Text(cycle.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      'Тип: ${cycle.animalType} • С: ${DateFormat('dd.MM.yyyy').format(cycle.createdAt)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CycleDetailScreen(cycle: cycle)),
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
}
