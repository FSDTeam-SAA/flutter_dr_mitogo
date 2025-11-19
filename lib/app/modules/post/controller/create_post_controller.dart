import 'dart:async';
import 'dart:io';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart' as pm;
import 'package:casarancha/app/data/models/user_model.dart';
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
