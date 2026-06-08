import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/calculator/data/datasources/calculator_remote_data_source.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_event.dart';
import 'package:agroledger/features/calculator/presentation/bloc/calculator_state.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final CalculatorRemoteDataSource _dataSource;

  CalculatorBloc(this._dataSource) : super(CalculatorInitial()) {
    on<LoadCyclesRequested>(_onLoadCycles);
    on<CreateCycleRequested>(_onCreateCycle);
    on<AddExpenseRequested>(_onAddExpense);
    on<AddIncomeRequested>(_onAddIncome);
    on<LoadAnalyticsRequested>(_onLoadAnalytics);
    on<CloseCycleRequested>(_onCloseCycle);
  }

  Future<void> _onLoadCycles(LoadCyclesRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      final cycles = await _dataSource.getCycles();
      emit(CyclesLoadSuccess(cycles));
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }

  Future<void> _onCreateCycle(CreateCycleRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      await _dataSource.createCycle(event.name, event.animalType);
      add(LoadCyclesRequested());
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }

  Future<void> _onAddExpense(AddExpenseRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      await _dataSource.addExpense(event.cycleId, event.category, event.amount, event.description);
      add(LoadAnalyticsRequested(event.cycleId));
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }

  Future<void> _onAddIncome(AddIncomeRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      await _dataSource.addIncome(event.cycleId, event.productName, event.quantity, event.amount);
      add(LoadAnalyticsRequested(event.cycleId));
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }

  Future<void> _onLoadAnalytics(LoadAnalyticsRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      final analytics = await _dataSource.getAnalytics(event.cycleId);
      emit(AnalyticsLoadSuccess(analytics));
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }

  Future<void> _onCloseCycle(CloseCycleRequested event, Emitter<CalculatorState> emit) async {
    emit(CalculatorLoading());
    try {
      await _dataSource.closeCycle(event.cycleId);
      add(LoadAnalyticsRequested(event.cycleId));
    } catch (e) {
      emit(CalculatorFailure(e.toString()));
    }
  }
}
