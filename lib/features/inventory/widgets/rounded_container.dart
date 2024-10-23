import 'package:flutter/material.dart';

class IRoundContainerBtn extends StatelessWidget {
  const IRoundContainerBtn({super.key, required this.child, this.onTap});
  final Widget child;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 80,
        decoration: BoxDecoration(
            color: Colors.blueGrey, borderRadius: BorderRadius.circular(50)),
        child: Center(child: child),
      ),
    );
  }
}
