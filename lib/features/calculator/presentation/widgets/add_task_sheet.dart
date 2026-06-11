import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';
import 'package:agroledger/features/calculator/data/models/livestock_task_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_event.dart';

class AddTaskSheet extends StatefulWidget {
  final List<LivestockAssetModel> assets;
  final int? preselectedAssetId;

  const AddTaskSheet({
    super.key,
    required this.assets,
    this.preselectedAssetId,
  });

  static void show(
    BuildContext context, {
    required List<LivestockAssetModel> assets,
    int? preselectedAssetId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTaskSheet(
        assets: assets,
        preselectedAssetId: preselectedAssetId,
      ),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedAssetId;
  String _title = '';
  String? _description;
  DateTime _plannedDate = DateTime.now().add(const Duration(days: 1));
  TaskType _selectedType = TaskType.vaccination;

  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    if (widget.assets.isNotEmpty) {
      if (widget.preselectedAssetId != null &&
          widget.assets.any((a) => a.id == widget.preselectedAssetId)) {
        _selectedAssetId = widget.preselectedAssetId;
      } else {
        _selectedAssetId = widget.assets.first.id;
      }
    }
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _plannedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.sagePrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_plannedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.sagePrimary,
                onPrimary: Colors.white,
                onSurface: AppColors.textDark,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _plannedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _taskTypeLabel(TaskType type) {
    switch (type) {
      case TaskType.vaccination:
        return 'Вакцинация / Лечение';
      case TaskType.vetCheck:
        return 'Осмотр ветеринара';
      case TaskType.breeding:
        return 'Случка / Осеменение';
      case TaskType.feeding:
        return 'Кормление / Рацион';
      case TaskType.general:
        return 'Другие работы';
      default:
        return 'Общее';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedAssetId != null) {
      _formKey.currentState!.save();

      final task = LivestockTaskModel(
        assetId: _selectedAssetId!,
        title: _title.trim(),
        description: _description?.trim(),
        plannedDate: _plannedDate,
        isCompleted: false,
        taskType: _selectedType,
      );

      context.read<CalendarBloc>().add(CreateCalendarTaskEvent(task));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.creamBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, mediaQuery.viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Новая задача календаря', style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // Asset Selector
              DropdownButtonFormField<int>(
                initialValue: _selectedAssetId,
                decoration: const InputDecoration(labelText: 'Группа животных'),
                items: widget.assets.map((a) {
                  return DropdownMenuItem<int>(
                    value: a.id,
                    child: Text('${a.breed} (${a.quantity} гол.)'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedAssetId = val),
                validator: (val) => val == null ? 'Выберите группу' : null,
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Название задачи',
                  hintText: 'например: Прививка от ящура',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (val) => val == null || val.trim().isEmpty ? 'Введите название' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Описание / Заметки',
                  hintText: 'Дополнительные сведения',
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                onSaved: (val) => _description = val,
              ),
              const SizedBox(height: 16),

              // Task Type
              DropdownButtonFormField<TaskType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Тип задачи'),
                items: TaskType.values
                    .where((t) => t != TaskType.unknown)
                    .map((t) {
                  return DropdownMenuItem<TaskType>(
                    value: t,
                    child: Text(_taskTypeLabel(t)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedType = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Planned Date Picker
              InkWell(
                onTap: _selectDateTime,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.sageLight.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.sagePrimary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Дата и время проведения',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _dateFormat.format(_plannedDate),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Запланировать задачу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
