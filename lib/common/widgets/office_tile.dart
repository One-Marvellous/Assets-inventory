import 'package:flutter/material.dart';

class OfficeTile extends StatelessWidget {
  const OfficeTile({super.key, required this.name, this.onTap});
  final String name;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: ListTile(
        tileColor: Colors.white70,
        title: Text(name),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios_outlined),
      ),
    );
  }
}
