import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agroledger/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agroledger/features/auth/data/models/user_model.dart';
import 'package:crypt/crypt.dart';

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
        super(AuthInitial()) {
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
        // If we want to support session persistence for PIN, we could check a 'is_pin_verified' flag here.
        // For now, any fresh start requires PIN if it exists.
        emit(AuthAuthenticated(user));
      } catch (_) {
        await _storage.delete(key: 'access_token');
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRemoteDataSource.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRemoteDataSource.register(
        email: event.email,
        password: event.password,
        phone: event.phone,
        role: event.role,
        fullName: event.fullName,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailureState(e.toString()));
    }
  }

  Future<void> _onPinSetupRequested(
    AuthPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final hashedPin = Crypt.sha256(event.pin).toString();
      await _storage.write(key: 'user_pin_hash', value: hashedPin);
      
      final user = await _authRemoteDataSource.getMe();
      emit(AuthAuthorized(user)); // Directly authorized after setup
    } catch (e) {
      emit(AuthFailureState("Ошибка при установке ПИН-кода"));
    }
  }

  Future<void> _onPinSignInRequested(
    AuthPinSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final savedHash = await _storage.read(key: 'user_pin_hash');
    if (savedHash != null && Crypt(savedHash).match(event.pin)) {
      try {
        final user = await _authRemoteDataSource.getMe();
        emit(AuthAuthorized(user)); // Authorized after correct PIN
      } catch (e) {
        emit(AuthFailureState("Ошибка сессии. Пожалуйста, войдите снова."));
      }
    } else {
      emit(AuthFailureState("Неверный ПИН-код"));
    }
  }

  Future<void> _onBiometricSignInRequested(
    AuthBiometricSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final user = await _authRemoteDataSource.getMe();
        emit(AuthAuthorized(user)); // Authorized after biometric
      } else {
        emit(AuthFailureState("Сессия истекла. Войдите по паролю."));
      }
    } catch (e) {
      emit(AuthFailureState("Ошибка входа по биометрии"));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user_pin_hash');
    emit(AuthUnauthenticated());
  }
}
