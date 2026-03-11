import 'package:flutter/material.dart';

/// Reusable form input field built on [TextFormField].
/// Automatically picks up all styles from [ThemeData.inputDecorationTheme].
class FormInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final String? errorText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool autofocus;

  const FormInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.maxLines,
    this.minLines,
    this.errorText,
    this.keyboardType,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLines: obscureText ? 1 : (maxLines ?? 1),
      minLines: minLines ?? 1,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return '${label ?? 'This field'} is required';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
