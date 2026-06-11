import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_enums.dart';
import 'package:agroledger/features/calculator/data/models/livestock_task_model.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_bloc.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calendar_state.dart';
import 'add_task_sheet.dart';

class VetTasksWidget extends StatelessWidget {
  final List<LivestockAssetModel> assets;
  final int? selectedAssetId;

  const VetTasksWidget({
    super.key,
    required this.assets,
    this.selectedAssetId,
  });

  IconData _taskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.vaccination:
        return Icons.vaccines_rounded;
      case TaskType.vetCheck:
        return Icons.medical_services_outlined;
      case TaskType.breeding:
        return Icons.favorite_border_rounded;
      case TaskType.feeding:
        return Icons.grain_rounded;
      case TaskType.general:
      default:
        return Icons.assignment_outlined;
    }
  }

  Color _taskTypeColor(TaskType type) {
    switch (type) {
      case TaskType.vaccination:
        return AppColors.errorSoft;
      case TaskType.vetCheck:
        return AppColors.sagePrimary;
      case TaskType.breeding:
        return Colors.pink;
      case TaskType.feeding:
        return AppColors.accentGold;
      case TaskType.general:
      default:
        return AppColors.sageDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.sagePrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        } else if (state is CalendarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorSoft,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      },
      builder: (context, state) {
        List<LivestockTaskModel> tasks = [];
        bool isLoading = state is CalendarLoading;

        if (state is CalendarTasksLoaded) {
          tasks = state.tasks;
        } else if (context.read<CalendarBloc>().state is CalendarTasksLoaded) {
          tasks = (context.read<CalendarBloc>().state as CalendarTasksLoaded).tasks;
        }

        // Filter tasks by selected asset if applicable
        if (selectedAssetId != null) {
          tasks = tasks.where((t) => t.assetId == selectedAssetId).toList();
        }

        final activeTasks = tasks.where((t) => !t.isCompleted).toList();
        final completedTasks = tasks.where((t) => t.isCompleted).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Задачи и Вакцинация', style: AppTextStyles.h2.copyWith(fontSize: 20)),
                if (assets.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.sagePrimary, size: 28),
                    onPressed: () => AddTaskSheet.show(
                      context,
                      assets: assets,
                      preselectedAssetId: selectedAssetId,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading && tasks.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.sagePrimary),
                ),
              )
            else if (tasks.isEmpty)
              SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 48, color: AppColors.textLight.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Нет запланированных задач',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Планируйте вакцинации, визиты ветеринара и случки для ваших животных в одном месте.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                      textAlign: TextAlign.center,
                    ),
                    if (assets.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => AddTaskSheet.show(
                          context,
                          assets: assets,
                          preselectedAssetId: selectedAssetId,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Добавить задачу'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeTasks.length + (completedTasks.isNotEmpty ? completedTasks.length + 1 : 0),
                itemBuilder: (context, index) {
                  // Divider header for completed tasks
                  if (index == activeTasks.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Выполненные задачи',
                              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textLight),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                    );
                  }

                  final isCompletedItem = index > activeTasks.length;
                  final task = isCompletedItem 
                      ? completedTasks[index - activeTasks.length - 1] 
                      : activeTasks[index];

                  final isOverdue = !task.isCompleted && task.plannedDate.isBefore(DateTime.now());
                  final parentAsset = assets.firstWhere(
                    (a) => a.id == task.assetId,
                    orElse: () => LivestockAssetModel(
                      id: task.assetId,
                      category: '',
                      breed: 'Неизвестная группа',
                      quantity: 0,
                      purchasePrice: 0,
                    ),
                  );

                  return Dismissible(
                    key: Key('task_${task.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.errorSoft, size: 28),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Удаление задачи'),
                          content: const Text('Вы уверены, что хотите удалить эту календарную задачу?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Удалить', style: TextStyle(color: AppColors.errorSoft)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      if (task.id != null) {
                        context.read<CalendarBloc>().add(DeleteCalendarTaskEvent(task.id!));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                            value: task.isCompleted,
                            activeColor: AppColors.sagePrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            onChanged: (val) {
                              if (task.id != null && val != null) {
                                context.read<CalendarBloc>().add(
                                  ToggleTaskCompletionEvent(taskId: task.id!, isCompleted: val),
                                );
                              }
                            },
                          ),
                          title: Text(
                            task.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? AppColors.textLight : AppColors.textDark,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task.description != null && task.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description!,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: _taskTypeColor(task.taskType).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _taskTypeIcon(task.taskType),
                                      size: 12,
                                      color: _taskTypeColor(task.taskType),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    parentAsset.breed,
                                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.sagePrimary),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•', style: TextStyle(color: AppColors.textLight, fontSize: 8)),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: isOverdue ? AppColors.errorSoft : AppColors.textLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateFormat.format(task.plannedDate),
                                    style: AppTextStyles.caption.copyWith(
                                      color: isOverdue ? AppColors.errorSoft : AppColors.textLight,
                                      fontWeight: isOverdue ? FontWeight.bold : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
