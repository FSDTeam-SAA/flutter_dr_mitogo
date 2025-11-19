import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

Widget buildPostSkeleton() {
  return SizedBox(
    width: Get.width,
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Header section with profile image, name, and options
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                // Profile image skeleton
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(width: 40, height: 40, color: Colors.white),
                ),
                SizedBox(width: 7),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Username skeleton
                        Container(width: 80, height: 14, color: Colors.white),
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        // Time skeleton
                        Container(width: 30, height: 10, color: Colors.white),
                      ],
                    ),
                    SizedBox(height: 3),
                    // Location skeleton
                    Container(width: 60, height: 10, color: Colors.white),
                  ],
                ),
                Spacer(),
                // Options button skeleton
                Container(width: 24, height: 24, color: Colors.white),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Post content text skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Container(
                  width: Get.width * 0.7,
                  height: 12,
                  color: Colors.white,
                ),
                SizedBox(height: 5),
                Container(
                  width: Get.width * 0.5,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Media skeleton (image/video placeholder)
          Stack(
            children: [
              Container(
                height: Get.height * 0.3,
                width: double.infinity,
                color: Colors.white,
              ),
              // Media counter skeleton (bottom right)
              Positioned(
                bottom: 8,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(width: 30, height: 13, color: Colors.white),
                ),
              ),
              // Views counter skeleton (bottom left)
              Positioned(
                left: 5,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(width: 17, height: 17, color: Colors.white),
                      SizedBox(width: 5),
                      Container(width: 25, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Action row skeleton (like, comment, share buttons)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like button skeleton
                Row(
                  children: [
                    Container(width: 20, height: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Container(width: 25, height: 12, color: Colors.white),
                  ],
                ),
                // Comment button skeleton
                Row(
                  children: [
                    Container(width: 20, height: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Container(width: 25, height: 12, color: Colors.white),
                  ],
                ),
                // Share button skeleton
                Row(
                  children: [
                    Container(width: 20, height: 20, color: Colors.white),
                    SizedBox(width: 5),
                    Container(width: 25, height: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    ),
  );
}

// Alternative version with multiple skeleton posts for ListView
Widget buildPostSkeletonList({int itemCount = 5}) {
  return ListView.separated(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: itemCount,
    separatorBuilder: (context, index) => SizedBox(height: 20),
    itemBuilder: (context, index) => buildPostSkeleton(),
  );
}
