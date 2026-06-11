import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'register_screen.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_account_picker_dialog.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_registration_completion_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isGoogleAction = false;
  String? _googleEmail;
  String? _googleName;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    setState(() {
      _isGoogleAction = false;
    });
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  Future<void> _onGoogleSignIn() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GoogleAccountPickerDialog(),
    );

    if (result != null) {
      final email = result['email']!;
      final name = result['name']!;
      setState(() {
        _googleEmail = email;
        _googleName = name;
        _isGoogleAction = true;
      });
      if (mounted) {
        context.read<AuthBloc>().add(
              AuthGoogleSignInRequested(
                email: email,
                fullName: name,
              ),
            );
      }
    }
  }

  Future<void> _showRegistrationCompletionDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GoogleRegistrationCompletionDialog(email: _googleEmail!),
    );

    if (result != null) {
      final phone = result['phone']!;
      final role = result['role']!;
      if (mounted) {
        context.read<AuthBloc>().add(
              AuthGoogleSignInRequested(
                email: _googleEmail!,
                fullName: _googleName!,
                phone: phone,
                role: role,
              ),
            );
      }
    } else {
      setState(() {
        _isGoogleAction = false;
        _googleEmail = null;
        _googleName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            if (state.errorMessage == "GOOGLE_REGISTRATION_REQUIRED" && _isGoogleAction && _googleEmail != null) {
              _showRegistrationCompletionDialog();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.errorSoft,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else if (state.status == AuthStatus.authenticated || state.status == AuthStatus.authorized) {
            setState(() {
              _isGoogleAction = false;
              _googleEmail = null;
              _googleName = null;
            });
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.sagePrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      size: 64,
                      color: AppColors.sagePrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('AgroLedger', style: AppTextStyles.h1),
                const SizedBox(height: 48),
                SoftCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Вход в систему', style: AppTextStyles.h2),
                        const SizedBox(height: 24),
                        AnimatedInputField(
                          controller: _emailController,
                          label: 'Email или Телефон',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) => (v == null || v.isEmpty) ? 'Введите данные' : null,
                        ),
                        const SizedBox(height: 16),
                        AnimatedInputField(
                          controller: _passwordController,
                          label: 'Пароль',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (v) => (v == null || v.length < 8) ? 'Минимум 8 символов' : null,
                        ),
                        const SizedBox(height: 32),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state.status == AuthStatus.loading && !_isGoogleAction;
                            return ElevatedButton(
                              onPressed: state.status == AuthStatus.loading ? null : _onLogin,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Войти'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.sageLight.withValues(alpha: 0.2))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('или', style: AppTextStyles.caption),
                            ),
                            Expanded(child: Divider(color: AppColors.sageLight.withValues(alpha: 0.2))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isGoogleLoading = state.status == AuthStatus.loading && _isGoogleAction;
                            return GoogleSignInButton(
                              isLoading: isGoogleLoading,
                              onPressed: (state.status == AuthStatus.loading)
                                  ? null
                                  : _onGoogleSignIn,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Нет аккаунта?', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Зарегистрироваться'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
