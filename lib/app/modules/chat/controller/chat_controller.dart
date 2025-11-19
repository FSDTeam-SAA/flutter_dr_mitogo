import 'dart:async';
import 'dart:io';
import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/controller/socket_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/data/services/message_service.dart';
import 'package:casarancha/app/modules/chat/controller/audio_controller.dart';
import 'package:casarancha/app/modules/chat/controller/chat_media_controller.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

class ChatController extends GetxController {
  final messageController = Get.find<MessageController>();
  final socketController = Get.find<SocketController>();
  final userController = Get.find<UserController>();

  late AudioController audioController;
  late ChatMediaPickerHelper mediaController;

  final TextEditingController textMessageController = TextEditingController();
  final RxString wordsTyped = "".obs;
  final RxBool isUploading = false.obs;
  late ChatListModel chatHead;
  Rxn<MessageModel> replyToMessage = Rxn<MessageModel>(null);

  // Scroll position tracking
  final RxBool isAtBottom = true.obs;
  final RxBool showScrollToBottomButton = false.obs;
  final scrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  //Cache-System
  final Map<String, Uint8List> _cache = {};
  Uint8List? get(String url) => _cache[url];
  void set(String url, Uint8List data) => _cache[url] = data;

  final isVisible = true.obs;
  Timer? _visibilityTimer;

  final RxBool showEmojiPicker = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    audioController = Get.put(AudioController());
    mediaController = Get.put(ChatMediaPickerHelper());
  }

  RxBool canScroll = false.obs;

  void scrollToBottom() async {
    if (scrollController.isAttached &&
        messageController.chatHistoryAndLiveMessage.isNotEmpty) {
      return scrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _setupScrollListener() {
    itemPositionsListener.itemPositions.addListener(() {
      _updateScrollPosition();
    });
  }

  void _updateScrollPosition() {
    final positions = itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisibleIndex = positions.first.index;
    final isCurrentlyAtBottom = firstVisibleIndex == 0;

    isAtBottom.value = isCurrentlyAtBottom;
    showScrollToBottomButton.value = !isCurrentlyAtBottom;

    // Show button when user scrolls away from bottom
    if (!isCurrentlyAtBottom) {
      isVisible.value = true;
      // Cancel previous timer if it exists
      _visibilityTimer?.cancel();
      // Start new timer to hide button after 3 seconds
      _visibilityTimer = Timer(const Duration(seconds: 3), () {
        isVisible.value = false;
      });
    } else {
      // Hide button immediately when at bottom
      isVisible.value = false;
      _visibilityTimer?.cancel();
    }
  }

  void scrollToMessage(String? messageId) {
    final messageController = Get.find<MessageController>();
    if (messageId == null) return;
    final messageIndex = messageController.chatHistoryAndLiveMessage
        .indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return;
    final reversedIndex =
        messageController.chatHistoryAndLiveMessage.length - 1 - messageIndex;
    scrollController.scrollTo(
      index: reversedIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1, // Show item at 10% from top
    );
    Future.delayed(const Duration(milliseconds: 600), () {
      _highlightMessage(messageId);
    });
  }

  void _highlightMessage(String messageId) {
    final messageController = Get.find<MessageController>();
    messageController.highlightedMessageId.value = messageId;
    messageController.highlightOpacity.value = 1.0;

    Future.delayed(const Duration(seconds: 2), () async {
      for (double i = 1.0; i >= 0; i -= 0.1) {
        await Future.delayed(const Duration(milliseconds: 100));
        messageController.highlightOpacity.value = i;
      }
      messageController.highlightedMessageId.value = null;
    });
  }

  void initialize(ChatListModel chat) {
    chatHead = chat;
    if (socketController.socket == null ||
        socketController.socket?.disconnected == true) {
      socketController.initializeSocket();
    }
    _setupSocketListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await messageController.getMessageHistory(
        receiverUserId: chatHead.userId ?? "",
      );
    });
    messageController.chatHistoryAndLiveMessage.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isAtBottom.value && canScroll.value) {
          scrollToBottom();
        }
        socketController.markMessageRead(chatHead.userId ?? "");
      });
    });
    canScroll.value = false;
  }

  void _setupSocketListeners() {
    socketController.socket?.on("typing", (data) {
      if (data["senderId"] == chatHead.userId) {
        final messages = messageController.chatHistoryAndLiveMessage;
        if (messages.isNotEmpty && messages.last.status == "typing") {
          return;
        }
        messageController.chatHistoryAndLiveMessage.add(
          MessageModel(status: "typing", receiverId: chatHead.userId),
        );
      }
    });

    socketController.socket?.on("stop-typing", (data) {
      if (data["senderId"] == chatHead.userId) {
        final messages = messageController.chatHistoryAndLiveMessage;
        if (messages.isNotEmpty && messages.last.status == "typing") {
          // Remove typing indicator without triggering full rebuilds
          messageController.chatHistoryAndLiveMessage.removeWhere(
            (msg) => msg.status == "typing",
          );
        }
      }
    });
  }

  void handleTyping(String value) {
    wordsTyped.value = value;
    String receiverId = chatHead.userId ?? "";
    if (value.isNotEmpty) {
      socketController.typing(receiverId: receiverId);
    } else {
      socketController.stopTyping(receiverId: receiverId);
    }
  }

  Future<void> sendMessage() async {
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();
    mediaController.showMediaPreview.value = false;
    audioController.showAudioPreview.value = false;

    if (audioController.isPlaying.value) {
      await audioController.pauseRecording();
    }
    if (audioController.isRecording.value) {
      audioController.isRecording.value = false;
      await audioController.pauseRecording();
    }

    final String messageText = textMessageController.text.trim();
    if (messageText.isEmpty &&
        mediaController.selectedFile.value == null &&
        audioController.selectedFile.value == null &&
        mediaController.multipleMediaSelected.isEmpty) {
      return;
    }

    if (chatHead.userId == null) {
      CustomSnackbar.showErrorToast("User not found");
      return;
    }

    final tempId = const Uuid().v4();
    final messageModel = MessageModel(
      receiverId: chatHead.userId ?? "",
      message: messageText,
      messageType: "text",
      clientGeneratedId: tempId,
      replyToMessage: replyToMessage.value,
    );

    final multipleIMages = mediaController.multipleMediaSelected;
    dynamic selectedFile = mediaController.selectedFile.value ??
        audioController.selectedFile.value;
    if (multipleIMages.isNotEmpty && multipleIMages.length == 1) {
      selectedFile = multipleIMages[0];
      multipleIMages.clear();
    }

    if (selectedFile != null) {
      isUploading.value = true;
      final messageType = mediaController.getFileType(selectedFile.path) ??
          audioController.getFileType(selectedFile.path) ??
          "image";

      final tempMessage = MessageModel(
        receiverId: chatHead.userId ?? "",
        message: messageText,
        messageType: messageType,
        senderId: userController.userModel.value!.id,
        status: "sending",
        tempFile: selectedFile,
        clientGeneratedId: tempId,
      );

      messageController.chatHistoryAndLiveMessage.add(tempMessage);

      dynamic res = await MessageService().uploadMedia(selectedFile);
      if (res == null) {
        isUploading.value = false;
        CustomSnackbar.showErrorToast("Error Uploading Media");
        return;
      }
      String? mediaUrl = res["mediaUrl"];
      String? uploadedMessageType = res["messageType"];
      String? mediaIv = res["mediaIv"];

      isUploading.value = false;

      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        messageModel.mediaUrl = mediaUrl;
        messageModel.messageType = uploadedMessageType;
        messageModel.mediaIv = mediaIv;

        tempMessage.mediaUrl = mediaUrl;
        tempMessage.messageType = uploadedMessageType;
        tempMessage.mediaIv = mediaIv;
        tempMessage.status = "sent";
        // messageController.chatHistoryAndLiveMessage.refresh();
      }
    }

    if (multipleIMages.isNotEmpty) {
      // isUploading.value = true;
      final tempMessage = MessageModel(
        receiverId: chatHead.userId ?? "",
        message: messageText,
        messageType: "image",
        senderId: userController.userModel.value!.id,
        status: "sending",
        tempFile: selectedFile,
        clientGeneratedId: tempId,
        multipleImages: multipleIMages.map((e) {
          return MultipleImages(
            mediaIv: "",
            mediaUrl: File(e.path),
            filename: e.path,
            mimetype: "image",
          );
        }).toList(),
      );

      messageController.chatHistoryAndLiveMessage.add(tempMessage);

      dynamic res =
          await MessageService().uploadMultiplePictures(multipleIMages);
      if (res == null) {
        isUploading.value = false;
        CustomSnackbar.showErrorToast("Error Uploading Pictures");
        return;
      }
      List mediaUrls = res["mediaObjects"] ?? [];
      if (mediaUrls.isEmpty) return;
      // isUploading.value = false;
      final multipleImages =
          mediaUrls.map((e) => MultipleImages.fromJson(e)).toList();

      // messageModel.mediaUrl = mediaUrl;
      // messageModel.messageType = uploadedMessageType;
      // messageModel.mediaIv = mediaIv;
      messageModel.multipleImages = multipleImages;
      messageModel.messageType = "image";

      // tempMessage.mediaUrl = mediaUrl;
      // tempMessage.messageType = uploadedMessageType;
      // tempMessage.mediaIv = mediaIv;
      tempMessage.status = "sent";
    }
    // Send the message
    socketController.sendMessage(message: messageModel);
    replyToMessage.value = null;
    scrollToBottom();
    socketController.stopTyping(receiverId: messageModel.receiverId ?? "");

    // Clear input
    textMessageController.clear();
    wordsTyped.value = "";
    mediaController.resetState();
    audioController.resetState();
  }

  void closeScreen() {
    messageController.getChatList(showLoading: false);
    socketController.stopTyping(receiverId: chatHead.userId ?? "");
    final userId = chatHead.userId;
    if (userId == null || userId.isEmpty) return;
    if (messageController.chatHistoryAndLiveMessage.isEmpty) return;
    final clonedMessages = [...messageController.chatHistoryAndLiveMessage];
    messageController.savedChatToAvoidLoading[userId] =
        RxList<MessageModel>.from(
      clonedMessages,
    );
    messageController.chatHistoryAndLiveMessage.clear();
    textMessageController.clear();
  }

  @override
  void onClose() {
    _visibilityTimer?.cancel();
    closeScreen();
    super.onClose();
  }
}
