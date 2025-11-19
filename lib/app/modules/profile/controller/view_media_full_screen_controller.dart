import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ViewMediaFullScreenController extends GetxController {
  final postController = Get.find<PostController>();

  final RxList<PostModel> posts = <PostModel>[].obs;
  RxInt currentPage = 1.obs;
  final RxBool hasMore = false.obs;
  final RxBool isLoadingMore = false.obs;

  final int _preloadCount = 4;
  final int _disposeAheadCount = 10;

  // New: store video controllers
  final Map<String, VideoPlayerController> videoControllers = {};

  RxString mediaType = "image".obs;

  void initialLoad() async {
    final allPost = postController.posts;
    for (var post in allPost) {
      if (post.media == null) continue;
      for (var media in post.media!) {
        if (media.type == mediaType.value) {
          posts.add(post);
        }
      }
    }
  }

  Future<void> getRelatedFeed({bool loadMore = false}) async {
    isLoadingMore.value = true;
    if (loadMore == true && hasMore.value) {
      currentPage.value++;
    } else {
      currentPage.value = 1;
    }
    final data = await postController.getPostsByMediaType(
      mediaType: mediaType.value,
      currentPage: currentPage.value,
    );
    if (data == null) return;
    final allPost = data["posts"] as List<PostModel>? ?? [];
    final hasNextPage = data["hasNextPage"] as bool;

    final newPosts =
        allPost
            .where(
              (newPost) =>
                  !posts.any((existingPost) => existingPost.id == newPost.id),
            )
            .toList();

    if (newPosts.isNotEmpty) {
      posts.addAll(newPosts);
    }
    hasMore.value = hasNextPage;
    isLoadingMore.value = false;
  }

  void loadMore({required int index}) async {
    if (index == posts.length - 2 && !isLoadingMore.value && hasMore.value) {
      isLoadingMore.value = true;

      await getRelatedFeed(loadMore: true);
      isLoadingMore.value = false;
    }
  }

  VideoPlayerController? getVideoController(String videoUrl) {
    return videoControllers[videoUrl];
  }

  // Preload videos around the current index
  void preloadVideos(int currentIndex) {
    // Preload next few videos
    for (int i = 1; i <= _preloadCount; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < posts.length) {
        _initializeVideoController(posts[nextIndex]);
      }
    } // Dispose videos that are too far behind
    final disposeIndex = currentIndex - _disposeAheadCount - 1;
    if (disposeIndex >= 0) {
      _disposeVideoController(posts[disposeIndex]);
    }
  }

  Future<void> _initializeVideoController(PostModel post) async {
    if (post.media == null || post.media!.isEmpty) return;
    for (var media in post.media!) {
      if (media.type == 'video' && !videoControllers.containsKey(media.url)) {
        try {
          final controller = VideoPlayerController.networkUrl(
            Uri.parse(media.url!),
          );
          await controller.initialize();
          videoControllers[media.url!] = controller;
        } catch (e) {
          print('Error initializing video controller: $e');
        }
      }
    }
  }

  void _disposeVideoController(PostModel post) {
    if (post.media == null) return;
    for (var media in post.media!) {
      if (media.type == 'video') {
        final controller = videoControllers.remove(media.url);
        controller?.dispose();
      }
    }
  }

  @override
  void onClose() {
    // Dispose all controllers when screen is closed
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    videoControllers.clear();
    super.onClose();
  }
}
