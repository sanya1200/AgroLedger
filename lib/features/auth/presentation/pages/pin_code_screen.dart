import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/services/biometric_service.dart';
import 'package:agroledger/core/di/service_locator.dart';

enum PinMode { setup, verify }

class PinCodeScreen extends StatefulWidget {
  final PinMode mode;

  const PinCodeScreen({super.key, required this.mode});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  String _currentPin = "";
  String _firstPin = ""; 
  bool _isConfirming = false;
  final _biometricService = sl<BiometricService>();
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isAvailable();
    if (mounted) setState(() => _biometricsAvailable = available);
  }

  void _handleKeyPress(String value) {
    if (_currentPin.length < 4) {
      setState(() => _currentPin += value);
      if (_currentPin.length == 4) {
        _processFullPin();
      }
    }
  }

  void _handleBackspace() {
    if (_currentPin.isNotEmpty) {
      setState(() => _currentPin = _currentPin.substring(0, _currentPin.length - 1));
    }
  }

  void _processFullPin() {
    if (widget.mode == PinMode.setup) {
      if (!_isConfirming) {
        setState(() {
          _firstPin = _currentPin;
          _currentPin = "";
          _isConfirming = true;
        });
      } else {
        if (_currentPin == _firstPin) {
          context.read<AuthBloc>().add(AuthPinSetupRequested(pin: _currentPin));
        } else {
          _showError('ПИН-коды не совпадают');
          setState(() {
            _currentPin = "";
            _isConfirming = false;
            _firstPin = "";
          });
        }
      }
    } else {
      context.read<AuthBloc>().add(AuthPinSignInRequested(pin: _currentPin));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorSoft, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _handleBiometric() async {
    if (widget.mode == PinMode.verify && _biometricsAvailable) {
      final authenticated = await _biometricService.authenticateWithBiometrics();
      if (authenticated && mounted) {
        context.read<AuthBloc>().add(AuthBiometricSignInRequested());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.mode == PinMode.verify
        ? "Введите ПИН-код"
        : (_isConfirming ? "Повторите ПИН-код" : "Придумайте ПИН-код");

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            setState(() => _currentPin = "");
            _showError(state.errorMessage!);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Text(title, style: AppTextStyles.h2),
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _PinIndicator(isActive: index < _currentPin.length)),
              ),
              
              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var j = 1; j <= 3; j++)
                              _PinButton(
                                label: (i * 3 + j).toString(),
                                onTap: () => _handleKeyPress((i * 3 + j).toString()),
                              ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _PinButton(
                          icon: Icons.fingerprint_rounded,
                          onTap: _handleBiometric,
                          isVisible: widget.mode == PinMode.verify && _biometricsAvailable,
                        ),
                        _PinButton(
                          label: "0",
                          onTap: () => _handleKeyPress("0"),
                        ),
                        _PinButton(
                          icon: Icons.backspace_outlined,
                          onTap: _handleBackspace,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinIndicator extends StatelessWidget {
  final bool isActive;
  const _PinIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isActive ? AppColors.sagePrimary : AppColors.sageLight.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppColors.sagePrimary : AppColors.sageLight.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      transform: isActive ? Matrix4.diagonal3Values(1.2, 1.2, 1.0) : Matrix4.identity(),
    );
  }
}

class _PinButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isVisible;

  const _PinButton({
    this.label,
    this.icon,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(width: 80, height: 80);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.creamSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: label != null
              ? Text(label!, style: AppTextStyles.h1.copyWith(fontSize: 28))
              : Icon(icon, size: 28, color: AppColors.sageDark),
        ),
      ),
    );
  }
}
