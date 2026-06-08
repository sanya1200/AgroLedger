import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/calculation_cycle_model.dart';
import 'package:agroledger/features/calculator/data/models/cycle_analytics_model.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();
  @override
  List<Object?> get props => [];
}

class CalculatorInitial extends CalculatorState {}
class CalculatorLoading extends CalculatorState {}

class CyclesLoadSuccess extends CalculatorState {
  final List<CalculationCycleModel> cycles;
  const CyclesLoadSuccess(this.cycles);
  @override
  List<Object?> get props => [cycles];
}

class AnalyticsLoadSuccess extends CalculatorState {
  final CycleAnalyticsModel analytics;
  const AnalyticsLoadSuccess(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class CalculatorActionSuccess extends CalculatorState {
  final String message;
  const CalculatorActionSuccess(this.message);
}

class CalculatorFailure extends CalculatorState {
  final String message;
  const CalculatorFailure(this.message);
  @override
  List<Object?> get props => [message];
}
