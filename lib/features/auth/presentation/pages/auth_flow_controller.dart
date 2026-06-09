import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/auth_bloc.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'pin_code_screen.dart';
import 'package:agroledger/core/di/service_locator.dart';

class AuthFlowController extends StatefulWidget {
  const AuthFlowController({super.key});

  @override
  State<AuthFlowController> createState() => _AuthFlowControllerState();
}

class _AuthFlowControllerState extends State<AuthFlowController> {
  bool? _isFirstLaunch;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if onboarding was already shown
    final isFirst = prefs.getBool('is_first_launch') ?? true;
    
    if (isFirst) {
      await prefs.setBool('is_first_launch', false);
    }

    if (mounted) {
      setState(() {
        _isFirstLaunch = isFirst;
        _isLoading = false;
      });
      // Trigger token check in BLoC
      context.read<AuthBloc>().add(AuthCheckStatusRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isFirstLaunch == true) {
      return const OnboardingScreen();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return FutureBuilder<String?>(
            future: sl<FlutterSecureStorage>().read(key: 'user_pin_hash'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              // If user is authenticated but has no PIN set yet
              if (snapshot.data == null) {
                return const PinCodeScreen(mode: PinMode.setup);
              }
              
              // If user is authenticated and has PIN, verify it
              // In a real app, you might want a state to track if PIN was verified in current session.
              // For simplicity, we show Verify screen.
              return const PinCodeScreen(mode: PinMode.verify);
            },
          );
        }

        if (state is AuthUnauthenticated || state is AuthFailureState) {
          return const LoginScreen();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
