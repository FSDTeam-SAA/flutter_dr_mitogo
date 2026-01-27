import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/comment_model.dart';
import 'package:casarancha/app/data/models/group_model.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/data/services/post_service.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'story_controller.dart';

class PostController extends GetxController {
  final isloading = false.obs;
  final isGhostFeedLoading = false.obs;
  final isFetchingComments = false.obs;
  final isReplyingComments = false.obs;

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> ghostPosts = <PostModel>[].obs;
  final PostService postService = PostService();

  final storageController = Get.find<StorageController>();
  RxList<String> viewedPostIds = <String>[].obs;
  RxList<Comment> comments = <Comment>[].obs;

  final focusNode = FocusNode();
  final commentController = TextEditingController();

  String replyCommentId = "";
  Timer? timer;

  //normal-feed
  RxInt currentPage = 1.obs;
  RxBool hasNextPage = false.obs;

  //ghost-feed
  RxInt ghostCurrentPage = 1.obs;
  RxBool ghostHasNextPage = false.obs;

  RxList<PostModel> allPersonalPost = <PostModel>[].obs;

  //injection post variable
  RxInt scrollCount = 0.obs;
  RxInt lastInjectedIndex = 0.obs;
  final List<int> injectionIntervals = [15, 80, 150, 250];
  int currentInjectionIndex = 0;

  @override
  void onInit() {
    getFeed(showLoader: false);
    getGhostFeed(showLoader: false);
    super.onInit();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (viewedPostIds.isNotEmpty) {
        await viewPosts(viewedPostIds);
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void addViewedPost(String? postId) {
    if (postId == null) return;
    if (viewedPostIds.contains(postId)) return;
    viewedPostIds.add(postId);
  }

  Future<void> getFeed({bool showLoader = true, bool? loadMore = false}) async {
    isloading.value = showLoader;
    try {
      if (loadMore == true && hasNextPage.value) {
        currentPage++;
      } else {
        currentPage.value = 1;
      }
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.getFeed(
        token: token,
        currentPage: currentPage,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      List<dynamic> postsList = decoded["data"]?["posts"] ?? [];
      if (loadMore == true && hasNextPage.value) {
        posts.addAll(postsList.map((e) => PostModel.fromJson(e)).toList());
      } else {
        posts.clear();
        posts.addAll(postsList.map((e) => PostModel.fromJson(e)).toList());
      }
      hasNextPage.value = decoded["data"]?["pagination"]?["hasMore"] ?? false;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<void> getGhostFeed({
    bool showLoader = true,
    bool? loadMore = false,
  }) async {
    isGhostFeedLoading.value = showLoader;
    try {
      if (loadMore == true && ghostHasNextPage.value) {
        ghostCurrentPage++;
      } else {
        ghostCurrentPage.value = 1;
      }
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.getFeed(
        token: token,
        currentPage: ghostCurrentPage,
        type: "ghost",
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      List<dynamic> ghostPostsList = decoded["data"]?["posts"] ?? [];
      if (loadMore == true && hasNextPage.value) {
        ghostPosts.addAll(
          ghostPostsList.map((e) => PostModel.fromJson(e)).toList(),
        );
      } else {
        ghostPosts.clear();
        ghostPosts.addAll(
          ghostPostsList.map((e) => PostModel.fromJson(e)).toList(),
        );
      }
      ghostHasNextPage.value =
          decoded["data"]?["pagination"]?["hasMore"] ?? false;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isGhostFeedLoading.value = false;
    }
  }

  Future<void> viewPosts(List<String> postIds) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      if (postIds.isEmpty) return;
      final response = await postService.viewPosts(
        token: token,
        postId: postIds,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      for (var postId in postIds) {
        final postIndex = posts.indexWhere((post) => post.id == postId);
        final ghostPostIndex = ghostPosts.indexWhere(
          (post) => post.id == postId,
        );
        if (postIndex != -1) {
          posts[postIndex].stats?.views!.value++;
          posts[postIndex].stats?.views?.refresh();
        }
        if (ghostPostIndex != -1) {
          ghostPosts[ghostPostIndex].stats?.views!.value++;
          ghostPosts[ghostPostIndex].stats?.views?.refresh();
        }
      }
      postIds.clear();
      viewedPostIds.clear();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> createPost({
    required PostModel postModel,
    List<File>? files,
  }) async {
    try {
      isloading.value = true;
      final token = await storageController.getToken();
      if (token == null) return;
      Stopwatch networkTimer = Stopwatch();

      networkTimer.start();
      final response = await postService.createPost(
        token: token,
        postModel: postModel,
        files: files,
      );
      networkTimer.stop();
      if (response == null) return;
      final responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 201) {
        CustomSnackbar.showErrorToast(message);
        return;
      }

      if (postModel.visibility?.type == "ghost") {
        await getGhostFeed(showLoader: false);
        CustomSnackbar.showSuccessToast(message);
        Get.offAllNamed(AppRoutes.ghostMode);
        await getFeed(showLoader: false);
        return;
      }
      if (postModel.visibility?.type == "group") {
        final group = GroupModel(
          id: postModel.groupId,
          name: postModel.groupName,
        );
        //Group here
        Get.offAllNamed(AppRoutes.groupFeed, arguments: {"group": group});
        return;
      }
      CustomSnackbar.showSuccessToast(message);
      Get.offAllNamed(AppRoutes.bottomNavigation);
      await getFeed(showLoader: false);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isloading.value = false;
    }
  }

  Future<bool> voteOnPoll({
    required String postId,
    required String optionId,
  }) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return false;
      final response = await postService.voteOnPoll(
        token: token,
        postId: postId,
        optionId: optionId,
      );
      if (response == null) return false;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return false;
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<void> reactToPost({
    required String postId,
    required String emoji,
    required String reactedEmoji,
  }) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.reactToPost(
        token: token,
        postId: postId,
        emoji: emoji,
        reactedEmoji: reactedEmoji,
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
    }
  }

  Future<void> deletePostReaction({required String postId}) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.deletePostReaction(
        token: token,
        postId: postId,
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
    }
  }

  Future<void> commentOnPost({
    required PostModel postModel,
    required TextEditingController commentController,
  }) async {
    HapticFeedback.lightImpact();
    final userModel = Get.find<UserController>().userModel.value;
    if (userModel == null) return;
    final clientId = Uuid().v4();
    final commentModel = Comment(
      postId: postModel.id,
      content: commentController.text,
      clientId: clientId,
      authorId: Author(
        id: userModel.id,
        username: userModel.username,
        displayName: userModel.displayName,
        avatarUrl: userModel.avatarUrl,
      ),
      createdAt: DateTime.now(),
      reactionCount: RxInt(0),
      replyCount: RxInt(0),
      reactedEmoji: RxString(""),
    );
    comments.add(commentModel);
    postModel.stats?.comments?.value++;
    commentController.clear();
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.commentOnPost(
        token: token,
        postId: postModel.id ?? "",
        comment: commentModel.content ?? "",
        clientId: clientId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      final data = decoded["data"] ?? "";
      final index = comments.indexWhere(
        (element) => element.clientId == clientId,
      );
      if (index != -1) {
        comments[index].id = data["_id"];
        comments[index].postId = data["postId"];
        comments[index].content = data["content"];
        comments[index].clientId = data["clientId"];
        comments[index].isGhostComment = data["isGhostComment"];
        comments[index].reactionCount = RxInt(data["reactionCount"] ?? 0);
        comments[index].isDeleted = data["isDeleted"];
        comments[index].isPinned = data["isPinned"];
        comments[index].replyCount = RxInt(data["replyCount"] ?? 0);
        comments[index].createdAt = DateTime.parse(data["createdAt"]);
        comments[index].updatedAt = DateTime.parse(data["updatedAt"]);
        comments[index].reactedEmoji = RxString(data["reactedEmoji"] ?? "");
      }
      comments.refresh();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> getPostComments({required String postId}) async {
    isFetchingComments.value = true;
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.getPostComments(
        token: token,
        postId: postId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      comments.clear();
      List<dynamic> commentsList = decoded["data"]?["comments"] ?? [];
      if (commentsList.isEmpty) return;
      comments.addAll(commentsList.map((e) => Comment.fromJson(e)).toList());
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isFetchingComments.value = false;
    }
  }

  Future<void> reactToComment({
    required String postId,
    required String commentId,
    required String emoji,
  }) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.reactToComment(
        token: token,
        postId: postId,
        commentId: commentId,
        emoji: emoji,
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
    }
  }

  Future<void> replyComment({
    required String commentId,
    required TextEditingController commentController,
  }) async {
    isReplyingComments.value = true;
    final commentIndex = comments.indexWhere(
      (element) => element.id == commentId,
    );
    if (commentIndex == -1) return;
    final comment = comments[commentIndex];
    comment.replyCount!.value++;
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final clientId = Uuid().v4();
      final response = await postService.replyComment(
        token: token,
        commentId: commentId,
        comment: commentController.text,
        clientId: clientId,
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
      isReplyingComments.value = false;
    }
    commentController.clear();
  }

  Future<dynamic> getAllCommentReplies({
    required String parentId,
    required RxInt currentPage,
  }) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return null;
      final response = await postService.getAllCommentReplies(
        token: token,
        parentId: parentId,
        currentPage: currentPage,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"]?["replies"] ?? "";
      final bool hasNextPage =
          decoded["data"]?["pagination"]?["hasMore"] ?? false;

      if (data.isEmpty) return null;
      List<Comment> commentReplies =
          data.map((e) => Comment.fromJson(e)).toList();

      // return commentReplies;
      return {"commentReplies": commentReplies, "hasNextPage": hasNextPage};
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
    return null;
  }

  Future<void> toggleSavePost({required String postId}) async {
    final postIndex = posts.indexWhere((element) => element.id == postId);
    if (postIndex == -1) return;
    posts[postIndex].isBookmarked!.value =
        !posts[postIndex].isBookmarked!.value;
    posts.refresh();
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.toggleSavePost(
        token: token,
        postId: postId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
      CustomSnackbar.showSuccessToast(message);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<UserModel>?> searchPeopleToTag({required String search}) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return null;
      final response = await postService.searchPeopleToTag(
        token: token,
        search: search,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? "";
      if (data.isEmpty) return null;
      List<UserModel> users = data.map((e) => UserModel.fromJson(e)).toList();
      return users;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> deleteComment({required String commentId}) async {
    try {
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.deleteComment(
        token: token,
        commentId: commentId,
      );
      if (response == null) return;
      final decoded = json.decode(response.body);
      print(decoded);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deletePost({
    required String postId,
    bool? isGhostPost,
    required bool isProfilePost,
  }) async {
    try {
      if (isProfilePost) {
        allPersonalPost.removeWhere((element) => element.id == postId);
        allPersonalPost.refresh();
      }
      posts.removeWhere((element) => element.id == postId);
      posts.refresh();
      if (isGhostPost == true) {
        ghostPosts.removeWhere((element) => element.id == postId);
        ghostPosts.refresh();
      }
      final token = await storageController.getToken();
      if (token == null) return;
      final response = await postService.deletePost(
        token: token,
        postId: postId,
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
    }
  }

  Future<dynamic> getPostsByMediaType({
    required String mediaType,
    required int currentPage,
  }) async {
    try {
      final storageController = Get.find<StorageController>();
      final String? token = await storageController.getToken();
      if (token == null) return null;

      final response = await postService.getPostsByMediaType(
        token: token,
        mediaType: mediaType,
        currentPage: currentPage,
      );
      if (response == null) return null;
      final decoded = json.decode(response.body);
      String message = decoded["message"] ?? "";
      if (response.statusCode != 200) {
        CustomSnackbar.showErrorToast(message);
        return null;
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return null;
      List<PostModel> posts = data.map((e) => PostModel.fromJson(e)).toList();
      bool hasNextPage = decoded["pagination"]?["hasNextPage"] ?? false;
      return {"posts": posts, "hasNextPage": hasNextPage};
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  Future<void> injectUsersPost() async {
    // Early return if we've used all injection intervals
    if (currentInjectionIndex >= injectionIntervals.length) return;

    // Check if we've scrolled enough to reach the next injection point
    final nextInjectionAt = injectionIntervals[currentInjectionIndex];
    if (scrollCount.value < nextInjectionAt ||
        scrollCount.value - lastInjectedIndex.value < nextInjectionAt) {
      return;
    }

    final userController = Get.find<UserController>();
    final userId = userController.userModel.value?.id;
    if (userId == null) return;

    final userPosts = await userController.getAllUserPost(userId: userId);
    if (userPosts == null || userPosts.isEmpty) return;

    // Pick a random spot to insert (70% down the current post list)
    final insertIndex = (posts.length * 0.7).round();
    final userPost = userPosts[currentInjectionIndex % userPosts.length];

    posts.insert(insertIndex, userPost);
    lastInjectedIndex.value = scrollCount.value;
    currentInjectionIndex++;
  }

  Future<List<UserModel>?> getPostViewers({required String postId}) async {
    try {
      final storageController = Get.find<StorageController>();
      String? token = await storageController.getToken();
      if (token == null || token.isEmpty) return [];

      final response = await postService.getPostViewers(
        token: token,
        postId: postId,
      );
      if (response == null) return [];
      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        return [];
      }
      final List data = decoded["data"] ?? [];
      if (data.isEmpty) return [];
      List<UserModel> users = data.map((e) => UserModel.fromJson(e)).toList();
      return users;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  /// [Noyon]
  // ADD THIS METHOD TO PostController
  Future<void> refreshHomeFeed({bool showLoader = true}) async {
    // Reset pagination
    currentPage.value = 1;
    hasNextPage.value = false;

    // Show loader if requested
    isloading.value = showLoader;

    try {
      final token = await storageController.getToken();
      if (token == null) return;

      final response = await postService.getFeed(
        token: token,
        currentPage: currentPage,
      );

      if (response == null) return;

      final decoded = json.decode(response.body);
      if (response.statusCode != 200) {
        final message = decoded["message"] ?? "Failed to refresh";
        CustomSnackbar.showErrorToast(message);
        return;
      }

      final List<dynamic> postsList = decoded["data"]?["posts"] ?? [];
      posts.assignAll(postsList.map((e) => PostModel.fromJson(e)).toList());
      hasNextPage.value = decoded["data"]?["pagination"]?["hasMore"] ?? false;

      // Also refresh stories (important!)
      await Get.find<StoryController>().getAllStories();
      await Get.find<StoryController>().getUserPostedStories();
    } catch (e) {
      debugPrint("refreshHomeFeed error: $e");
    } finally {
      isloading.value = false;
    }
  }

  //a metjod here
  void clean() {
    try {
      timer?.cancel();
    } catch (_) {}

    isloading.value = false;
    isGhostFeedLoading.value = false;
    isFetchingComments.value = false;
    isReplyingComments.value = false;

    posts.clear();
    ghostPosts.clear();
    viewedPostIds.clear();
    comments.clear();
    allPersonalPost.clear();

    // Inputs/focus
    replyCommentId = "";
    commentController.clear();
    if (focusNode.hasFocus) {
      focusNode.unfocus();
    }

    // Pagination
    currentPage.value = 1;
    hasNextPage.value = false;
    ghostCurrentPage.value = 1;
    ghostHasNextPage.value = false;

    // Injection counters
    scrollCount.value = 0;
    lastInjectedIndex.value = 0;
    currentInjectionIndex = 0;
  }
}
