part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String phone;
  final String role;
  final String? fullName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.fullName,
  });

  @override
  List<Object?> get props => [email, password, phone, role, fullName];
}

class AuthPinSetupRequested extends AuthEvent {
  final String pin;
  const AuthPinSetupRequested({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class AuthPinSignInRequested extends AuthEvent {
  final String pin;
  const AuthPinSignInRequested({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class AuthBiometricSignInRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
