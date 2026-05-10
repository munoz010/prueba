import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  const CustomInput({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocus,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      validator: widget.validator,
      onFieldSubmitted: (_) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 15,
        ),
        // Solo borde inferior, igual al diseño
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorder, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
