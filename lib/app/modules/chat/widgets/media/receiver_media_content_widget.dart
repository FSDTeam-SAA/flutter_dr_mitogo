import 'dart:typed_data';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/controller/receiver_card_controller.dart';
import 'package:casarancha/app/modules/chat/shimmer/video_shimmer_loader.dart';
import 'package:casarancha/app/modules/chat/widgets/animated/animated_widgets.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/base_media_content_widget.dart';
import 'package:casarancha/app/utils/get_thumbnail_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiverMediaContentWidget extends BaseMediaContentWidget {
  final ReceiverCardController controller;
  final ChatController chatController;

  const ReceiverMediaContentWidget({
    super.key,
    required super.messageModel,
    required this.controller,
    required this.chatController,
  }) : super(isReceiver: true);

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
}
