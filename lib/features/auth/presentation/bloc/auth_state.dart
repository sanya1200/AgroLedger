part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, authorized, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? needsVerificationEmail;
  final bool isVerificationLoading;
  final bool clearVerificationEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.needsVerificationEmail,
    this.isVerificationLoading = false,
    this.clearVerificationEmail = false,
  });

  @override
  List<Object?> get props => [
        status,
        user,
        errorMessage,
        needsVerificationEmail,
        isVerificationLoading,
        clearVerificationEmail,
      ];

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? needsVerificationEmail,
    bool? isVerificationLoading,
    bool? clearVerificationEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      needsVerificationEmail: (clearVerificationEmail ?? false) ? null : (needsVerificationEmail ?? this.needsVerificationEmail),
      isVerificationLoading: isVerificationLoading ?? this.isVerificationLoading,
      clearVerificationEmail: clearVerificationEmail ?? this.clearVerificationEmail,
    );
  }
}
