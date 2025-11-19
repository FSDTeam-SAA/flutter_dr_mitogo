import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/enums/message_enum_type.dart';
import 'package:casarancha/app/modules/chat/shimmer/video_shimmer_loader.dart';
import 'package:casarancha/app/modules/chat/widgets/animated/animated_widgets.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/get_thumbnail_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ReplyToContent extends StatelessWidget {
  final ChatController controller;
  final ChatListModel? chatHead;
  final MessageModel? messageModel;
  final bool isSender;
  ReplyToContent({
    super.key,
    required this.controller,
    this.chatHead,
    this.messageModel,
    required this.isSender,
  });

  final _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    if (messageModel != null) {
      return InkWell(
        onTap: () {
          controller.scrollToMessage(messageModel!.id);
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.09,
            minWidth: Get.width * 0.4,
          ),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _getColor(messageModel: messageModel, isSender: isSender),
            borderRadius: BorderRadius.circular(10),
            border: Border(
              left: BorderSide(
                color: AppColors.primaryColor,
                width: 4,
              ),
            ),
          ),
          child: IntrinsicHeight(
            child: _buildContent(
              messageModel: messageModel,
              showDeteIcon: false,
            ),
          ),
        ),
      );
    }
    return Obx(() {
      if (controller.replyToMessage.value != null) {
        final messageModel = controller.replyToMessage.value;
        return Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.99,
            maxWidth: Get.width,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 3,
          ),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey.shade400.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border(
              left: BorderSide(
                color: AppColors.primaryColor,
                width: 4,
              ),
            ),
          ),
          child: IntrinsicHeight(
            child: _buildContent(messageModel: messageModel),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Color _getColor({
    required MessageModel? messageModel,
    required bool isSender,
  }) {
    if (messageModel == null) {
      return Colors.transparent;
    }
    return isSender
        ? const Color.fromARGB(255, 116, 70, 2).withOpacity(0.4)
        : Colors.grey.shade400.withOpacity(0.7);
  }

  Widget _buildContent({
    MessageModel? messageModel,
    bool? showDeteIcon = true,
  }) {
    final senderId = _userController.userModel.value?.id ?? "";
    final isSender = messageModel?.senderId == senderId;
    if (messageModel == null) {
      return const SizedBox.shrink();
    }
    final messageType = getMessageType(messageModel.messageType);
    if (messageType == MessageType.text &&
        messageModel.message != null &&
        messageModel.storyMediaUrl?.isEmpty == true) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender
                      ? "You"
                      : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  messageModel.message!.length > 100
                      ? "${messageModel.message!.substring(0, 90)}.."
                      : messageModel.message!,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4)
              ],
            ),
          ),
          if (showDeteIcon == true)
            InkWell(
              onTap: () {
                controller.replyToMessage.value = null;
              },
              child: const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 26,
              ),
            ),
        ],
      );
    }
    if (messageType == MessageType.audio) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSender
                    ? "You"
                    : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  // color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "🎤 Voice message",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
          const Spacer(),
          if (showDeteIcon == true)
            InkWell(
              onTap: () {
                controller.replyToMessage.value = null;
              },
              child: const Icon(
                Icons.cancel,
                color: Colors.grey,
                size: 26,
              ),
            ),
        ],
      );
    }
    if (messageType == MessageType.image &&
        (messageModel.multipleImages == null ||
            messageModel.multipleImages!.isEmpty)) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender
                      ? "You"
                      : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  messageModel.message != null &&
                          messageModel.message!.isNotEmpty
                      ? messageModel.message!
                      : "Photo",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: messageModel.mediaUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return SizedBox(
                        width: 45,
                        height: 40,
                        child: buildShimmerVideoLoading(),
                      );
                    },
                    width: 45,
                    height: 40,
                  ),
                ),
              ),
              if (showDeteIcon == true)
                Positioned(
                  right: 0,
                  top: -2,
                  child: InkWell(
                    onTap: () {
                      controller.replyToMessage.value = null;
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }
    if (messageType == MessageType.video) {
      final cached = controller.get(messageModel.mediaUrl ?? "");
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender
                      ? "You"
                      : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  messageModel.message != null &&
                          messageModel.message!.isNotEmpty
                      ? messageModel.message!
                      : "Video",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Stack(
            children: [
              cached != null
                  ? _buildThumbnailWidget(cached)
                  : FutureBuilder(
                      future: generateThumbnail(messageModel.mediaUrl ?? ""),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox(
                            width: 45,
                            height: 40,
                            child: buildShimmerVideoLoading(),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const AnimatedVideoPreview(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                          );
                        }
                        return _buildThumbnailWidget(snapshot.data!);
                      },
                    ),
              if (showDeteIcon == true)
                Positioned(
                  right: -1,
                  top: -2,
                  child: InkWell(
                    onTap: () {
                      controller.replyToMessage.value = null;
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }
    if (messageType == MessageType.image &&
        messageModel.multipleImages != null &&
        messageModel.multipleImages!.isNotEmpty) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender
                      ? "You"
                      : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  messageModel.message != null &&
                          messageModel.message!.isNotEmpty
                      ? messageModel.message!
                      : "Photo",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    imageUrl: messageModel.multipleImages![0].mediaUrl ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) {
                      return SizedBox(
                        width: 45,
                        height: 40,
                        child: buildShimmerVideoLoading(),
                      );
                    },
                    width: 45,
                    height: 40,
                  ),
                ),
              ),
              if (showDeteIcon == true)
                Positioned(
                  right: 0,
                  top: -2,
                  child: InkWell(
                    onTap: () {
                      controller.replyToMessage.value = null;
                    },
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    }

    if (messageModel.storyMediaUrl != null &&
        messageModel.storyMediaUrl?.isNotEmpty == true) {
      final isMediaImage = messageModel.storyMediaUrl?.contains("image");
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSender
                      ? "You"
                      : ((chatHead?.displayName?.split(" ")[0]) ?? "Unknown"),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    // color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  "Story",
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          isMediaImage == true
              ? Padding(
                  padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      imageUrl: messageModel.storyMediaUrl ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return SizedBox(
                          width: 45,
                          height: 40,
                          child: buildShimmerVideoLoading(),
                        );
                      },
                      width: 45,
                      height: 40,
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.error,
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                )
              : FutureBuilder(
                  future: generateThumbnail(messageModel.storyMediaUrl ?? ""),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 45,
                        height: 40,
                        child: buildShimmerVideoLoading(),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const AnimatedVideoPreview(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    }
                    return _buildThumbnailWidget(snapshot.data!);
                  },
                ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildThumbnailWidget(Uint8List data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedVideoPreview(
        child: Image.memory(
          data,
          width: 45,
          height: 40,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
