// lib/features/chat/controllers/sender_card_controller.dart
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_media_controller.dart';
import 'package:casarancha/app/modules/chat/controller/media_player_controller.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class SenderCardController extends GetxController {
  final MessageModel messageModel;
  SenderCardController({required this.messageModel});
  final RxDouble scale = 1.0.obs;
  late final MediaPlayerController mediaController;
  final ChatMediaPickerHelper chatMediaController =
      Get.find<ChatMediaPickerHelper>();

  @override
  void onInit() {
    super.onInit();
    mediaController =
        Get.put(MediaPlayerController(), tag: 'sender${messageModel.id}');
  }

  Future<void> onLongPress() async {
    scale.value = 0.96;
    await Future.delayed(const Duration(milliseconds: 100));
    scale.value = 1.0;
    HapticFeedback.lightImpact();
    // TODO: Show reactions UI here in the future
  }

  Future<void> ensureControllerInitialized(MessageModel messageModel) async {
    if (mediaController.hasInitialized.value) return;

    final messageType = getMessageType(messageModel.messageType);
    final mediaUrl = messageModel.mediaUrl;

    if (mediaUrl == null || mediaUrl.isEmpty) return;

    switch (messageType) {
      case MessageType.video:
        await mediaController.initializeVideoController(mediaUrl);
        break;
      case MessageType.audio:
        await mediaController.initializeAudioController(mediaUrl);
        break;
      default:
        break;
    }
  }

  void handleMediaUrlChange(String? newUrl, String? oldUrl) {
    if (newUrl != oldUrl) {
      mediaController.reset();
    }
  }

  @override
  void onClose() {
    Get.delete<MediaPlayerController>(tag: 'sender${messageModel.id}');
    super.onClose();
  }
}
