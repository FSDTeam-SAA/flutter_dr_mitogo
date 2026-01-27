import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/data/models/fomo_window_model.dart';
import 'package:casarancha/app/data/models/post_model.dart' as pm;
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/fomo_service.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePostController extends GetxController {
  final RxBool isAnonymous = false.obs;
  final RxBool isVerificationBadge = true.obs;
  final RxBool isComments = false.obs;
  final RxBool isloading = false.obs;
  final RxBool showPostTime = true.obs;
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  //selectedMedias-is-to-upload
  //allMediaToPreview-is-to-preview-incase-of-videos-thumbnails
  final RxList<File> selectedMedias = <File>[].obs;
  final RxList<File> allMediaToPreview = <File>[].obs;

  final FomoService _fomoService = FomoService();
  final storageController = Get.find<StorageController>();
  final RxList<FomoWindow> activeFomoWindows = <FomoWindow>[].obs;
  final Rxn<FomoWindow> selectedFomoWindow = Rxn<FomoWindow>();
  final RxBool isLoadingFomo = false.obs;
  final RxBool isJoiningFomo = false.obs;

  // final RxBool ghostMode = false.obs;
  final postController = Get.find<PostController>();

  Timer? _debounce;
  final RxList<UserModel> displayUsers = <UserModel>[].obs;
  List<String> mentionedUserIds = [];
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    selectedMedias.clear();
    allMediaToPreview.clear();
    loadActiveFomoWindows();
    super.onInit();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        // Only search if query is 2+ characters
        searchPeopleToTag(query);
      } else {
        displayUsers.clear();
      }
    });
  }

  Future<void> searchPeopleToTag(String query) async {
    final users = await postController.searchPeopleToTag(search: query);
    if (users != null) {
      displayUsers.assignAll(users);
    }
  }

  Future<void> createPost({
    String? postType,
    String? visibilityType,
    String? originalPostId,
    String? groupId,
    String? groupName,
  }) async {
    isloading.value = true;
    final postModel = pm.PostModel(
      content: pm.Content(text: descriptionController.text),
      allowComments: !isComments.value,
      showPostTime: showPostTime.value,
      allowSharing: true,
      showVerificationBadge: isVerificationBadge.value,
      postType: postType ?? "regular",
      visibility: pm.Visibility(type: visibilityType ?? "public"),
      originalPostId: originalPostId,
      groupId: groupId,
      groupName: groupName,
    );

    if (locationController.text.isNotEmpty) {
      postModel.location = pm.Location(name: locationController.text);
    }
    await postController.createPost(
      postModel: postModel,
      files: selectedMedias,
    );
    isloading.value = false;
  }

  Future<void> loadActiveFomoWindows() async {
    try {
      isLoadingFomo.value = true;
      final token = await storageController.getToken();
      if (token == null || token.isEmpty) return;
      final response = await _fomoService.getActiveWindows(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        return;
      }
      final List data = decoded["data"] ?? [];
      activeFomoWindows.assignAll(
        data.map((e) => FomoWindow.fromJson(e)).toList(),
      );
      if (activeFomoWindows.isNotEmpty) {
        selectedFomoWindow.value = activeFomoWindows.first;
      }
    } catch (_) {
      // no-op; UI will show empty state
    } finally {
      isLoadingFomo.value = false;
    }
  }

  Future<void> joinSelectedFomo() async {
    if (isJoiningFomo.value) return;
    final window = selectedFomoWindow.value;
    if (window == null) {
      CustomSnackbar.showErrorToast("No active FOMO window right now");
      return;
    }
    try {
      isJoiningFomo.value = true;
      final token = await storageController.getToken();
      if (token == null || token.isEmpty) {
        CustomSnackbar.showErrorToast("Please login to join FOMO");
        return;
      }
      final response = await _fomoService.participate(
        token: token,
        windowId: window.id,
      );
      if (response == null) {
        CustomSnackbar.showErrorToast("Unable to join FOMO. Try again.");
        return;
      }
      final decoded = json.decode(response.body);
      final message = decoded["message"] ?? "FOMO participation recorded";
      if (response.statusCode == 200) {
        CustomSnackbar.showSuccessToast(message);
        await loadActiveFomoWindows();
      } else {
        CustomSnackbar.showErrorToast(message);
      }
    } catch (e) {
      CustomSnackbar.showErrorToast("Could not join FOMO");
    } finally {
      isJoiningFomo.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.clear();
    locationController.clear();
    selectedMedias.clear();
    allMediaToPreview.clear();
    _debounce?.cancel();
    super.onClose();
  }
}
