import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/controller/sender_card_controller.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:casarancha/app/modules/chat/widgets/media/sender_audio_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/media/sender_media_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/chat_image_gallery.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/message_container_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/message_timestamp_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/reply_to_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/swipeable_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SenderCard extends StatefulWidget {
  final MessageModel messageModel;
  final ChatListModel chatHead;

  const SenderCard({
    super.key,
    required this.messageModel,
    required this.chatHead,
  });

  @override
  State<SenderCard> createState() => _SenderCardState();
}

class _SenderCardState extends State<SenderCard>
    with AutomaticKeepAliveClientMixin {
  late final SenderCardController controller;
  String? _oldMediaUrl;
  late final ChatController _chatController;
  final Map<String, bool> _expandedStates = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chatController = Get.find<ChatController>(
      tag: widget.messageModel.receiverId,
    );
    controller = Get.put(
      SenderCardController(messageModel: widget.messageModel),
      tag: widget.messageModel.id,
    );
    _oldMediaUrl = widget.messageModel.mediaUrl;
  }

  @override
  void didUpdateWidget(SenderCard oldWidget) {
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
    Get.delete<SenderCardController>(tag: widget.messageModel.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onLongPress: controller.onLongPress,
        child: Obx(() {
          final MessageType messageType =
              getMessageType(widget.messageModel.messageType);
          return AnimatedScale(
            scale: controller.scale.value,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: SwipeableMessage(
              isSender: true,
              onSwipe: () {
                _chatController.replyToMessage.value = widget.messageModel;
                _chatController.replyToMessage.refresh();
              },
              child: MessageContainerWidget(
                messageType: messageType,
                messageModel: widget.messageModel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.messageModel.replyToMessage != null ||
                        (widget.messageModel.storyMediaUrl != null &&
                            widget.messageModel.storyMediaUrl?.isNotEmpty ==
                                true))
                      ReplyToContent(
                        controller: _chatController,
                        chatHead: widget.chatHead,
                        messageModel: widget.messageModel.replyToMessage ??
                            widget.messageModel,
                        isSender: true,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MessageTimestampWidget(
                          createdAt: widget.messageModel.createdAt,
                        ),
                        Padding(
                          padding: messageType == MessageType.image ||
                                  messageType == MessageType.video
                              ? const EdgeInsets.only(right: 5.0)
                              : EdgeInsets.zero,
                          child: Icon(
                            Icons.done_all,
                            color: widget.messageModel.status != "read"
                                ? Colors.grey.shade50
                                : const Color(0xFF66BB6A),
                            size: 14,
                          ),
                        ),
                      ],
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
    switch (messageType) {
      case MessageType.image:
      case MessageType.video:
        return SenderMediaContentWidget(
          messageModel: widget.messageModel,
          controller: controller,
          chatController: _chatController,
        );
      case MessageType.audio:
        return SenderAudioContentWidget(
          messageModel: widget.messageModel,
          controller: controller,
        );
      default:
        return const SizedBox.shrink();
    }
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
              color: AppColors.senderText,
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
                    color: AppColors.lightGrey,
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
