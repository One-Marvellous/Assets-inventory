import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LinkText extends StatelessWidget {
  final String? preText;
  final String linkText;
  final double? fontSize;
  final Color linkColor;
  final Function() onTap;

  const LinkText({
    super.key,
    this.preText,
    required this.linkText,
    this.fontSize,
    this.linkColor = Colors.green,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final color = Theme.of(context).colorScheme.primary;

    final linkStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: linkColor, fontSize: fontSize, fontWeight: FontWeight.w600);

    final preTextStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: const Color(0xff666666),
        fontSize: fontSize,
        fontWeight: FontWeight.w300);

    return Text.rich(TextSpan(children: [
      TextSpan(text: preText, style: preTextStyle),
      TextSpan(
        text: linkText,
        style: linkStyle,
        recognizer: TapGestureRecognizer()..onTap = onTap,
      )
    ]));
  }
}
