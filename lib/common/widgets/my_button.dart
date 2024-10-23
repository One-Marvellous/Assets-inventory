import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? color;
  final bool disabled;
  final bool isLoading;

  const MyButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.color,
      this.disabled = false,
      this.isLoading = false});

  void onTap() {
    if (isLoading) {
      return;
    }

    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black);

    final progressIndicatorSize = textStyle.fontSize! * 1.4;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          minimumSize: Size(size.width, 50),
          backgroundColor: color ?? Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          disabledBackgroundColor: Colors.grey.withOpacity(0.25),
          padding: const EdgeInsets.all(15)),
      onPressed: onTap,
      child: isLoading
          ? SizedBox(
              height: progressIndicatorSize,
              width: progressIndicatorSize,
              child: CircularProgressIndicator(
                color: textStyle.color,
              ))
          : Text(text, style: textStyle),
    );
  }
}
