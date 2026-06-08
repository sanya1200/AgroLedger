import 'package:equatable/equatable.dart';

class CalculationCycleModel extends Equatable {
  final int id;
  final int businessId;
  final String name;
  final String animalType;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;

  const CalculationCycleModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.animalType,
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  factory CalculationCycleModel.fromJson(Map<String, dynamic> json) {
    return CalculationCycleModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      animalType: json['animal_type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
    );
  }

  @override
  List<Object?> get props => [id, businessId, name, animalType, status, createdAt, closedAt];
}
