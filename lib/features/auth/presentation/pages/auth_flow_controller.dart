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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _loadingIndicator();

    if (_isFirstLaunch == true) {
      return OnboardingScreen(onFinish: _finishOnboarding);
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authorized) {
          final user = state.user;
          if (user != null && user.role == 'farmer_business' && !user.hasBusinessProfile) {
            return const BusinessSetupScreen();
          }
          return const MainScreen();
        }
          
          case AuthStatus.authenticated:
            return FutureBuilder<String?>(
              future: sl<FlutterSecureStorage>().read(key: 'user_pin_hash'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return _loadingIndicator();
                if (snapshot.data == null) return const PinCodeScreen(mode: PinMode.setup);
                return const PinCodeScreen(mode: PinMode.verify);
              },
            );

          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            // Only show login if it's a real unauth or if we are not in loading/authenticated states
            if (state.status == AuthStatus.failure && state.user != null) {
              // If failure happened but we have a user, it's likely a PIN error, handled in PinScreen
            }
            return const LoginScreen();

          case AuthStatus.loading:
          case AuthStatus.initial:
            return _loadingIndicator();
        }
      },
    );
  }

  Widget _loadingIndicator() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
