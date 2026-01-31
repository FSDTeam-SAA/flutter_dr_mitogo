import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/post/widgets/media_carousel_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:casarancha/app/utils/timeago.dart';
import 'package:casarancha/app/widgets/verification_badge.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:google_fonts/google_fonts.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool? isGhostCard;
  final bool? isProfilePost;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.isGhostCard = false,
    this.isProfilePost = false,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final RxInt currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isRetweet = _isRetweet();

    return VisibilityDetector(
      key: ValueKey(widget.post.id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final postController = Get.find<PostController>();
          postController.addViewedPost(widget.post.id);
          postController.scrollCount.value++;
          postController.injectUsersPost();
        }
      },
      child: SizedBox(
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(),
            if (isRetweet) _buildRetweetComment(),
            _buildPostContent(),
            const SizedBox(height: 10),
            _buildActionButtons(),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // Helper method to check if this is a retweet
  bool _isRetweet() {
    return widget.post.originalPost != null && widget.post.postType == "repost";
  }

  // Build the main post header (author info)
  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (widget.isGhostCard == true) {
                return;
              }
              Get.toNamed(
                AppRoutes.profile,
                arguments: {"userId": widget.post.author?.id},
              );
            },
            child: _buildProfileImage(widget.post.author?.avatarUrl ?? ""),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: InkWell(
              onTap: () {
                if (widget.isGhostCard == true) {
                  return;
                }
                Get.toNamed(
                  AppRoutes.profile,
                  arguments: {"userId": widget.post.author?.id},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(),
                  if (_isRetweet()) _buildRetweetIndicator(),
                  if (widget.post.location != null) _buildLocationInfo(),
                ],
              ),
            ),
          ),
          buildOptionAboutPost(
            postModel: widget.post,
            index: currentIndex,
            isProfilePost: widget.isProfilePost ?? false,
            onDelete: widget.onDelete,
          ),
        ],
      ),
    );
  }

  // Build author name and timestamp
  Widget _buildAuthorInfo() {
    String name = "";
    if (widget.isGhostCard == true) {
      name = widget.post.ghostMode?.anonymousId ?? "";
    } else {
      name = widget.post.author?.displayName ?? "";
    }
    if (widget.isGhostCard == true) {
      return Row(
        children: [
          Text(name, style: Get.textTheme.bodyMedium),
          _buildDotSeparator(),
          Text(
            timeAgo(widget.post.createdAt),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      );
    }
    final badges = widget.post.author?.verificationBadges;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            VerifiedInlineText(
              text: name,
              verified: badges?.profile == true || widget.post.author?.isVerified == true,
              style: Get.textTheme.bodyMedium,
              badgeSize: 14,
            ),
            _buildDotSeparator(),
            Text(
              timeAgo(widget.post.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        if ((widget.post.author?.education ?? "").isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: VerifiedInlineText(
              text: widget.post.author?.education ?? "",
              verified: badges?.school == true,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              badgeSize: 12,
            ),
          ),
        if ((widget.post.author?.work ?? "").isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: VerifiedInlineText(
              text: widget.post.author?.work ?? "",
              verified: badges?.work == true,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              badgeSize: 12,
            ),
          ),
      ],
    );
  }

  // Build retweet indicator
  Widget _buildRetweetIndicator() {
    return Row(
      children: [
        const Icon(Icons.repeat, size: 12, color: Colors.green),
        const SizedBox(width: 3),
        const Text(
          "Retweeted",
          style: TextStyle(
            fontSize: 10,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Build location info
  Widget _buildLocationInfo() {
    return Text(
      widget.post.location?.name ?? "",
      style: GoogleFonts.montserrat(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  // Build retweet comment (user's comment on the retweet)
  Widget _buildRetweetComment() {
    if (widget.post.content?.text == null ||
        widget.post.content!.text!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Obx(() {
        final text = widget.post.content?.text ?? "";
        final bool expanded = widget.post.isExpanded.value;
        const int maxLines = 4;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.content!.text!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (text.length > 100) // show button only if long
              GestureDetector(
                onTap: () => widget.post.isExpanded.toggle(),
                child: Text(
                  expanded ? "Show less" : "Show more",
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Build the main post content (original post or regular post)
  Widget _buildPostContent() {
    if (_isRetweet()) {
      return _buildOriginalPostCard();
    } else {
      return _buildRegularPostContent();
    }
  }

  // Build original post content in a card (for retweets)
  Widget _buildOriginalPostCard() {
    final originalPost = widget.post.originalPost!;
    if (originalPost.isDeleted == true) {
      return const Center(
        child: Text(
          "This post has been deleted",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOriginalPostHeader(originalPost),
          if (_hasText(originalPost)) _buildOriginalPostText(originalPost),
          if (_hasMedia(originalPost)) _buildOriginalPostMedia(originalPost),
        ],
      ),
    );
  }

  // Build original post header
  Widget _buildOriginalPostHeader(PostModel originalPost) {
    final badges = originalPost.author?.verificationBadges;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (widget.isGhostCard == true) {
                return;
              }
              Get.toNamed(
                AppRoutes.profile,
                arguments: {"userId": originalPost.author?.id},
              );
            },
            child: _buildProfileImage(
              originalPost.author?.avatarUrl ?? "",
              size: 20,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (widget.isGhostCard == true) {
                      return;
                    }
                    Get.toNamed(
                      AppRoutes.profile,
                      arguments: {"userId": originalPost.author?.id},
                    );
                  },
                  child: Row(
                    children: [
                      VerifiedInlineText(
                        text: originalPost.author?.displayName ?? "",
                        verified:
                            badges?.profile == true ||
                            originalPost.author?.isVerified == true,
                        style: Get.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        badgeSize: 12,
                      ),
                      _buildDotSeparator(),
                      Text(
                        timeAgo(originalPost.createdAt),
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (originalPost.location != null)
                  Text(
                    originalPost.location?.name ?? "",
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build original post text
  Widget _buildOriginalPostText(PostModel originalPost) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(() {
        final text = originalPost.content?.text ?? "";
        final bool expanded = originalPost.isExpanded.value;
        const int maxLines = 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (text.length > 100)
              GestureDetector(
                onTap: () => originalPost.isExpanded.toggle(),
                child: Text(
                  expanded ? "Show less" : "Show more",
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Build original post media with page view
  Widget _buildOriginalPostMedia(PostModel originalPost) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Obx(() {
        final height = _resolveMediaHeight(
          mediaList: originalPost.media ?? [],
          defaultHeight: Get.height * 0.25,
          audioHeight: Get.height * 0.2,
          availableWidth: Get.width - 20,
        );
        return MediaCarousel(
          mediaList: originalPost.media!,
          height: height,
          viewCount: originalPost.stats?.views ?? RxInt(0),
          isOriginalPost: true,
          currentIndex: currentIndex,
          postModel: originalPost,
        );
      }),
    );
  }

  // Build regular post content (non-retweet)
  Widget _buildRegularPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasText(widget.post)) _buildRegularPostText(),
        if (_hasMedia(widget.post)) _buildRegularPostMedia(),
      ],
    );
  }

  // Build regular post text
  Widget _buildRegularPostText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(() {
        final text = widget.post.content?.text ?? "";
        final bool expanded = widget.post.isExpanded.value;
        const int maxLines = 4;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.content!.text!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: expanded ? null : maxLines,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (text.length > 100) // show button only if long
              GestureDetector(
                onTap: () => widget.post.isExpanded.toggle(),
                child: Text(
                  expanded ? "Show less" : "Show more",
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
                ),
              ),
            SizedBox(height: 4),
          ],
        );
      }),
    );
  }

  // Build regular post media
  Widget _buildRegularPostMedia() {
    return Obx(() {
      final height = _resolveMediaHeight(
        mediaList: widget.post.media ?? [],
        defaultHeight: Get.height * 0.56,
        audioHeight: Get.height * 0.24,
        availableWidth: Get.width,
      );
      return MediaCarousel(
        mediaList: widget.post.media!,
        height: height,
        viewCount: widget.post.stats?.views ?? RxInt(0),
        isOriginalPost: false,
        currentIndex: currentIndex,
        postModel: widget.post,
      );
    });
  }

  // Build action buttons row
  Widget _buildActionButtons() {
    return buildPostActionRowWidget(
      postModel: widget.post,
      isGhostCard: widget.isGhostCard,
      index: currentIndex,
    ); // Keeping original method
  }

  // Helper method to build profile image
  Widget _buildProfileImage(String avatarUrl, {double size = 30}) {
    if (widget.isGhostCard == true) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryColor,
        child: FaIcon(FontAwesomeIcons.ghost, color: Colors.white),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: buildProfileImage(avatarUrl), // Keeping original method
    );
  }

  // Helper method to build dot separator
  Widget _buildDotSeparator() {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor,
      ),
    );
  }

  // Helper methods to check content
  bool _hasText(PostModel postModel) {
    return postModel.content?.text != null &&
        postModel.content!.text!.isNotEmpty;
  }

  bool _hasMedia(PostModel postModel) {
    return postModel.media != null && postModel.media!.isNotEmpty;
  }

  FileType _resolveMediaType(Media media) {
    final declaredType = media.type?.toLowerCase();
    if (declaredType == "video") return FileType.video;
    if (declaredType == "audio") return FileType.music;
    if (declaredType == "image") return FileType.image;
    final url = media.url;
    if (url == null || url.isEmpty) return FileType.image;
    return getMediaType(url);
  }

  double _resolveMediaHeight({
    required List<Media> mediaList,
    required double defaultHeight,
    required double audioHeight,
    double? availableWidth,
  }) {
    if (mediaList.isEmpty) return defaultHeight;
    final safeIndex = currentIndex.value < 0
        ? 0
        : currentIndex.value >= mediaList.length
            ? mediaList.length - 1
            : currentIndex.value;
    final media = mediaList[safeIndex];
    if (_resolveMediaType(media) == FileType.music) {
      return audioHeight;
    }
    final dimensions = media.dimensions;
    if (dimensions == null || dimensions.width <= 0 || dimensions.height <= 0) {
      return defaultHeight;
    }
    final aspectRatio = dimensions.width / dimensions.height;
    if (aspectRatio <= 0) {
      return defaultHeight;
    }
    final width = availableWidth ?? Get.width;
    return width / aspectRatio;
  }
}
