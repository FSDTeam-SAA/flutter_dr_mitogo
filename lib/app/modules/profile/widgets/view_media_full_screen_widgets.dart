import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/post/widgets/post_widget.dart';
// import 'package:casarancha/app/modules/post/widgets/video_media_player.dart';
import 'package:casarancha/app/modules/profile/controller/view_media_full_screen_controller.dart';
import 'package:casarancha/app/modules/profile/widgets/full_screen_video_player.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ViewMediaFullScreenWidgets {
  final viewMediaController = Get.find<ViewMediaFullScreenController>();

  Widget buildLoader() {
    return Obx(() {
      if (viewMediaController.isLoadingMore.value &&
          viewMediaController.posts.isNotEmpty) {
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(child: Loader1(size: 20)),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget buildPost({required bool isProfilePost}) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Obx(() {
        if (viewMediaController.posts.isEmpty) {
          return const Center(child: Text("No posts found"));
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemCount: viewMediaController.posts.length,
          onPageChanged: (index) {
            viewMediaController.loadMore(index: index);
            viewMediaController.preloadVideos(index);
          },
          itemBuilder: (context, index) {
            final post = viewMediaController.posts[index];
            return buildEachPostBuilder(
              post: post,
              isProfilePost: isProfilePost,
              postIndex: index,
            );
          },
        );
      }),
    );
  }

  Widget buildEachPostBuilder({
    required PostModel post,
    required bool isProfilePost,
    required int postIndex,
  }) {
    return VisibilityDetector(
      key: ValueKey(post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.8) {
          viewMediaController.postController.addViewedPost(post.id);
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: post.media?.length ?? 0,
        itemBuilder: (context, index) {
          final mediaUrl = post.media?[index];

          return buildViewScreenMedia(
            media: mediaUrl!,
            fit: BoxFit.contain,
            postModel: post,
            isProfilePost: isProfilePost,
            videoPlayerController:
                mediaUrl.type == 'video'
                    ? viewMediaController.getVideoController(mediaUrl.url ?? "")
                    : null,
          );
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        CircleAvatar(
          radius: 15,
          backgroundColor: Colors.grey.shade300,
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert_outlined, size: 13),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text(
                    "Share",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: Text(
                    "Saved",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {},
                ),
                PopupMenuItem(
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  onTap: () {},
                ),
              ];
            },
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget buildContent({
    required PostModel postModel,
    required bool isProfilePost,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            InkWell(
              onTap: () {
                Get.toNamed(
                  AppRoutes.profile,
                  arguments: {"userId": postModel.author?.id ?? ""},
                );
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                      postModel.author?.avatarUrl ?? "",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postModel.author?.displayName ?? "",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${postModel.author?.username ?? ""}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // const Icon(Icons.more_horiz, color: Colors.white),
                  buildOptionAboutPost(
                    postModel: postModel,
                    isProfilePost: isProfilePost,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Tweet text
            Obx(() {
              final text = postModel.content?.text ?? "";
              final bool expanded = postModel.isExpanded.value;
              const int maxLines = 3; // truncate after 3 lines

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: expanded ? null : maxLines,
                    overflow:
                        expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                  if (text.length > 100) // show button only if long
                    GestureDetector(
                      onTap: () => postModel.isExpanded.toggle(),
                      child: Text(
                        expanded ? "Show less" : "Show more",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              );
            }),

            const SizedBox(height: 8),
            buildPostActionRowWidget(
              postModel: postModel,
              textColor: Colors.white,
              iconColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildViewScreenMedia({
    required PostModel postModel,
    required Media media,
    required BoxFit fit,
    bool isFullScreen = false,
    required bool isProfilePost,
    VideoPlayerController? videoPlayerController,
  }) {
    if (media.url == null || media.url!.isEmpty) return SizedBox.shrink();
    final mediaType = getMediaType(media.url!);
    if (mediaType == FileType.image) {
      return Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: media.url ?? "",
              fit: fit,
              placeholder: (context, url) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                );
              },
              errorWidget: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 40);
              },
            ),
          ),
          buildContent(postModel: postModel, isProfilePost: isProfilePost),
        ],
      );
    } else if (mediaType == FileType.video) {
      return FullScreenVideoPlayer(
        videoUrl: media.url!,
        isProfilePost: isProfilePost,
        postModel: postModel,
        videoPlayerController: videoPlayerController,
      );
    } else {
      final hash = media.url.hashCode;
      final randomIndex = (hash % 4) + 1;
      return Stack(
        children: [
          Image.asset(
            "assets/images/audio$randomIndex.jpg",
            fit: BoxFit.cover,
            width: Get.width,
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          Chewie(
            controller: ChewieController(
              materialProgressColors: ChewieProgressColors(
                playedColor: AppColors.primaryColor, // already played
                handleColor: Colors.white, // draggable circle
                backgroundColor: Colors.grey, // unplayed
                bufferedColor: Colors.grey.shade300, // buffered
              ),
              cupertinoProgressColors: ChewieProgressColors(
                playedColor: AppColors.primaryColor,
                handleColor: Colors.white,
                backgroundColor: Colors.grey,
                bufferedColor: Colors.grey.shade300,
              ),
              videoPlayerController: VideoPlayerController.networkUrl(
                Uri.parse(media.url!),
              ),
            ),
          ),
        ],
      );
    }
  }

}
