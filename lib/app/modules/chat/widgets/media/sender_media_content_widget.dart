import 'dart:typed_data';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/controller/sender_card_controller.dart';
import 'package:casarancha/app/modules/chat/shimmer/video_shimmer_loader.dart';
import 'package:casarancha/app/modules/chat/widgets/animated/animated_widgets.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/base_media_content_widget.dart';
import 'package:casarancha/app/utils/get_thumbnail_network.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SenderMediaContentWidget extends BaseMediaContentWidget {
  final SenderCardController controller;
  final ChatController chatController;

  const SenderMediaContentWidget({
    super.key,
    required super.messageModel,
    required this.controller,
    required this.chatController,
  }) : super(isReceiver: false);


  @override
  Widget buildVideoPreview() {
    final cached = chatController.get(messageModel.mediaUrl ?? "");
    if (cached != null) {
      return _buildThumbnailWidget(cached);
    }
    return FutureBuilder<Uint8List?>(
      future: generateThumbnail(messageModel.mediaUrl ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerVideoLoading();
        }
        if (snapshot.hasData) {
          chatController.set(messageModel.mediaUrl ?? "", snapshot.data!);
          return _buildThumbnailWidget(snapshot.data!);
        }
        return const AnimatedVideoPreview(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 50,
          ),
        );
      },
    );
  }

  Widget _buildThumbnailWidget(Uint8List data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedVideoPreview(
            child: Image.memory(
              data,
              width: Get.width * 0.558,
              height: Get.height * 0.32,
              fit: BoxFit.cover,
            ),
          ),
          const Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> onVideoTap() async {
    if (controller.mediaController.videoController == null) {
      await controller.ensureControllerInitialized(messageModel);
    }
    navigateToFullScreen();
  }

  @override
  Widget? buildSendingState() {
    return _buildSendingState();
  }

  Widget _buildSendingState() {
    final thumbnailData = controller.chatMediaController.thumbnailData.value;
    final tempFile = messageModel.tempFile;

    if (thumbnailData == null && tempFile == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              thumbnailData ?? tempFile!,
              width: Get.width * 0.558,
              height: Get.height * 0.32,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Center(
          child: SizedBox(
            width: 45,
            child: Loader1(),
          ),
        ),
      ],
    );
  }
}
