import 'package:equatable/equatable.dart';
import '../../data/models/livestock_task_model.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarTasksEvent extends CalendarEvent {
  const LoadCalendarTasksEvent();
}

class CreateCalendarTaskEvent extends CalendarEvent {
  final LivestockTaskModel task;

  const CreateCalendarTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateCalendarTaskEvent extends CalendarEvent {
  final int taskId;
  final LivestockTaskModel task;

  const UpdateCalendarTaskEvent({required this.taskId, required this.task});

  @override
  List<Object?> get props => [taskId, task];
}

class ToggleTaskCompletionEvent extends CalendarEvent {
  final int taskId;
  final bool isCompleted;

  const ToggleTaskCompletionEvent({required this.taskId, required this.isCompleted});

  @override
  List<Object?> get props => [taskId, isCompleted];
}

class DeleteCalendarTaskEvent extends CalendarEvent {
  final int taskId;

  const DeleteCalendarTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
