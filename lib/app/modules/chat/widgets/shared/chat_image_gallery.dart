import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ChatImageGallery extends StatelessWidget {
  final List<MultipleImages> imageUrls;
  final double borderRadius;
  final MessageModel messageModel;

  const ChatImageGallery({
    super.key,
    required this.imageUrls,
    this.borderRadius = 10,
    required this.messageModel,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    return _buildImageLayout();
  }

  Widget _buildImageLayout() {
    switch (imageUrls.length) {
      case 2:
        return _buildTwoImages();
      case 3:
        return _buildThreeImages();
      case 4:
        return _buildFourImages();
      default:
        return _buildMultipleImages();
    }
  }

  Widget _buildTwoImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: Get.width * 0.558,
            height: Get.height * 0.25,
            child: Row(
              children: [
                Expanded(child: _buildImageContainer(0)),
                const SizedBox(width: 2),
                Expanded(child: _buildImageContainer(1)),
              ],
            ),
          ),
          messageModel.status == "sending"
              ? Container(
                  width: Get.width * 0.558,
                  height: Get.height * 0.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          messageModel.status == "sending"
              ? const Center(child: Loader1())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildThreeImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: Get.width * 0.558,
            height: Get.height * 0.25,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildImageContainer(0),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildImageContainer(1)),
                      const SizedBox(height: 2),
                      Expanded(child: _buildImageContainer(2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          messageModel.status == "sending"
              ? Container(
                  width: Get.width * 0.558,
                  height: Get.height * 0.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          messageModel.status == "sending"
              ? const Center(child: Loader1())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildFourImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: Get.width * 0.558,
        height: Get.height * 0.25,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageContainer(0)),
                      const SizedBox(width: 2),
                      Expanded(child: _buildImageContainer(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageContainer(2)),
                      const SizedBox(width: 2),
                      Expanded(child: _buildImageContainer(3)),
                    ],
                  ),
                ),
              ],
            ),
            messageModel.status == "sending"
                ? Container(
                    width: Get.width * 0.558,
                    height: Get.height * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            messageModel.status == "sending"
                ? const Center(child: Loader1())
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleImages() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: Get.width * 0.558,
            height: Get.height * 0.32,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageContainer(0)),
                      const SizedBox(width: 2),
                      Expanded(child: _buildImageContainer(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildImageContainer(2)),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Stack(
                          children: [
                            _buildImageContainer(3),
                            if (imageUrls.length > 4)
                              _buildOverlay(imageUrls.length - 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          messageModel.status == "sending"
              ? Container(
                  width: Get.width * 0.558,
                  height: Get.height * 0.32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
          messageModel.status == "sending"
              ? const Center(child: Loader1())
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildImageContainer(int index) {
    final userController = Get.find<UserController>();
    final senderId = userController.userModel.value?.id;
    bool isSender = senderId == messageModel.senderId;
    final bool isNetWorkMessage =
        imageUrls[index].mediaUrl.toString().contains("https");
    Widget imageWidget = isNetWorkMessage
        ? CachedNetworkImage(
            imageUrl: imageUrls[index].mediaUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Shimmer.fromColors(
                highlightColor:
                    isSender == false ? AppColors.primaryColor : Colors.white,
                baseColor: isSender == false
                    ? Colors.grey.shade100.withOpacity(0.1)
                    : Colors.grey,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade300,
                ),
              );
            },
          )
        : Image.file(
            imageUrls[index].mediaUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          );

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ViewChatImageGalleryFullScreen(
            imageUrls: imageUrls,
          ),
        );
      },
      child: imageWidget,
    );

    // return GestureDetector(
    //   onTap: () => onImageTap?.call(),
    //   child: Container(
    //     width: double.infinity,
    //     height: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Colors.grey[300],
    //       image: DecorationImage(
    //         image: isNetWorkMessage
    //             ? NetworkImage(imageUrls[index].mediaUrl)
    //             : FileImage(imageUrls[index].mediaUrl),
    //         fit: BoxFit.cover,
    //         onError: (error, stackTrace) {
    //           // Handle image loading error
    //         },
    //       ),
    //     ),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         gradient: LinearGradient(
    //           begin: Alignment.topCenter,
    //           end: Alignment.bottomCenter,
    //           colors: [
    //             Colors.transparent,
    //             Colors.black.withOpacity(0.1),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _buildOverlay(int remainingCount) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
      ),
      child: Center(
        child: Text(
          '+$remainingCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ViewChatImageGalleryFullScreen extends StatelessWidget {
  final List<MultipleImages> imageUrls;
  const ViewChatImageGalleryFullScreen({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final image = imageUrls[index].mediaUrl;
          return Container(
            width: Get.width,
            height: Get.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.fitWidth,
              ),
            ),
          );
        },
      ),
    );
  }
}
