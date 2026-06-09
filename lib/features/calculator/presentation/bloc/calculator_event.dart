import 'package:equatable/equatable.dart';
import 'package:agroledger/features/calculator/data/models/livestock_asset_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_expense_model.dart';
import 'package:agroledger/features/calculator/data/models/livestock_yield_model.dart';

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

class FetchAssetsEvent extends CalculatorEvent {
  const FetchAssetsEvent();
}

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
