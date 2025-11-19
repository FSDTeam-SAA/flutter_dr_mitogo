import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageContainerWidget extends StatelessWidget {
  final Widget child;
  final bool isReceiver;
  final MessageType messageType;
  final MessageModel messageModel;

  MessageContainerWidget({
    super.key,
    required this.child,
    this.isReceiver = false,
    required this.messageType,
    required this.messageModel,
  });

  final _messageController = Get.find<MessageController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHighlighted =
          _messageController.highlightedMessageId.value == messageModel.id;
      final opacity =
          isHighlighted ? _messageController.highlightOpacity.value : 0.0;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isHighlighted ? 1.02 : 1.0),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: _getPadding(messageType),
        constraints: _getConstraits(messageType),
        width: messageType == MessageType.audio ? Get.width * 0.8 : null,
        decoration: BoxDecoration(
          color: _getCardColor(isReceiver, isHighlighted, opacity),
          border: _getBorder(isReceiver, isHighlighted),
          gradient: _getCardGradient(isReceiver, isHighlighted),
          borderRadius: BorderRadius.circular(10),
          boxShadow: _getBoxShadow(isReceiver, isHighlighted),
        ),
        child: IntrinsicWidth(child: child),
      );
    });
  }

  List<BoxShadow>? _getBoxShadow(bool isReceiver, bool isHighlighted) {
    if (!isReceiver && isHighlighted) {
      return [
        const BoxShadow(
          color: AppColors.senderHighlightShadow,
          blurRadius: 25,
          offset: Offset(0, 8),
        ),
      ];
    }
    if (isReceiver && isHighlighted) {
      return [
        const BoxShadow(
          color: AppColors.receiverHighlightShadow,
          blurRadius: 25,
          offset: Offset(0, 8),
        ),
      ];
    }
    return null;
  }

  BoxBorder? _getBorder(bool isReceiver, bool isHighlighted) {
    if (isReceiver && isHighlighted) {
      return Border.all(color: AppColors.receiverHighlightBorder, width: 2);
    }
    if (isReceiver && !isHighlighted) {
      return Border.all(color: AppColors.receiverBorder, width: 1);
    }
    return null;
  }

  Color? _getCardColor(bool isReceiver, bool isHighlighted, double opacity) {
    if (isReceiver && isHighlighted) {
      return const Color.fromARGB(255, 238, 203, 200).withOpacity(opacity);
    }
    if (isReceiver && !isHighlighted) {
      return const Color.fromARGB(255, 238, 203, 200);
    }
    return null;
  }

  BoxConstraints? _getConstraits(MessageType messageType) {
    if (messageType == MessageType.image || messageType == MessageType.video) {
      return BoxConstraints(maxWidth: Get.width * 0.558);
    }
    if (messageType == MessageType.audio) {
      return null;
    }
    return BoxConstraints(maxWidth: Get.width * 0.68);
  }

  LinearGradient? _getCardGradient(bool isReceiver, bool isHighlighted) {
    if (!isReceiver && isHighlighted) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryColor, Color.fromARGB(185, 231, 18, 15)],
      );
    }
    if (!isReceiver && isHighlighted == false) {
      return const LinearGradient(

        colors: [AppColors.primaryColor, AppColors.primaryColor],
      );
    }
    return null;
  }

  EdgeInsets _getPadding(MessageType messageType) {
    switch (messageType) {
      case MessageType.image:
        return _imagePadding();
      case MessageType.video:
        return _videoPadding();
      default:
        return const EdgeInsets.symmetric(horizontal: 7, vertical: 6);
    }
  }

  EdgeInsets _imagePadding() {
    return const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5);
  }

  EdgeInsets _videoPadding() {
    return const EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 5);
  }
}
