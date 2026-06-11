import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/calculator_repository.dart';
import '../../data/models/livestock_asset_model.dart';
import '../../data/models/livestock_expense_model.dart';
import '../../data/models/livestock_yield_model.dart';
import '../../data/models/calculator_summary_model.dart';
import '../../data/models/predictive_forecast_model.dart';
import '../../data/datasources/calculator_remote_data_source.dart';
import '../../data/models/calculator_enums.dart';

part 'calculator_event.dart';
part 'calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final CalculatorRepository _repository;

  CalculatorBloc(this._repository) : super(const CalculatorInitial()) {
    on<FetchCalculatorSummaryEvent>(_onFetchSummary);
    on<FetchAssetsEvent>(_onFetchAssets);
    on<CreateAssetEvent>(_onCreateAsset);
    on<RecordExpenseEvent>(_onRecordExpense);
    on<RecordYieldEvent>(_onRecordYield);
    on<FetchPredictiveForecastEvent>(_onFetchForecast);
    on<ActivatePremiumDebugEvent>(_onActivatePremium);
    on<SaveSimulatedGroupEvent>(_onSaveSimulatedGroup);
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
      final summary = await _repository.getSummary();
      emit(CalculatorSummaryLoaded(summary: summary, assets: assets));
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
    } on FreeLimitException {
      emit(const CalculatorFreeLimitReachedState());
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

  Future<void> _onFetchForecast(
    FetchPredictiveForecastEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      final forecast = await _repository.getPredictiveForecast(event.assetId);
      emit(PredictiveForecastLoadedState(forecast));
    } on PremiumRequiredException {
      emit(const CalculatorPremiumLockedState('Предиктивная аналитика'));
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onActivatePremium(
    ActivatePremiumDebugEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    try {
      await _repository.activatePremiumDebug();
      emit(const CalculatorActionSuccess(message: 'Премиум активирован!'));
      add(const FetchCalculatorSummaryEvent());
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }

  Future<void> _onSaveSimulatedGroup(
    SaveSimulatedGroupEvent event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(const CalculatorLoading());
    try {
      final createdAsset = await _repository.addAsset(event.asset);
      
      // If feedCost > 0, record the expense
      if (event.feedCost > 0) {
        await _repository.addExpense(LivestockExpenseModel(
          id: 0,
          assetId: createdAsset.id!,
          feedSubType: FeedSubType.compoundFeed,
          amount: event.feedCost,
          description: 'Расчетный расход на корма из калькулятора',
          date: DateTime.now(),
        ));
      }
      
      // If otherCost > 0, record the expense
      if (event.otherCost > 0) {
        await _repository.addExpense(LivestockExpenseModel(
          id: 0,
          assetId: createdAsset.id!,
          otherSubType: OtherSubType.logistics,
          amount: event.otherCost,
          description: 'Расчетный расход на ветпрепараты и прочее из калькулятора',
          date: DateTime.now(),
        ));
      }

      emit(const CalculatorActionSuccess(
        message: 'Моделирование сохранено в активную группу!',
      ));
      add(const FetchCalculatorSummaryEvent());
    } on FreeLimitException {
      emit(const CalculatorFreeLimitReachedState());
    } catch (e) {
      emit(CalculatorError(e.toString()));
    }
  }
}
