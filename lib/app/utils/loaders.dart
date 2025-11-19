import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader1 extends StatelessWidget {
  final double? size;
  final Color? color;
  const Loader1({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.progressiveDots(
        color: color ?? AppColors.primaryColor,
        size: size ?? 50,
      ),
    );
  }
}


class Loader2 extends StatelessWidget {
  final double? size;
  final Color? color;
  const Loader2({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        color: color ?? AppColors.primaryColor,
        size: size ?? 50,
      ),
    );
  }
}
