import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer buildShimmerVideoLoading({bool isSender = true}) {
  return Shimmer.fromColors(
    highlightColor: isSender ? AppColors.primaryColor : Colors.white,
    baseColor: isSender ? Colors.grey.shade100.withOpacity(0.1) : Colors.grey,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Colors.grey,
      ),
      width: double.infinity,
      height: double.infinity,
    ),
  );
}
