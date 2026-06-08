import 'package:equatable/equatable.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();
  @override
  List<Object?> get props => [];
}

class LoadCyclesRequested extends CalculatorEvent {}

class CreateCycleRequested extends CalculatorEvent {
  final String name;
  final String animalType;
  const CreateCycleRequested(this.name, this.animalType);
}

class AddExpenseRequested extends CalculatorEvent {
  final int cycleId;
  final String category;
  final double amount;
  final String? description;
  const AddExpenseRequested(this.cycleId, this.category, this.amount, this.description);
}

class AddIncomeRequested extends CalculatorEvent {
  final int cycleId;
  final String productName;
  final double quantity;
  final double amount;
  const AddIncomeRequested(this.cycleId, this.productName, this.quantity, this.amount);
}

class LoadAnalyticsRequested extends CalculatorEvent {
  final int cycleId;
  const LoadAnalyticsRequested(this.cycleId);
}

class CloseCycleRequested extends CalculatorEvent {
  final int cycleId;
  const CloseCycleRequested(this.cycleId);
}
