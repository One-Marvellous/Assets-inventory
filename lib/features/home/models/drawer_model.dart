import 'package:flutter/material.dart';

class DrawerModel {
  final String iconName;
  final IconData icon;
  final Widget navigationDestination;

  DrawerModel({required this.iconName, required this.icon, this.navigationDestination = const Placeholder()});
}
