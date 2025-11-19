import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:casarancha/app/modules/chat/views/view_message_media_screen.dart';
import 'package:casarancha/app/modules/chat/widgets/animated/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseMediaContentWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isReceiver;

  const BaseMediaContentWidget({
    super.key,
    required this.messageModel,
    this.isReceiver = false,
  });

  // Abstract methods
  Widget buildVideoPreview();
  Future<void> onVideoTap();
  Widget? buildSendingState() => null;

  // Computed properties
  double get mediaWidth => Get.width * 0.558;
  double get mediaHeight => Get.height * 0.32;
  Color get playIconColor => isReceiver ? Colors.black54 : Colors.white;
  Color get videoBackgroundColor => isReceiver
      ? Colors.black.withOpacity(0.1)
      : Colors.black.withOpacity(0.2);

  @override
  Widget build(BuildContext context) {
    if (messageModel.status == "sending") {
      return buildSendingState() ?? const SizedBox.shrink();
    }

    final messageType = getMessageType(messageModel.messageType);

    switch (messageType) {
      case MessageType.image:
        return buildImageContent();
      case MessageType.video:
        return buildVideoContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildImageContent() {
    if (messageModel.mediaUrl?.isEmpty != false) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: navigateToFullScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: AnimatedImagePreview(
          imageUrl: messageModel.mediaUrl!,
          width: mediaWidth,
          height: mediaHeight,
          isSender: isReceiver,
        ),
      ),
    );
  }

  Widget buildVideoContent() {
    return InkWell(
      onTap: onVideoTap,
      child: Container(
        width: mediaWidth,
        height: mediaHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: videoBackgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            buildVideoPreview(),
          ],
        ),
      ),
    );
  }

  void navigateToFullScreen() {
    Get.to(
      transition: Transition.zoom,
      () => ViewMessageMediaScreen(message: messageModel),
    );
  }
}
