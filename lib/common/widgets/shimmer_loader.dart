import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Loader extends StatelessWidget {
  const Loader({super.key, required this.height, this.width = double.infinity});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: const Color(0xFFEBEBF4),
        highlightColor: const Color(0xFFEBEBF4).withOpacity(0.1),
        // loop: 5,
        enabled: true,
        // period: const Duration(milliseconds: 1500),
        child: Container(
          height: height,
          width: width,
          margin: const EdgeInsets.only(right: 5, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10),
          ),
        ));
  }
}
