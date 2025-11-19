import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/story_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/story_service.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoryController extends GetxController {
  RxBool isloading = false.obs;
  RxBool isStoryFetched = false.obs;
  final StoryService _storyService = StoryService();
  RxList<StoryModel> allstoriesList = RxList<StoryModel>();
  RxList<UserModel> allStoryViewers = RxList<UserModel>();
  Rxn<StoryModel> userPostedStory = Rxn<StoryModel>();
  RxList<Map> seenStoryIds = <Map>[].obs;
  final emptyStoryModel = StoryModel(
    userId: "",
    stories: [],
  );

  @override
  void onInit() {
    getAllStories();
    getUserPostedStories();
    super.onInit();
  }

  Future<void> createStory({
    required List<File> mediaFiles,
    required String content,
    required BuildContext context,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _storyService.createStory(
        content: content,
        token: token,
        mediaFiles: mediaFiles,
      );
      if (response == null) return;
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(decoded["message"]);
        return;
      }
      await getUserPostedStories();
      await getAllStories();
      CustomSnackbar.showSuccessToast("Story created successfully!");
      mediaFiles.clear();
      Get.back();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getAllStories() async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _storyService.getAllStories(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        debugPrint(decoded["message"].toString());
        return;
      }
      List stories = decoded["data"];
      allstoriesList.clear();
      if (stories.isEmpty) return;
      List<StoryModel> mappedList =
          stories.map((data) => StoryModel.fromJson(data)).toList();
      allstoriesList.value = mappedList;
      isStoryFetched.value = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  void markStoryAsSeen(
    String? storyId,
    String? storyItemId,
    String? storyUserId,
  ) {
    final userController = Get.find<UserController>();
    if (userController.userModel.value?.id == storyUserId) return;
    if (storyId == null || storyItemId == null) return;
    seenStoryIds.add({"storyId": storyId, "storyItemId": storyItemId});
  }

  Future<void> markAllStoryViewed() async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _storyService.viewStory(
        token: token,
        storyItems: seenStoryIds,
      );

      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        debugPrint(message);
        return;
      }
      seenStoryIds.clear();
      await getAllStories();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getStoryViewers({
    required String storyId,
    required String storyItemId,
  }) async {
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _storyService.getStoryViewers(
        token: token,
        storyId: storyId,
        storyItemId: storyItemId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        debugPrint(decoded["message"].toString());
        return;
      }
      final viewers = decoded["viewers"] ?? "";
      allStoryViewers.clear();
      if (viewers.isEmpty) return;
      List<UserModel> viewerList = (viewers as List)
          .cast<Map<String, dynamic>>()
          .map((e) => UserModel.fromJson(e))
          .toList();
      if (viewerList.isEmpty) return;
      allStoryViewers.value = viewerList;
      allStoryViewers.refresh();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteStory({
    required String storyId,
  }) async {
    isloading.value = true;
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response =
          await _storyService.deleteStory(storyId: storyId, token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(decoded["message"]);
        return;
      }
      CustomSnackbar.showErrorToast("Story deleted successfully!");
      await getUserPostedStories();
      Get.offAllNamed(AppRoutes.bottomNavigation);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getUserPostedStories() async {
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return;
      final response = await _storyService.getUserPostedStories(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        userPostedStory.value = null;
        debugPrint(decoded["message"].toString());
        return;
      }
      var storyMap = decoded["data"] ?? "";
      userPostedStory.value = null;
      if (storyMap == null || storyMap.isEmpty || storyMap["stories"] == null) {
        return;
      }
      StoryModel story = StoryModel.fromJson(storyMap);
      userPostedStory.value = story;
      userPostedStory.refresh();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void clearUserData() {
    allstoriesList.clear();
    allStoryViewers.clear();
    allstoriesList.clear();
    seenStoryIds.clear();
    userPostedStory.value = null;
    isStoryFetched.value = false;
  }
}
