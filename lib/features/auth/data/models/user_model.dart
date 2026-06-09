import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String email;
  final String phone;
  final String? fullName;
  final String role;
  final bool isBiometricEnabled;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    this.fullName,
    required this.role,
    required this.isBiometricEnabled,
    required this.isVerified,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handling the "data" envelope from our new API
    Map<String, dynamic> data;
    if (json.containsKey('data')) {
      if (json['data'] is Map<String, dynamic>) {
        data = json['data'];
      } else if (json['data'] is List && (json['data'] as List).isNotEmpty) {
        data = (json['data'] as List).first;
      } else {
        data = json;
      }
    } else {
      data = json;
    }
    
    return UserModel(
      id: data['id'] ?? 0,
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      fullName: data['full_name'],
      role: data['role'] ?? '',
      isBiometricEnabled: data['is_biometric_enabled'] ?? false,
      isVerified: data['is_verified'] ?? false,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'role': role,
      'is_biometric_enabled': isBiometricEnabled,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, phone, fullName, role, isBiometricEnabled, isVerified, createdAt];
}
