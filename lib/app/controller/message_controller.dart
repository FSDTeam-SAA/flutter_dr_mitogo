import 'dart:convert';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/data/services/message_service.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  RxBool isloading = false.obs;
  RxBool isChatListLoading = false.obs;
  RxBool isChattedListFetched = false.obs;
  final MessageService _messageService = MessageService();
  RxList<ChatListModel> allChattedUserList = <ChatListModel>[].obs;
  RxList<ChatListModel> activeFriends = <ChatListModel>[].obs;
  RxList<MessageModel> chatHistoryAndLiveMessage = <MessageModel>[].obs;
  RxMap<String, RxList<MessageModel>> savedChatToAvoidLoading =
      <String, RxList<MessageModel>>{}.obs;

  final RxnString highlightedMessageId = RxnString();
  final RxDouble highlightOpacity = 1.0.obs;

  Future<void> sendMessage({
    required MessageModel messageModel,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) {
        CustomSnackbar.showErrorToast("Authentication required");
        return;
      }

      final response = await _messageService.sendMessage(
        token: token,
        messageModel: messageModel,
      );

      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getMessageHistory({
    required String receiverUserId,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) {
        CustomSnackbar.showErrorToast("Authentication required");
        return;
      }

      final response = await _messageService.getMessageHistory(
        token: token,
        receiverUserId: receiverUserId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      List chatHistory = decoded["data"] ?? [];
      chatHistoryAndLiveMessage.clear();
      if (chatHistory.isEmpty) return;
      List<MessageModel> mapped =
          chatHistory.map((json) => MessageModel.fromJson(json)).toList();
      chatHistoryAndLiveMessage.assignAll(mapped);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getChatList({bool showLoading = true}) async {
    isChatListLoading.value = showLoading;
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) {
        CustomSnackbar.showErrorToast("Authentication required");
        return;
      }

      final response = await _messageService.getChatList(
        token: token,
      );

      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      List chatHistory = decoded["chatList"] ?? [];
      allChattedUserList.clear();
      if (chatHistory.isEmpty) return;
      List<ChatListModel> mapped =
          chatHistory.map((e) => ChatListModel.fromJson(e)).toList();
      allChattedUserList.value = mapped;
      allChattedUserList.refresh();
      if (response.statusCode == 200) isChattedListFetched.value = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isChatListLoading.value = false;
    }
    return;
  }

  clearChatHistory() {
    isChattedListFetched.value = false;
    activeFriends.clear();
    allChattedUserList.clear();
    chatHistoryAndLiveMessage.clear();
    savedChatToAvoidLoading.clear();
  }
}
