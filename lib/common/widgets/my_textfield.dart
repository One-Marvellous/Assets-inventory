import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    super.key,
    required this.controller,
    this.hintText,
    this.expands = false,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.autovalidateMode,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String? hintText;
  final bool expands;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: autovalidateMode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      enabled: enabled,
      validator: validator,
      expands: expands,
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        border: InputBorder.none,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
