class CycleAnalyticsModel {
  final double totalExpenses;
  final double totalIncomes;
  final double netProfit;
  final double roi;
  final String status;

  CycleAnalyticsModel({
    required this.totalExpenses,
    required this.totalIncomes,
    required this.netProfit,
    required this.roi,
    required this.status,
  });

  factory CycleAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CycleAnalyticsModel(
      totalExpenses: double.parse(json['total_expenses'].toString()),
      totalIncomes: double.parse(json['total_incomes'].toString()),
      netProfit: double.parse(json['net_profit'].toString()),
      roi: double.parse(json['ROI'].toString()),
      status: json['status'],
    );
  }
}
