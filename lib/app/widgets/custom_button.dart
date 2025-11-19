import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  String? text;
  Color? bgColor;
  Color? textColor;
  final VoidCallback ontap;
  BoxBorder? border;
  BorderRadiusGeometry? borderRadius;
  double? height;
  double? width;
  Widget? child;
  RxBool isLoading;
  CustomButton({
    super.key,
    this.text,
    this.bgColor,
    required this.ontap,
    this.textColor,
    this.border,
    this.borderRadius,
    this.height,
    this.width,
    this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: height ?? 55,
        alignment: Alignment.center,
        width: width ?? Get.width,
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius ?? BorderRadius.circular(10),
          color: bgColor ?? AppColors.primaryColor,
        ),
        child: Obx(() {
          return isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : child ?? Text(text.toString(), style: Get.textTheme.bodyMedium);
        }),
      ),
    );
  }
}
