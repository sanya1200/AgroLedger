import 'package:equatable/equatable.dart';
import '../../data/models/livestock_task_model.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarTasksLoaded extends CalendarState {
  final List<LivestockTaskModel> tasks;

  const CalendarTasksLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class CalendarActionSuccess extends CalendarState {
  final String message;

  const CalendarActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
