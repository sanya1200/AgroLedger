import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String? phone;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, phone, role];
}

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.phone,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}
