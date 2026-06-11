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
  final String? phone;
  final String role;
  final String? fullName;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.phone,
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

class AuthUpdateSettingsRequested extends AuthEvent {
  final bool? isBiometricEnabled;
  final String? fullName;
  final String? phone;
  final String? role;

  const AuthUpdateSettingsRequested({
    this.isBiometricEnabled,
    this.fullName,
    this.phone,
    this.role,
  });

  @override
  List<Object?> get props => [isBiometricEnabled, fullName, phone, role];
}

class AuthVerifyUserRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthDeleteAccountRequested extends AuthEvent {}

class AuthSessionExpired extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {
  final String email;
  final String fullName;
  final String? phone;
  final String? role;
  final String? idToken;

  const AuthGoogleSignInRequested({
    required this.email,
    required this.fullName,
    this.phone,
    this.role,
    this.idToken,
  });

  @override
  List<Object?> get props => [email, fullName, phone, role, idToken];
}

class AuthVerifyEmailRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyEmailRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class AuthResendCodeRequested extends AuthEvent {
  final String email;

  const AuthResendCodeRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthClearVerificationEmail extends AuthEvent {}
