import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/comment_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:casarancha/app/utils/timeago.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class CommentCard extends StatelessWidget {
  final bool? isGhostCard;
  final Comment comment;
  CommentCard({super.key, required this.comment, this.isGhostCard = false});

  final postController = Get.find<PostController>();
  RxList<Comment> commentReplies = <Comment>[].obs;
  RxBool isLoadingReplies = false.obs;

  RxInt currentPage = 0.obs;
  RxBool hasNextPage = false.obs;

  RxInt visibleReplies = 0.obs;
  final int repliesChunkSize = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAuthorName(),
                const SizedBox(height: 2),
                _buildCommentTextAndReaction(),
                const SizedBox(height: 2),
                _buildCommentActions(),
                _buildRepliesSection(),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the comment author's avatar
  Widget _buildAvatar() {
    if (isGhostCard == true) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryColor,
        child: const FaIcon(FontAwesomeIcons.ghost, color: Colors.white),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: CachedNetworkImage(
        imageUrl: comment.authorId?.avatarUrl ?? "",
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmerPlaceholder(),
        errorWidget:
            (context, error, stackTrace) => const Icon(Icons.person, size: 40),
      ),
    );
  }

  /// Creates a shimmer loading effect for the avatar
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.white,
      child: Container(height: 40, width: 40, color: Colors.grey),
    );
  }

  /// Displays the comment author's name
  Widget _buildAuthorName() {
    final displayName =
        isGhostCard == true
            ? (comment.authorId?.anonymousId ?? "")
            : (comment.authorId?.displayName ?? "");

    return Text(
      displayName,
      style: Get.textTheme.bodyMedium?.copyWith(
        color: Colors.blueGrey,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Shows the comment text and like button
  Widget _buildCommentTextAndReaction() {
    return Row(
      children: [
        Expanded(
          child: Text(
            comment.content ?? "",
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildLikeButton(),
      ],
    );
  }

  /// Shows timestamp and reply button
  Widget _buildCommentActions() {
    return Row(
      children: [
        Text(
          commentTimeAgo(comment.createdAt),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: const Color.fromRGBO(49, 42, 42, 0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          onTap: _onReplyTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            color: Colors.transparent,
            child: Text(
              "Reply",
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: const Color.fromARGB(255, 65, 6, 5).withOpacity(0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Creates the like button with heart icon and count
  Widget _buildLikeButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _toggleLike,
          child: Obx(
            () => FaIcon(
              _isLiked() ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: const Color.fromARGB(255, 65, 6, 5).withOpacity(0.75),
              size: 15,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Obx(() => Text(comment.reactionCount?.value.toString() ?? "0")),
      ],
    );
  }

  /// Manages the entire replies section
  Widget _buildRepliesSection() {
    return Obx(() {
      // Show "View replies" button if comment has replies but none are loaded
      if (_shouldShowViewRepliesButton()) {
        return _buildViewRepliesButton();
      }

      // Show loading indicator
      if (isLoadingReplies.value) {
        return const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Center(child: Loader1(size: 20)),
        );
      }

      // Show replies if any are loaded
      if (commentReplies.isNotEmpty) {
        return _buildRepliesList();
      }

      return const SizedBox();
    });
  }

  /// Button to initially load replies
  Widget _buildViewRepliesButton() {
    final replyCount = comment.replyCount?.value ?? 0;

    return InkWell(
      onTap: _loadInitialReplies,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            const Icon(Icons.keyboard_arrow_down_outlined, size: 15),
            Text("View $replyCount replies", style: _actionTextStyle()),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreRepliesButton() {
    return InkWell(
      onTap: _loadMoreReplies,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text("View more replies", style: _actionTextStyle()),
      ),
    );
  }

  Widget _buildHideRepliesButton() {
    return InkWell(
      onTap: _hideAllReplies,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          children: [
            const Icon(Icons.keyboard_arrow_up_outlined, size: 15),
            Text("Hide replies", style: _actionTextStyle()),
          ],
        ),
      ),
    );
  }

  TextStyle _actionTextStyle() {
    return GoogleFonts.montserrat(
      fontSize: 12,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    );
  }

  /// Shows the list of replies with pagination controls
  Widget _buildRepliesList() {
    final displayedReplies = commentReplies.take(visibleReplies.value).toList();

    return Column(
      children: [
        // List of reply widgets
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedReplies.length,
          itemBuilder:
              (context, index) => _ReplyItem(
                reply: displayedReplies[index],
                isGhostCard: isGhostCard,
              ),
        ),

        // Pagination controls
        _buildPaginationControls(),
      ],
    );
  }

  /// Controls for loading more replies or hiding them
  Widget _buildPaginationControls() {
    // Show more replies from current batch
    if (visibleReplies.value < commentReplies.length) {
      return _buildShowMoreRepliesButton();
    }

    // Load next page of replies
    if (hasNextPage.value) {
      return _buildLoadMoreRepliesButton();
    }

    // Hide all replies
    return _buildHideRepliesButton();
  }

  Widget _buildShowMoreRepliesButton() {
    final remaining = commentReplies.length - visibleReplies.value;
    final toShow = min(repliesChunkSize, remaining);

    return InkWell(
      onTap: _showMoreReplies,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text("View $toShow more replies", style: _actionTextStyle()),
      ),
    );
  }

  bool _shouldShowViewRepliesButton() {
    return comment.replyCount?.value != null &&
        comment.replyCount!.value > 0 &&
        commentReplies.isEmpty &&
        !isLoadingReplies.value;
  }

  bool _isLiked() => comment.reactedEmoji?.value == "❤️";

  Future<void> _toggleLike() async {
    if (_isLiked()) {
      comment.reactedEmoji!.value = "";
      comment.reactionCount!.value--;
    } else {
      comment.reactedEmoji!.value = "❤️";
      comment.reactionCount!.value++;
      await postController.reactToComment(
        postId: comment.postId!,
        commentId: comment.id!,
        emoji: "❤️",
      );
    }
  }

  void _onReplyTap() {
    postController.replyCommentId = comment.id!;
    FocusScope.of(Get.context!).requestFocus(postController.focusNode);
  }

  Future<void> _loadInitialReplies() async {
    await _fetchReplies(page: 1);
  }

  Future<void> _loadMoreReplies() async {
    await _fetchReplies(page: currentPage.value + 1);
  }

  void _showMoreReplies() {
    final remaining = commentReplies.length - visibleReplies.value;
    final toAdd = min(repliesChunkSize, remaining);
    visibleReplies.value += toAdd;
  }

  void _hideAllReplies() {
    visibleReplies.value = 0;
    commentReplies.clear();
    hasNextPage.value = false;
    currentPage.value = 0;
  }

  Future<void> _fetchReplies({required int page}) async {
    if (page == 1) {
      commentReplies.clear();
      visibleReplies.value = 0;
      hasNextPage.value = false;
    }

    isLoadingReplies.value = true;

    try {
      final result = await postController.getAllCommentReplies(
        parentId: comment.id ?? "",
        currentPage: page.obs,
      );

      final newReplies = result["commentReplies"] as List<Comment>?;
      final nextPageExists = result["hasNextPage"] as bool?;

      if (newReplies != null) {
        commentReplies.addAll(newReplies);
        visibleReplies.value = min(repliesChunkSize, commentReplies.length);
      }

      hasNextPage.value = nextPageExists ?? false;
      currentPage.value = page;
    } catch (e) {
      // Handle error appropriately
      debugPrint('Error fetching replies: $e');
    } finally {
      isLoadingReplies.value = false;
    }
  }
}

/// Individual reply item widget
class _ReplyItem extends StatelessWidget {
  final Comment reply;
  final bool? isGhostCard;

  const _ReplyItem({required this.reply, this.isGhostCard});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          _buildReplyAvatar(),
          const SizedBox(width: 5),
          Expanded(child: _buildReplyContent()),
          const SizedBox(width: 10),
          _buildReplyLikeSection(),
        ],
      ),
    );
  }

  Widget _buildReplyAvatar() {
    if (isGhostCard == true) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: AppColors.primaryColor,
        child: const FaIcon(
          FontAwesomeIcons.ghost,
          color: Colors.white,
          size: 12,
        ),
      );
    }

    return CircleAvatar(
      radius: 13,
      backgroundImage: NetworkImage(reply.authorId?.avatarUrl ?? ""),
    );
  }

  Widget _buildReplyContent() {
    final displayName =
        isGhostCard == true
            ? (reply.authorId?.anonymousId ?? "")
            : (reply.authorId?.displayName ?? "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          reply.content ?? "",
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyLikeSection() {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            reply.reactedEmoji?.value == "❤️"
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart,
            color: const Color.fromARGB(255, 65, 6, 5).withOpacity(0.75),
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            reply.reactionCount?.value.toString() ?? "0",
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
