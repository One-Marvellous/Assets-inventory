import 'package:flutter/material.dart';

class TextFieldDescription extends StatelessWidget {
  const TextFieldDescription(
      {super.key, required this.text, this.fontSize = 14});
  final String text;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      // textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
