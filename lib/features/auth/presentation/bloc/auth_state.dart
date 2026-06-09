part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, authorized, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
