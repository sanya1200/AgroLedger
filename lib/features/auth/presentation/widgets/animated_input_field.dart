import 'package:flutter/material.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

class AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.bodyMax,
        validator: widget.validator,
        maxLines: widget.isPassword ? 1 : widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isFocused ? 1.0 : 0.5,
            child: Icon(
              widget.prefixIcon,
              color: _isFocused ? AppColors.sagePrimary : AppColors.textLight,
            ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      key: ValueKey(_obscureText),
                      color: _isFocused ? AppColors.sagePrimary : AppColors.textLight,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
