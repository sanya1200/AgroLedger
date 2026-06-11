class IncomeModel {
  final int id;
  final int cycleId;
  final String productName;
  final double quantity;
  final double amount;
  final DateTime? date;

  IncomeModel({
    required this.id,
    required this.cycleId,
    required this.productName,
    required this.quantity,
    required this.amount,
    this.date,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      cycleId: json['cycle_id'],
      productName: json['product_name'],
      quantity: double.parse(json['quantity'].toString()),
      amount: double.parse(json['amount'].toString()),
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : null,
    );
  }
}
