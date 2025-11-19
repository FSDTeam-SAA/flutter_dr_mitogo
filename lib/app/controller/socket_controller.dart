// ignore_for_file: library_prefixes

import 'dart:async';
import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketController extends GetxController {
  IO.Socket? socket;
  RxBool isloading = false.obs;

  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  Future<void> initializeSocket() async {
    String? token = await StorageController().getToken();
    if (token == null) {
      return;
    }

    socket = IO.io("https://casaranche-backend-yjla.onrender.com", <String, dynamic>{
      'transports': ['websocket'],
      'extraHeaders': {'Authorization': 'Bearer $token'},
      'reconnection': true,
      "forceNew": true,
    });

    socket?.connect();

    socket?.onConnect((_) async {
      listenToEvents();
    });

    socket?.onDisconnect((_) {
      print("Socket disconnected");
      scheduleReconnect();
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        disConnectListeners();
      }
    });

    socket?.on('connect_error', (_) {
      print("Connection error");
      scheduleReconnect();
    });
  }

  void listenToEvents() {
    socket?.on("refresh", (data) async {
      final userController = Get.find<UserController>();
      await userController.getUserDetails();
    });

    // socket?.on("update-online-chat-list", (data) {
    //   final response = List.from(data);
    //   Get.find<MessageController>().activeFriends.clear();
    //   if (response.isEmpty) return;
    //   List<ChatListModel> mapped =
    //       response.map((e) => ChatListModel.fromJson(e)).toList();
    //   Get.find<MessageController>().activeFriends.value = mapped;
    //   Get.find<MessageController>().activeFriends.refresh();
    // });

    socket?.on("update-chat-list", (data) {
      Get.find<MessageController>().getChatList(showLoading: false);
    });

    socket?.on("user-offline", (data) {
      final userId = data["userId"] as String;
      Get.find<MessageController>()
          .activeFriends
          .removeWhere((e) => e.userId == userId);
      Get.find<MessageController>().activeFriends.refresh();
      final index = Get.find<MessageController>()
          .allChattedUserList
          .indexWhere((e) => e.userId == userId);
      if (index != -1) {
        Get.find<MessageController>().allChattedUserList[index].online = false;
        Get.find<MessageController>().allChattedUserList.refresh();
      }
    });

    socket?.on("blocked", (data){
      CustomSnackbar.showErrorToast(data["message"].toString());
    });

    // socket?.on("update-unread-count", (data) {
    //   Get.find<MessageController>().getChatList(showLoading: false);
    // });

    socket?.on("receive-message", (data) {
      final message = Map<String, dynamic>.from(data);
      final messageModel = MessageModel.fromJson(message);
      final messageController = Get.find<MessageController>();

      // Check if the message already exists to avoid duplicates
      final exists = messageController.chatHistoryAndLiveMessage
          .any((msg) => msg.id == messageModel.id);

      if (exists) return;
      final index = messageController.chatHistoryAndLiveMessage.indexWhere(
        (msg) => msg.clientGeneratedId == messageModel.clientGeneratedId,
      );
      if (index != -1) {
        messageController.chatHistoryAndLiveMessage[index].mediaUrl =
            messageModel.mediaUrl;
        messageController.chatHistoryAndLiveMessage[index].multipleImages =
            messageModel.multipleImages;
        messageController.chatHistoryAndLiveMessage[index].id = messageModel.id;
        messageController.chatHistoryAndLiveMessage[index].avater =
            messageModel.avater;
        messageController.chatHistoryAndLiveMessage[index].createdAt =
            messageModel.createdAt;
        messageController.chatHistoryAndLiveMessage.refresh();
      } else {
        messageController.chatHistoryAndLiveMessage.add(messageModel);
      }
    });

    socket?.on("error", (data) {
      print(data);
      // String error = data["message"] ?? "";
      // CustomSnackbar.showErrorToast(error);
      // if (error.contains("limit")) {
      //   Get.to(() => const SubscriptionScreen());
      // }
    });
  }

  void sendMessage({required MessageModel message}) {
    if (socket != null && socket!.connected) {
      socket?.emit("send-message", message.toJson());
    }
  }

  void markMessageRead(String receiverId) {
    if (socket != null && socket!.connected) {
      socket?.emit("mark-message-read", {"receiverId": receiverId});
    }
  }

  void typing({required String receiverId}) {
    if (socket != null && socket!.connected) {
      socket?.emit("typing", {"receiverId": receiverId});
    }
  }

  void stopTyping({required String receiverId}) {
    if (socket != null && socket!.connected) {
      socket?.emit("stop-typing", {"receiverId": receiverId});
    }
  }

  void disConnectListeners() async {
    if (socket != null) {
      socket?.off("newChatMessage");
      socket?.off("new-story");
      socket?.off("newstream");
      socket?.off("endedStream");
      socket?.off("viewer-count-updated");
      socket?.off("refresh");
      socket?.off("update-online-chat-list");
      socket?.off("receive-message");
      socket?.off("update-chat-list");
      socket?.off("update-unread-count");
    }
  }

  void disconnectSocket() {
    disConnectListeners();
    socket?.disconnect();
    socket = null;
    socket?.close();
    print('Socket disconnected and deleted');
  }

  void getChatHistory(String rideId) {
    socket?.emit("history", {"rideId": rideId});
  }

  void markRead({
    required String channedId,
    required String messageId,
  }) async {
    socket?.emit("MARK_MESSAGE_READ", {
      "channel_id": channedId,
      "message_ids": [messageId],
    });
  }

  void scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint("🚨 Max reconnection attempts reached. Stopping retry.");
      return;
    }

    int delay = 2 * _reconnectAttempts + 2;
    debugPrint("🔄 Reconnecting in $delay seconds...");

    Future.delayed(Duration(seconds: delay), () {
      _reconnectAttempts++;
      socket?.connect();
    });
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
    socket = null;
  }
}
