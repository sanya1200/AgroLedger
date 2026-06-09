import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navigate to Dashboard/Home
            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
          }
          if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorSoft,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Section
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.sagePrimary.withOpacity(0.1),
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
                  const SizedBox(height: 8),
                  Text(
                    'Управляйте хозяйством с умом',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                  ),
                  const SizedBox(height: 48),

                  // Login Form
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
                            validator: (v) => (v == null || v.length < 6) ? 'Минимум 6 символов' : null,
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: state is AuthLoading ? null : _onLogin,
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Войти'),
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
          );
        },
      ),
    );
  }
}
