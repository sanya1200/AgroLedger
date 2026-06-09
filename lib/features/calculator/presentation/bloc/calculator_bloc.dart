import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/calculator/data/repositories/calculator_repository.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final CalculatorRepository _repository;

  CalculatorBloc(this._repository) : super(const CalculatorInitial()) {
    on<FetchCalculatorSummaryEvent>(_onFetchSummary);
    on<FetchAssetsEvent>(_onFetchAssets);
    on<CreateAssetEvent>(_onCreateAsset);
    on<RecordExpenseEvent>(_onRecordExpense);
    on<RecordYieldEvent>(_onRecordYield);
  }

  Future<void> _onFetchSummary(
    FetchCalculatorSummaryEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      final summary = await _repository.getSummary(assetId: event.assetId);
      final assets = await _repository.getAssets();
      emit(CalculatorSummaryLoaded(summary: summary, assets: assets));
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onFetchAssets(
    FetchAssetsEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      final assets = await _repository.getAssets();
      final currentState = state;
      if (currentState is CalculatorSummaryLoaded) {
        emit(CalculatorSummaryLoaded(
          summary: currentState.summary,
          assets: assets,
        ));
      } else {
        final summary = await _repository.getSummary();
        emit(CalculatorSummaryLoaded(summary: summary, assets: assets));
      }
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onCreateAsset(
    CreateAssetEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      await _repository.addAsset(event.asset);
      emit(const CalculatorActionSuccess(
        message: 'Группа поголовья успешно добавлена',
      ));
      add(const FetchCalculatorSummaryEvent());
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onRecordExpense(
    RecordExpenseEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      await _repository.addExpense(event.expense);
      emit(const CalculatorActionSuccess(
        message: 'Расход успешно записан',
      ));
      add(FetchCalculatorSummaryEvent(assetId: event.expense.assetId));
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onRecordYield(
    RecordYieldEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      await _repository.addYield(event.yieldData);
      emit(const CalculatorActionSuccess(
        message: 'Доход успешно записан',
      ));
      add(FetchCalculatorSummaryEvent(assetId: event.yieldData.assetId));
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }
}
