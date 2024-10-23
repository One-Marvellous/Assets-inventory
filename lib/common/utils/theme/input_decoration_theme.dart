import 'package:flutter/material.dart';

class GInputDecorationTheme {
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
      constraints: const BoxConstraints(minHeight: 44),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 12,
          borderSide: const BorderSide(width: 1, color: Color(0xffeeeeee))
          ),
      hintStyle: const TextStyle(
        color: Color(0xffC4C4C4),
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 12,
          borderSide: const BorderSide(width: 1, color: Color(0xffeeeeee))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 12,
          borderSide: const BorderSide(width: 1, color: Color(0xffeeeeee))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 12,
          borderSide: const BorderSide(width: 1, color: Color(0xffeeeeee))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 12,
          borderSide: const BorderSide(width: 1, color: Color(0xffeeeeee))));
}
