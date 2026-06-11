import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/calculator_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalculatorRepository _repository;

  CalendarBloc(this._repository) : super(const CalendarInitial()) {
    on<LoadCalendarTasksEvent>(_onLoadTasks);
    on<CreateCalendarTaskEvent>(_onCreateTask);
    on<UpdateCalendarTaskEvent>(_onUpdateTask);
    on<ToggleTaskCompletionEvent>(_onToggleTask);
    on<DeleteCalendarTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(
    LoadCalendarTasksEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    try {
      final tasks = await _repository.getTasks();
      emit(CalendarTasksLoaded(tasks));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateCalendarTaskEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    try {
      await _repository.addTask(event.task);
      emit(const CalendarActionSuccess('Задача успешно создана'));
      add(const LoadCalendarTasksEvent());
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateCalendarTaskEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    try {
      await _repository.updateTask(event.taskId, event.task);
      emit(const CalendarActionSuccess('Задача успешно обновлена'));
      add(const LoadCalendarTasksEvent());
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onToggleTask(
    ToggleTaskCompletionEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    try {
      // Fetch current task first (we can retrieve it from the current loaded state if available, 
      // or we can construct a partial task update with just is_completed)
      final tasks = await _repository.getTasks();
      final currentTask = tasks.firstWhere((t) => t.id == event.taskId);
      final updatedTask = currentTask.copyWith(
        isCompleted: event.isCompleted,
      );
      await _repository.updateTask(event.taskId, updatedTask);
      emit(CalendarActionSuccess(
        event.isCompleted ? 'Задача отмечена как выполненная' : 'Задача возвращена в работу'
      ));
      add(const LoadCalendarTasksEvent());
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteCalendarTaskEvent event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());
    try {
      await _repository.deleteTask(event.taskId);
      emit(const CalendarActionSuccess('Задача успешно удалена'));
      add(const LoadCalendarTasksEvent());
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }
}
