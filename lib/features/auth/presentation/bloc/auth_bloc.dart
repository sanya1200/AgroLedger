import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:agroledger/core/services/pin_crypto_service.dart';
import 'dart:developer' as dev;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  final FlutterSecureStorage _storage;

  static const sessionExpiredMessage =
      'Сессия истекла, пожалуйста, войдите снова';

  AuthBloc({
    required AuthRemoteDataSource authRemoteDataSource,
    required FlutterSecureStorage storage,
  })  : _authRemoteDataSource = authRemoteDataSource,
        _storage = storage,
        super(const AuthState()) {
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthPinSetupRequested>(_onPinSetupRequested);
    on<AuthPinSignInRequested>(_onPinSignInRequested);
    on<AuthBiometricSignInRequested>(_onBiometricSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthUpdateSettingsRequested>(_onUpdateSettingsRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  Future<void> _onUpdateSettingsRequested(
    AuthUpdateSettingsRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRemoteDataSource.updateSettings(
        isBiometricEnabled: event.isBiometricEnabled,
        fullName: event.fullName,
      );
      emit(state.copyWith(user: user));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRemoteDataSource.deleteAccount();
      await _clearAllAuthData();
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    } catch (e) {
      emit(state.copyWith(
          status: AuthStatus.authorized, errorMessage: e.toString()));
    }
  }

  Future<void> _clearAllAuthData() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_pin_hash');
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');

    if (accessToken == null && refreshToken == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      return;
    }

    try {
      final user = await _authRemoteDataSource.getMe();
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      dev.log('Auth check failed', error: e);

      final remainingRefresh = await _storage.read(key: 'refresh_token');
      if (remainingRefresh == null) {
        await _clearAllAuthData();
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: sessionExpiredMessage,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      }
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRemoteDataSource.login(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final user = await _authRemoteDataSource.register(
        email: event.email,
        password: event.password,
        phone: event.phone,
        role: event.role,
        fullName: event.fullName,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPinSetupRequested(
    AuthPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRemoteDataSource.setupPin(event.pin);
      final hashedPin = await PinCryptoService.hashPin(event.pin);
      await _storage.write(key: 'user_pin_hash', value: hashedPin);
      emit(state.copyWith(status: AuthStatus.authorized));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.toString().contains('Exception') ? 'Ошибка сохранения ПИН-кода' : e.toString(),
      ));
    }
  }

  Future<void> _onPinSignInRequested(
    AuthPinSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      final savedHash = await _storage.read(key: 'user_pin_hash');
      if (savedHash != null &&
          await PinCryptoService.verifyPin(event.pin, savedHash)) {
        emit(state.copyWith(status: AuthStatus.authorized));
      } else {
        emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Неверный ПИН-код',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Ошибка проверки ПИН-кода',
      ));
    }
  }

  Future<void> _onBiometricSignInRequested(
    AuthBiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      emit(state.copyWith(status: AuthStatus.authorized));
    } else {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: sessionExpiredMessage,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _clearAllAuthData();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: null,
    ));
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _clearAllAuthData();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
      errorMessage: sessionExpiredMessage,
    ));
  }
}
