class ExpenseModel {
  final int id;
  final int cycleId;
  final String category;
  final double amount;
  final String? description;
  final DateTime date;

  ExpenseModel({
    required this.id,
    required this.cycleId,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      cycleId: json['cycle_id'],
      category: json['category'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      date: DateTime.parse(json['date']),
    );
  }
}
