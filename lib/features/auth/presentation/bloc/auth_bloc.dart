import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:crypt/crypt.dart';
import 'dart:developer' as dev;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource _authRemoteDataSource;
  final FlutterSecureStorage _storage;

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
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        final user = await _authRemoteDataSource.getMe();
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } catch (e) {
        dev.log('Auth check failed', error: e);
        await _storage.delete(key: 'access_token');
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRemoteDataSource.login(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
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
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onPinSetupRequested(
    AuthPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final hashedPin = Crypt.sha256(event.pin).toString();
      await _storage.write(key: 'user_pin_hash', value: hashedPin);
      emit(state.copyWith(status: AuthStatus.authorized));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: "Ошибка сохранения ПИН-кода"));
    }
  }

  Future<void> _onPinSignInRequested(
    AuthPinSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final savedHash = await _storage.read(key: 'user_pin_hash');
      if (savedHash != null && Crypt(savedHash).match(event.pin)) {
        emit(state.copyWith(status: AuthStatus.authorized));
      } else {
        emit(state.copyWith(status: AuthStatus.failure, errorMessage: "Неверный ПИН-код"));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: "Ошибка проверки ПИН-кода"));
    }
  }

  Future<void> _onBiometricSignInRequested(
    AuthBiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      emit(state.copyWith(status: AuthStatus.authorized));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, errorMessage: "Сессия истекла"));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_pin_hash');
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }
}
