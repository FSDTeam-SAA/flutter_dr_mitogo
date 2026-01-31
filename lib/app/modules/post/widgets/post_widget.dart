import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/modules/home/widgets/comment_widget.dart';
import 'package:casarancha/app/modules/home/widgets/reaction_row.dart';
import 'package:casarancha/app/modules/post/controller/create_post_controller.dart';
import 'package:casarancha/app/modules/post/widgets/bottom_share_sheet.dart';
import 'package:casarancha/app/modules/post/widgets/video_media_player.dart';
import 'package:casarancha/app/modules/report/widgets/report_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutx_core/core/theme/gap.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

Widget buildMedia({
  required Media media,
  required BoxFit fit,
  bool isFullScreen = false,
  required PostModel postModel,
}) {
  if (media.url == null || media.url!.isEmpty) return SizedBox.shrink();
  final mediaType = getMediaType(media.url!);
  if (mediaType == FileType.image) {
    return CachedNetworkImage(
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
    );
  } else if (mediaType == FileType.video) {
    return VideoMediaPlayer(url: media.url!, postModel: postModel);
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

Widget buildProfileImage(String url, {bool? isGhodePost = false}) {
  if (isGhodePost == true) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primaryColor,
      child: FaIcon(FontAwesomeIcons.ghost, color: Colors.white),
    );
  }
  if (url.toLowerCase().contains('svg')) {
    return SvgPicture.network(
      url,
      placeholderBuilder: (context) {
        return Shimmer.fromColors(
          baseColor: Colors.red,
          highlightColor: Colors.white,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(shape: BoxShape.circle),
          ),
        );
      },
      height: 40,
      width: 40,
    );
  } else {
    return CachedNetworkImage(
      imageUrl: url,
      height: 40,
      width: 40,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Shimmer.fromColors(
          baseColor: Colors.grey,
          highlightColor: Colors.white,
          child: Container(height: 40, width: 40, color: Colors.grey),
        );
      },
      errorWidget: (context, error, stackTrace) {
        return const Icon(Icons.person, size: 40);
      },
    );
  }
}

PopupMenuButton buildOptionAboutPost({
  required PostModel postModel,
  required bool isProfilePost,
  RxInt? index,
  VoidCallback? onDelete,
  Color? iconColor,
}) {
  final userController = Get.find<UserController>();
  final postController = Get.find<PostController>();
  final userModel = userController.userModel.value;
  final isAuthor = userModel?.id == postModel.author?.id;
  final isMediaAvailable = postModel.media?.isNotEmpty ?? false;
  return PopupMenuButton(
    icon: Icon(Icons.more_vert_outlined, color: iconColor),
    itemBuilder: (context) {
      return [
        PopupMenuItem(
          child: Text(
            "Report",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ReportBottomSheet(
                  reportUser: postModel.author?.id ?? "",
                  type: ReportType.post,
                  referenceId: postModel.id,
                );
              },
            );
          },
        ),
        if (isMediaAvailable)
          PopupMenuItem(
            child: Text(
              "Copy",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            onTap: () {
              if (postModel.media == null) return;

              Clipboard.setData(
                ClipboardData(text: postModel.media![index?.value ?? 0].url!),
              );
              // CustomSnackbar.showSuccessToast("Copied to clipboard");
            },
          ),
        if (!isAuthor)
          PopupMenuItem(
            child: Text(
              "Block",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            onTap: () async {
              if (postModel.author == null) return;
              await userController.toggleBlock(blockId: postModel.author!.id!);
            },
          ),
        if (isAuthor)
          PopupMenuItem(
            child: Text(
              "Delete",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            onTap: () async {
              if (onDelete != null) {
                onDelete.call();
              }

              await postController.deletePost(
                postId: postModel.id!,
                isProfilePost: isProfilePost,
              );
            },
          ),
        PopupMenuItem(
          child: Obx(
            () => Text(
              postModel.isBookmarked!.value ? "Unsave" : "Save",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          onTap: () async {
            await postController.toggleSavePost(postId: postModel.id!);
          },
        ),
      ];
    },
  );
}

Future<dynamic> buildCommentSheet(
  BuildContext context,
  PostModel postModel,
  bool? isGhostCard,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CommentSheet(postModel: postModel, isGhostCard: isGhostCard),
      );
    },
  );
}

Future<dynamic> buildRetweetSheet(BuildContext context, PostModel postModel) {
  final controller = Get.put(CreatePostController());
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Obx(() {
            if (controller.postController.isloading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: LinearProgressIndicator(color: AppColors.primaryColor),
              );
            }
            return ListTile(
              leading: Text("Repost", style: Get.textTheme.bodyMedium),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              minTileHeight: 45,
              onTap: () async {
                controller.createPost(
                  postType: "repost",
                  visibilityType: "public",
                  originalPostId: postModel.id!,
                );
              },
            );
          }),
          ListTile(
            leading: Text("Quote", style: Get.textTheme.bodyMedium),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            minTileHeight: 45,
            onTap: () {
              Get.toNamed(
                AppRoutes.createPost,
                arguments: {"originalPostId": postModel.id, "title": "Repost"},
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

Widget buildPostActionRowWidget({
  required PostModel postModel,
  RxInt? index,
  bool? isGhostCard,
  Color? iconColor,
  Color? textColor,
}) {
  final controller = Get.find<PostController>();
  final mediaIcon = _getPostMediaIcon(postModel);
  final resolvedIconColor =
      iconColor ?? const Color.fromARGB(255, 65, 6, 5).withValues();
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: [
        Obx(
          () => ReactionRowWidget(
            onReactionSelected: (v) async {
              if (postModel.reactedEmoji?.value.isEmpty == true) {
                postModel.stats!.reactionCount!.value++;
                postModel.reactedEmoji!.value = v;
                await Get.find<PostController>().reactToPost(
                  postId: postModel.id!,
                  emoji: v,
                  reactedEmoji: emojiMap[v] ?? "",
                );
              } else {
                postModel.reactedEmoji!.value = "";
                postModel.stats!.reactionCount!.value--;
                await Get.find<PostController>().deletePostReaction(
                  postId: postModel.id!,
                );
              }
            },
            selectedReaction: postModel.reactedEmoji?.value ?? "",
            reactionCount: postModel.stats?.reactionCount?.value ?? 0,
            iconColor: iconColor,
            textColor: textColor,
          ),
        ),

        postModel.visibility?.allowComments == true
            ? SizedBox(width: 15)
            : SizedBox.shrink(),
        postModel.visibility?.allowComments == true
            ? Obx(
              () => buildTextButton(
                icon: FontAwesomeIcons.comment,
                text:
                    postModel.stats?.comments?.value.toString() ??
                    "0".obs.value,
                onTap: () {
                  buildCommentSheet(Get.context!, postModel, isGhostCard);
                },
                iconColor: iconColor,
                textColor: textColor,
              ),
            )
            : SizedBox.shrink(),
        SizedBox(width: 15),
        buildTextButton(
          icon: FontAwesomeIcons.retweet,
          text: postModel.stats?.reposts.toString(),
          onTap: () {
            buildRetweetSheet(Get.context!, postModel);
          },
          iconColor: iconColor,
          textColor: textColor,
        ),
        const Spacer(),
        if (postModel.content?.text?.isNotEmpty == true &&
            postModel.media?.isEmpty == true) ...[
          buildTextButton(
            icon: FontAwesomeIcons.bars,
            text: postModel.stats?.views.toString(),
            onTap: () {
              showModalBottomSheet(
                context: Get.context!,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return AllPostViewersWidget(post: postModel);
                },
              );
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
          SizedBox(width: 15),
        ],

        if (mediaIcon != null) ...[
          Icon(mediaIcon, size: 22, color: resolvedIconColor),
          SizedBox(width: 8),
        ],

        buildTextButton(
          icon: FontAwesomeIcons.shareNodes,
          onTap: () {
            showShareBottomSheet(post: postModel, index: index);
          },
          iconColor: iconColor,
          textColor: textColor,
        ),
        SizedBox(width: 15),
        Obx(
          () => buildTextButton(
            icon:
                postModel.isBookmarked!.value
                    ? FontAwesomeIcons.solidBookmark
                    : FontAwesomeIcons.bookmark,
            onTap: () async {
              await controller.toggleSavePost(postId: postModel.id!);
            },
            iconColor: iconColor,
            textColor: textColor,
          ),
        ),
      ],
    ),
  );
}

Widget buildTextButton({
  required IconData icon,
  String? text,
  VoidCallback? onTap,
  Color? iconColor,
  Color? textColor,
}) {
  return InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: iconColor ?? const Color.fromARGB(255, 65, 6, 5).withValues(),
        ),
        SizedBox(width: 2),
        text != null
            ? Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color.fromARGB(255, 24, 24, 24),
              ),
            )
            : SizedBox.shrink(),
      ],
    ),
  );
}

FileType _resolveMediaFileType(Media media) {
  final declaredType = media.type?.toLowerCase();
  if (declaredType == "video") return FileType.video;
  if (declaredType == "audio") return FileType.music;
  if (declaredType == "image") return FileType.image;
  final url = media.url;
  if (url == null || url.isEmpty) return FileType.image;
  return getMediaType(url);
}

IconData? _getPostMediaIcon(PostModel postModel) {
  final mediaList = postModel.media;
  if (mediaList == null || mediaList.isEmpty) return null;
  bool hasVideo = false;
  bool hasAudio = false;
  bool hasImage = false;

  for (final media in mediaList) {
    final fileType = _resolveMediaFileType(media);
    if (fileType == FileType.video) {
      hasVideo = true;
    } else if (fileType == FileType.music) {
      hasAudio = true;
    } else {
      hasImage = true;
    }
  }

  if (hasVideo) return Icons.videocam_rounded;
  if (hasAudio) return Icons.audiotrack;
  if (hasImage) return Icons.photo;
  return null;
}

final Map<String, String> emojiMap = {
  "👍": "like",
  "❤️": "love",
  "😂": "laugh",
  "😮": "wow",
  "👎": "dislike",
  "😢": "sad",
  "😡": "angry",
};

class AllPostViewersWidget extends StatelessWidget {
  final PostModel post;
  const AllPostViewersWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
      ),
      child: FutureBuilder<List<UserModel>?>(
        future: Get.find<PostController>().getPostViewers(
          postId: post.id ?? "",
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("No viewers yet"));
          }

          final users = snapshot.data!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            post.stats?.views?.value = users.length;
          });
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final viewer = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(viewer.avatarUrl ?? ""),
                ),
                title: Text(
                  viewer.displayName ?? "Unknown User",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FollowFollowingViers extends StatelessWidget {
  final String userId;
  final bool isFollowers;
  FollowFollowingViers({
    super.key,
    required this.userId,
    required this.isFollowers,
  });

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
      ),
      child: FutureBuilder<List<UserModel>?>(
        future:
            isFollowers
                ? userController.viewAllFollowers(userId: userId)
                : userController.viewAllFollowing(userId: userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("No viewers yet"));
          }

          final users = snapshot.data!;
          return ListView.builder(
            // controller: scrollController,
            padding: const EdgeInsets.only(top: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final viewer = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(viewer.avatarUrl ?? ""),
                ),
                title: Text(
                  viewer.displayName ?? "Unknown User",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
