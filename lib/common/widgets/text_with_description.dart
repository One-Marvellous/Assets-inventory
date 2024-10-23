import 'package:flutter/material.dart';

class TextWithDescription extends StatelessWidget {
  const TextWithDescription(
      {super.key, required this.startText, required this.descriptionText});
  final String startText;
  final String descriptionText;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: [
      TextSpan(
        text: startText,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      TextSpan(
          text: "\n$descriptionText",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.italic,
          ))
    ]));
  }
}
