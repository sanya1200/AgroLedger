part of 'calculator_bloc.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object?> get props => [];
}

class FetchCalculatorSummaryEvent extends CalculatorEvent {
  final int? assetId;
  const FetchCalculatorSummaryEvent({this.assetId});

  @override
  List<Object?> get props => [assetId];
}

class FetchAssetsEvent extends CalculatorEvent {}

class CreateAssetEvent extends CalculatorEvent {
  final LivestockAssetModel asset;
  const CreateAssetEvent(this.asset);

  @override
  List<Object?> get props => [asset];
}

class RecordExpenseEvent extends CalculatorEvent {
  final LivestockExpenseModel expense;
  const RecordExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class RecordYieldEvent extends CalculatorEvent {
  final LivestockYieldModel yieldData;
  const RecordYieldEvent(this.yieldData);

  @override
  List<Object?> get props => [yieldData];
}

class FetchPredictiveForecastEvent extends CalculatorEvent {
  final int assetId;
  const FetchPredictiveForecastEvent(this.assetId);

  @override
  List<Object?> get props => [assetId];
}

class ActivatePremiumDebugEvent extends CalculatorEvent {}
