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
  final bool isPremium;
  final DateTime? premiumUntil;

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
    this.isPremium = false,
    this.premiumUntil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'],
      role: json['role'] ?? '',
      isBiometricEnabled: json['is_biometric_enabled'] ?? false,
      isVerified: json['is_verified'] ?? false,
      hasBusinessProfile: json['has_business_profile'] ?? false,
      isPremium: json['is_premium'] ?? false,
      premiumUntil: json['premium_until'] != null
          ? DateTime.parse(json['premium_until'])
          : null,
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
      'is_premium': isPremium,
      'premium_until': premiumUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumUntil == null) return true;
    return premiumUntil!.isAfter(DateTime.now());
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        fullName,
        role,
        isBiometricEnabled,
        isVerified,
        hasBusinessProfile,
        createdAt,
        isPremium,
        premiumUntil,
      ];
}
