import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/controller/receiver_card_controller.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:casarancha/app/modules/chat/widgets/media/receiver_audio_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/media/receiver_media_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/chat_image_gallery.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/message_container_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/message_timestamp_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/reply_to_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/swipeable_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/typing_indicator_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiverCard extends StatefulWidget {
  final MessageModel messageModel;
  final ChatController chatController;
  final ChatListModel chatHead;

  const ReceiverCard({
    super.key,
    required this.messageModel,
    required this.chatController,
    required this.chatHead,
  });

  @override
  State<ReceiverCard> createState() => _ReceiverCardState();
}

class _ReceiverCardState extends State<ReceiverCard>
    with AutomaticKeepAliveClientMixin {
  late final ReceiverCardController controller;
  String? _oldMediaUrl;
  final Map<String, bool> _expandedStates = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ReceiverCardController(messageModel: widget.messageModel),
      tag: widget.messageModel.id,
    );
    _oldMediaUrl = widget.messageModel.mediaUrl;
  }

  @override
  void didUpdateWidget(ReceiverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messageModel.mediaUrl != widget.messageModel.mediaUrl) {
      controller.handleMediaUrlChange(
        widget.messageModel.mediaUrl,
        _oldMediaUrl,
      );
      _oldMediaUrl = widget.messageModel.mediaUrl;
    }
  }

  @override
  void dispose() {
    Get.delete<ReceiverCardController>(tag: widget.messageModel.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isTyping = widget.messageModel.status == "typing";
    return isTyping ? const TypingIndicatorWidget() : _buildMessageCard();
  }

  Widget _buildMessageCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: controller.onLongPress,
        child: Obx(() {
          final messageType = getMessageType(widget.messageModel.messageType);
          return AnimatedScale(
            scale: controller.scale.value,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: SwipeableMessage(
              isSender: false,
              onSwipe: () {
                widget.chatController.replyToMessage.value =
                    widget.messageModel;
                widget.chatController.replyToMessage.refresh();
              },
              child: MessageContainerWidget(
                isReceiver: true,
                messageType: messageType,
                messageModel: widget.messageModel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.messageModel.replyToMessage != null ||
                        (widget.messageModel.storyMediaUrl != null &&
                            widget.messageModel.storyMediaUrl?.isNotEmpty ==
                                true))
                      ReplyToContent(
                        controller: widget.chatController,
                        chatHead: widget.chatHead,
                        messageModel: widget.messageModel.replyToMessage ??
                            widget.messageModel,
                        isSender: false,
                      ),
                    if (widget.messageModel.multipleImages != null &&
                        widget.messageModel.multipleImages!.isNotEmpty)
                      ChatImageGallery(
                        imageUrls: widget.messageModel.multipleImages!,
                        messageModel: widget.messageModel,
                      ),
                    _buildContent(messageType),
                    if (widget.messageModel.message?.isNotEmpty == true)
                      _buildMessageText(),
                    MessageTimestampWidget(
                      createdAt: widget.messageModel.createdAt,
                      isReceiver: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(MessageType messageType) {
    if (messageType == MessageType.audio) {
      return ReceiverAudioContentWidget(
        messageModel: widget.messageModel,
        controller: controller,
      );
    }

    if (messageType == MessageType.image || messageType == MessageType.video) {
      return ReceiverMediaContentWidget(
        messageModel: widget.messageModel,
        controller: controller,
        chatController: widget.chatController,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageText() {
    final mType = getMessageType(widget.messageModel.messageType);
    final messageText = widget.messageModel.message ?? "";
    final messageId = widget.messageModel.id ?? "";
    final needsTruncation = messageText.length > 100;
    final isExpanded = _expandedStates[messageId] ?? false;
    return Padding(
      padding: mType == MessageType.image || mType == MessageType.video
          ? const EdgeInsets.only(left: 3.0)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isExpanded ? messageText : _getTruncatedText(messageText),
            style: const TextStyle(
              color: AppColors.receiverText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (needsTruncation)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedStates[messageId] = !isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  isExpanded ? "Show less" : "Show more",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTruncatedText(String text) {
    if (text.length <= 100) return text;
    final truncated = text.substring(0, 100);
    final lastSpaceIndex = truncated.lastIndexOf(' ');
    if (lastSpaceIndex > 80) {
      return '${truncated.substring(0, lastSpaceIndex)}...';
    } else {
      return '$truncated...';
    }
  }
}
