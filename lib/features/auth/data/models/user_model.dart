import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String email;
  final String phone;
  final String? fullName;
  final String role;
  final bool isBiometricEnabled;
  final bool isVerified;
  final bool hasBusinessProfile;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.phone,
    this.fullName,
    required this.role,
    required this.isBiometricEnabled,
    required this.isVerified,
    required this.hasBusinessProfile,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // We assume the caller has already extracted the 'data' part from BaseResponse
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'],
      role: json['role'] ?? '',
      isBiometricEnabled: json['is_biometric_enabled'] ?? false,
      isVerified: json['is_verified'] ?? false,
      hasBusinessProfile: json['has_business_profile'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
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
      'has_business_profile': hasBusinessProfile,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, email, phone, fullName, role, isBiometricEnabled, isVerified, hasBusinessProfile, createdAt];
}
