import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';

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

  const CalculatorSummaryLoaded({
    required this.summary,
    required this.assets,
  });

  @override
  List<Object?> get props => [summary, assets];
}

class CalculatorActionSuccess extends CalculatorState {
  final String message;

  const CalculatorActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError(this.message);

  @override
  List<Object?> get props => [message];
}
