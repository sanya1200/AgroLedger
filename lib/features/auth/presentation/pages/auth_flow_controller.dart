import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'pin_code_screen.dart';
import 'package:agroledger/features/home/presentation/pages/main_screen.dart';
import 'package:agroledger/features/home/presentation/pages/business_setup_screen.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/core/services/auth_session_service.dart';
import 'package:agroledger/core/theme/app_colors.dart';

class AuthFlowController extends StatefulWidget {
  const AuthFlowController({super.key});

  @override
  State<AuthFlowController> createState() => _AuthFlowControllerState();
}

class _AuthFlowControllerState extends State<AuthFlowController> {
  bool? _isFirstLaunch;
  bool _isLoading = true;
  StreamSubscription<void>? _sessionExpiredSubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
    _sessionExpiredSubscription =
        sl<AuthSessionService>().onSessionExpired.listen((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthSessionExpired());
    });
  }

  @override
  void dispose() {
    _sessionExpiredSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool('is_first_launch') ?? true;

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirst;
        _isLoading = false;
      });
      context.read<AuthBloc>().add(AuthCheckStatusRequested());
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    if (mounted) setState(() => _isFirstLaunch = false);
  }

  void _showSessionExpiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AuthBloc.sessionExpiredMessage),
        backgroundColor: AppColors.errorSoft,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _loadingIndicator();

    if (_isFirstLaunch == true) {
      return OnboardingScreen(onFinish: _finishOnboarding);
    }

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.unauthenticated &&
          current.errorMessage == AuthBloc.sessionExpiredMessage &&
          (previous.status != AuthStatus.unauthenticated ||
              previous.errorMessage != AuthBloc.sessionExpiredMessage),
      listener: (context, state) {
        _showSessionExpiredSnackBar(context);
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.authorized:
              return const MainScreen();

            case AuthStatus.authenticated:
              return FutureBuilder<String?>(
                future: sl<FlutterSecureStorage>().read(key: 'user_pin_hash'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _loadingIndicator();
                  }
                  if (snapshot.data == null) {
                    return const PinCodeScreen(mode: PinMode.setup);
                  }
                  return const PinCodeScreen(mode: PinMode.verify);
                },
              );

            case AuthStatus.unauthenticated:
            case AuthStatus.failure:
              return const LoginScreen();

            case AuthStatus.loading:
            case AuthStatus.initial:
              return _loadingIndicator();
          }
        },
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
