import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Modular animated logo widget
class AnimatedLogo extends StatelessWidget {
  final String imagePath;
  final double? width;
  final BoxFit fit;
  final Animation<double> animation;

  const AnimatedLogo({
    super.key,
    required this.imagePath,
    required this.animation,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Image.asset(
            imagePath,
            fit: fit,
            width: width ?? Get.width * 0.45,
          ),
        );
      },
    );
  }
}