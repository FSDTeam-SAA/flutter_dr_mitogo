import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/data/models/group_model.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/group_service.dart';
import 'package:casarancha/app/data/services/post_service.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  final isLoading = false.obs;
  final isJoinLoading = false.obs;

  final groupService = GroupService();
  final postService = PostService();
  final storageController = Get.find<StorageController>();

  final groupList = <GroupModel>[].obs;
  final userGroups = <GroupModel>[].obs;

  //Members to add
  final membersToAdd = <UserModel>[].obs;

  Future<void> createGroup({
    required String name,
    required String description,
    required String visibilityType,
    required File file,
    required List<String> membersId,
  }) async {
    try {
      isLoading.value = true;
      final token = await storageController.getToken();
      if (token == null) return;
      final Stopwatch stopwatch = Stopwatch()..start();
      final response = await groupService.createGroup(
        token: token,
        name: name,
        description: description,
        visibilityType: visibilityType,
        file: file,
        membersId: membersId,
      );
      stopwatch.stop();
      debugPrint("Time taken: ${stopwatch.elapsed}");
      if (response == null) return;
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
      Get.back();
      await getUserGroups();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getAllPublicGroups() async {
    isLoading.value = true;
    try {
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await groupService.getGroups(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      List groups = decoded["data"] ?? [];
      if (groups.isEmpty) return;
      groupList.value = groups.map((e) => GroupModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinGroup({required String groupId}) async {
    try {
      isJoinLoading.value = true;
      final token = await storageController.getToken();
      if (token == null) return;
      final Stopwatch stopwatch = Stopwatch()..start();
      final response = await groupService.joinGroup(
        token: token,
        groupId: groupId,
      );
      stopwatch.stop();
      debugPrint("Time taken: ${stopwatch.elapsed}");
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      final groupData = decoded["data"];
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
      final group = GroupModel(
        id: groupData["_id"],
        name: groupData["name"],
        description: groupData["description"],
      );
      Get.toNamed(AppRoutes.groupFeed, arguments: {"group": group});
      await getUserGroups();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isJoinLoading.value = false;
    }
  }

  Future<void> getUserGroups() async {
    isLoading.value = true;
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await groupService.userGroups(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      List groups = decoded["data"] ?? [];
      if (groups.isEmpty) return;
      userGroups.value = groups.map((e) => GroupModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getGroupFeed({
    bool showLoader = true,
    bool? loadMore = false,
    required String groupId,
    required RxInt currentPage,
    required RxBool hasNextPage,
    required RxList<PostModel> groupFeed,
  }) async {
    isLoading.value = showLoader;
    try {
      if (loadMore == true && hasNextPage.value) {
        currentPage.value++;
      } else {
        currentPage.value = 1;
      }

      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.getFeed(
        token: token,
        currentPage: currentPage,
        type: "group",
        groupId: groupId,
      );
      if (response == null) return;

      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      List<dynamic> postsList = decoded["data"]?["posts"] ?? [];
      if (loadMore == true) {
        groupFeed.addAll(postsList.map((e) => PostModel.fromJson(e)).toList());
      } else {
        groupFeed.clear();
        groupFeed.addAll(postsList.map((e) => PostModel.fromJson(e)).toList());
      }
      hasNextPage.value = decoded["data"]?["pagination"]?["hasMore"] ?? false;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMembersToAdd() async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await groupService.getMembersToAdd(token: token);
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      membersToAdd.clear();
      List members = decoded["data"] ?? [];
      if (members.isEmpty) return;
      membersToAdd.value = members.map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
