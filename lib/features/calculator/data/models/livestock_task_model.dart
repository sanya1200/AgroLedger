import 'package:equatable/equatable.dart';
import 'calculator_enums.dart';

class LivestockTaskModel extends Equatable {
  final int? id;
  final int assetId;
  final String title;
  final String? description;
  final DateTime plannedDate;
  final bool isCompleted;
  final TaskType taskType;
  final DateTime? completedAt;
  final DateTime? createdAt;

  const LivestockTaskModel({
    this.id,
    required this.assetId,
    required this.title,
    this.description,
    required this.plannedDate,
    required this.isCompleted,
    required this.taskType,
    this.completedAt,
    this.createdAt,
  });

  factory LivestockTaskModel.fromJson(Map<String, dynamic> json) {
    return LivestockTaskModel(
      id: json['id'],
      assetId: json['asset_id'],
      title: json['title'] ?? '',
      description: json['description'],
      plannedDate: DateTime.parse(json['planned_date'].toString()).toLocal(),
      isCompleted: json['is_completed'] ?? false,
      taskType: TaskType.fromString(json['task_type']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'].toString()).toLocal() 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()).toLocal() 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'asset_id': assetId,
        'title': title,
        'description': description,
        'planned_date': plannedDate.toUtc().toIso8601String(),
        'is_completed': isCompleted,
        'task_type': taskType.name,
        if (completedAt != null) 'completed_at': completedAt?.toUtc().toIso8601String(),
      };

  LivestockTaskModel copyWith({
    int? id,
    int? assetId,
    String? title,
    String? description,
    DateTime? plannedDate,
    bool? isCompleted,
    TaskType? taskType,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return LivestockTaskModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      title: title ?? this.title,
      description: description ?? this.description,
      plannedDate: plannedDate ?? this.plannedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      taskType: taskType ?? this.taskType,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assetId,
        title,
        description,
        plannedDate,
        isCompleted,
        taskType,
        completedAt,
        createdAt,
      ];
}
