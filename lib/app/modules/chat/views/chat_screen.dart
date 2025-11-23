import 'dart:ui';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/shimmer/chat_loader_shimmer.dart';
import 'package:casarancha/app/modules/chat/widgets/receiver_card.dart';
import 'package:casarancha/app/modules/chat/widgets/sender_card.dart';
import 'package:casarancha/app/modules/chat/widgets/textfield/chat_input_field_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:casarancha/app/modules/chat/widgets/media/media_preview_widget.dart';

class ChatScreen extends StatefulWidget {
  final ChatListModel chatHead;
  const ChatScreen({super.key, required this.chatHead});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = Get.put(ChatController(), tag: widget.chatHead.userId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatController.initialize(widget.chatHead);
    });
  }

  @override
  void dispose() {
    Get.delete<ChatController>(tag: widget.chatHead.userId);
    _chatController.closeScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: Stack(
                children: [_buildMessageList(), _buildScrollDownButton()],
              ),
            ),
            // _buildReceiverCard(),
            // const SizedBox(height: 10),
            // _buildSenderCard(),
            Divider(),
            Obx(() {
              if (_chatController.mediaController.showMediaPreview.value) {
                return MediaPreviewWidget(
                  controller: _chatController.mediaController,
                );
              }
              return const SizedBox();
            }),
            NewChatInputFields(
              controller: _chatController,
              chatHead: widget.chatHead,
            ),
            // _buildInputFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollDownButton() {
    return Obx(() {
      final shouldShow =
          _chatController.showScrollToBottomButton.value &&
          _chatController.isVisible.value;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        bottom: shouldShow ? 20 : -100,
        right: 20,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          opacity: shouldShow ? 1.0 : 0.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            scale: shouldShow ? 1.0 : 0.8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _chatController.scrollToBottom();
                      },
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMessageList() {
    return Obx(() {
      final messageController = _chatController.messageController;
      final savedChatToAvoidLoading = messageController.savedChatToAvoidLoading;
      List<MessageModel> oldChats =
          savedChatToAvoidLoading[widget.chatHead.userId] ?? [];
      final chatHistoryAndLiveMessage =
          messageController.chatHistoryAndLiveMessage;
      if (oldChats.isEmpty && messageController.isloading.value) {
        return const ChatShimmerEffect(
          itemCount: 20,
          showSenderCards: true,
          showReceiverCards: true,
          // showImageCards: true,
          // showAudioCards: true,
        );
      }

      if (oldChats.isNotEmpty && messageController.isloading.value) {
        return _buildMessageListView(oldChats);
      }

      if (chatHistoryAndLiveMessage.isEmpty && oldChats.isEmpty) {
        return Center(child: Text("no_message".tr));
      }

      return _buildMessageListView(chatHistoryAndLiveMessage);
    });
  }

  Widget _buildMessageListView(List<MessageModel> messages) {
    return ScrollablePositionedList.builder(
      key: PageStorageKey<String>('chat_list_${widget.chatHead.userId}'),
      itemScrollController: _chatController.scrollController,
      itemPositionsListener: _chatController.itemPositionsListener,
      itemCount: messages.length,
      reverse: true,
      // cacheExtent: 1000,
      physics: const AlwaysScrollableScrollPhysics(),
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final isSender =
            message.senderId ==
            _chatController.userController.userModel.value!.id;
        final bubble =
            isSender
                ? RepaintBoundary(
                  child: SenderCard(
                    messageModel: message,
                    chatHead: widget.chatHead,
                  ),
                )
                : RepaintBoundary(
                  child: ReceiverCard(
                    messageModel: message,
                    chatController: _chatController,
                    chatHead: widget.chatHead,
                  ),
                );
        if (index == 0) {
          return TweenAnimationBuilder<Offset>(
            key: ValueKey(
              message.id ?? message.createdAt?.toIso8601String() ?? index,
            ),
            tween: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: Offset(0, offset.dy * 50),
                child: child,
              );
            },
            child: bubble,
          );
        } else {
          return bubble;
        }
      },
    );
  }

  Align buildSenderCard() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onLongPress: () {
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(maxWidth: Get.width * 0.6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum est a, mattis tellus. ",
                        style: Get.textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "12:30 PM",
                    style: Get.textTheme.bodySmall!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage("assets/images/jao.jpg"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReceiverCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage("assets/images/jao.jpg"),
              ),
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onLongPress: () {
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: Get.width * 0.6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 238, 203, 200),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum est a, mattis tellus. ",
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "12:30 PM",
                  style: Get.textTheme.bodySmall!.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Row buildInputFields() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: Padding(
  //           padding: const EdgeInsets.only(
  //             left: 10,
  //             top: 10,
  //             bottom: 10,
  //             right: 5,
  //           ),
  //           child: CustomTextField(
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: BorderSide.none,
  //             ),
  //             hintText: "write_reply".tr,
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               borderSide: BorderSide.none,
  //             ),
  //             bgColor: Color.fromARGB(255, 240, 240, 243),
  //             suffixIcon: Icons.attach_file,
  //             suffixIconcolor: Colors.grey,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 10),
  //       Container(
  //         height: 50,
  //         width: 50,
  //         margin: const EdgeInsets.only(right: 15),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border.all(width: 1, color: Colors.grey.shade300),
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //         child: InkWell(
  //           onTap: () {
  //             HapticFeedback.lightImpact();
  //           },
  //           child: Icon(Icons.mic, color: AppColors.primaryColor),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(widget.chatHead.avatar ?? ""),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chatHead.displayName ?? "",
                style: Get.textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                widget.chatHead.online ?? false ? "Online" : "Offline",
                style: Get.textTheme.bodySmall!.copyWith(
                  color:
                      widget.chatHead.online ?? false
                          ? Colors.green
                          : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Icon(CupertinoIcons.video_camera, size: 35),
        // SizedBox(width: 10),
        // Icon(CupertinoIcons.phone, size: 22),
        // SizedBox(width: 10),
        // Icon(Icons.more_vert),
        // SizedBox(width: 10),
      ],
    );
  }
}
