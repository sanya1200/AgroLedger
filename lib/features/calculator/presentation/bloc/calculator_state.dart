part of 'calculator_bloc.dart';

abstract class CalculatorState extends Equatable {
  const CalculatorState();

  @override
  List<Object?> get props => [];
}

class CalculatorInitial extends CalculatorState {
  const CalculatorInitial();
}

class CalculatorLoading extends CalculatorState {
  const CalculatorLoading();
}

class CalculatorSummaryLoaded extends CalculatorState {
  final CalculatorSummaryModel summary;
  final List<LivestockAssetModel> assets;

  const CalculatorSummaryLoaded({required this.summary, required this.assets});

  @override
  List<Object?> get props => [summary, assets];
}

class PredictiveForecastLoadedState extends CalculatorState {
  final PredictiveForecastModel forecast;
  const PredictiveForecastLoadedState(this.forecast);

  @override
  List<Object?> get props => [forecast];
}

class CalculatorActionSuccess extends CalculatorState {
  final String message;
  const CalculatorActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CalculatorPremiumLockedState extends CalculatorState {
  final String featureName;
  const CalculatorPremiumLockedState(this.featureName);

  @override
  List<Object?> get props => [featureName];
}

class CalculatorFreeLimitReachedState extends CalculatorState {
  const CalculatorFreeLimitReachedState();
}

class CalculatorError extends CalculatorState {
  final String message;
  const CalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}
