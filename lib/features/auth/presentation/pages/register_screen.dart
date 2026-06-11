import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_account_picker_dialog.dart';
import 'package:agroledger/features/auth/presentation/widgets/google_registration_completion_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isGoogleAction = false;
  String? _googleEmail;
  String? _googleName;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    setState(() {
      _isGoogleAction = false;
    });
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              phone: _phoneController.text.trim(),
              role: 'farmer_business', // Default role for universal access
              fullName: _nameController.text.trim(),
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
      appBar: AppBar(
        title: const Text('Создание аккаунта'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated || state.status == AuthStatus.authorized) {
            setState(() {
              _isGoogleAction = false;
              _googleEmail = null;
              _googleName = null;
            });
            // After successful registration, we are now authenticated
            // The AuthFlowController will handle the switch to PIN screen
            Navigator.of(context).pop();
          }
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
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SoftCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Ваши данные', style: AppTextStyles.h2),
                      const SizedBox(height: 24),
                      AnimatedInputField(
                        controller: _nameController,
                        label: 'ФИО',
                        prefixIcon: Icons.badge_outlined,
                        validator: (v) => (v == null || v.isEmpty) ? 'Введите имя' : null,
                      ),
                      const SizedBox(height: 16),
                      AnimatedInputField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Введите email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                            return 'Некорректный email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AnimatedInputField(
                        controller: _phoneController,
                        label: 'Телефон',
                        prefixIcon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.isEmpty) ? 'Введите телефон' : null,
                      ),
                      const SizedBox(height: 16),
                      AnimatedInputField(
                        controller: _passwordController,
                        label: 'Пароль',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.length < 8) return 'Минимум 8 символов';
                          if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Нужна заглавная буква';
                          if (!RegExp(r'\d').hasMatch(v)) return 'Нужна цифра';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading && !_isGoogleAction;
                          return ElevatedButton(
                            onPressed: state.status == AuthStatus.loading ? null : _onRegister,
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Создать аккаунт'),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
