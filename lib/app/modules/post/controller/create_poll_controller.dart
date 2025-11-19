import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart' as pm;
import 'package:casarancha/app/modules/post/controller/create_post_controller.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePollController extends GetxController {
  final questionController = TextEditingController();
  final optionControllers = <TextEditingController>[].obs;
  final RxBool isLoading = false.obs;

  final postController = Get.find<PostController>();

  @override
  void onInit() {
    super.onInit();
    addOption();
    addOption();
  }

  @override
  void onClose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
    super.onClose();
  }

  void addOption() {
    optionControllers.add(TextEditingController());
  }

  void removeOption(int index) {
    if (optionControllers.length > 2) {
      optionControllers[index].dispose();
      optionControllers.removeAt(index);
    } else {
      // Show snackbar when trying to remove below minimum
      Get.snackbar(
        "Minimum Options Required",
        "A poll must have at least 2 options",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  bool validatePoll() {
    if (questionController.text.trim().isEmpty) {
      Get.snackbar(
        "Question Required",
        "Please enter a question for your poll",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Check if at least 2 options have text
    int filledOptions = 0;
    for (var controller in optionControllers) {
      if (controller.text.trim().isNotEmpty) {
        filledOptions++;
      }
    }

    if (filledOptions < 2) {
      Get.snackbar(
        "Options Required",
        "Please fill at least 2 poll options",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> createPoll({String? groupId, String? groupName}) async {
    if (!validatePoll()) return;
    isLoading.value = true;
    bool isAnoymous = Get.find<CreatePostController>().isAnonymous.value;
    List<pm.PollOptions> pollOptions =
        optionControllers
            .map((controller) => pm.PollOptions(text: controller.text.trim()))
            .where((text) => text.text != null && text.text?.isNotEmpty == true)
            .toList();
    final poll = pm.Poll(
      question: questionController.text,
      options: pollOptions,
    );
    pm.PostModel post = pm.PostModel(
      poll: poll,
      visibility: pm.Visibility(type: getVisibilityType(isAnoymous, groupId)),
      groupId: groupId,
      groupName: groupName,
    );
    await postController.createPost(postModel: post);
    isLoading.value = false;
  }

  String? getVisibilityType(bool isAnoymous, String? groupId) {
    if (isAnoymous) {
      return "ghost";
    }
    if (groupId != null) {
      return "group";
    }
    return "public";
  }
}
