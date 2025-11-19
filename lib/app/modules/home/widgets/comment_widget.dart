import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/comment_model.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/home/widgets/comment_card.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentSheet extends StatefulWidget {
  final PostModel postModel;
  final bool? isGhostCard;
  const CommentSheet({
    super.key,
    required this.postModel,
    this.isGhostCard = false,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final postController = Get.find<PostController>();
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    postController.getPostComments(postId: widget.postModel.id ?? "");
  }

  @override
  void dispose() {
    postController.commentController.clear();
    postController.comments.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Content
              _buildAllComments(scrollController),
              const SizedBox(height: 2),
              _buildInputField(),
            ],
          ),
        );
      },
    );
  }

  Padding _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Obx(
        () => CustomTextField(
          controller: postController.commentController,
          focusNode: postController.focusNode,
          hintText: "Write a comment here....",
          suffixIcon:
              postController.isReplyingComments.value
                  ? Icons.refresh
                  : Icons.send,
          suffixIconcolor: AppColors.primaryColor,
          onSuffixTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            if (postController.commentController.text.isEmpty) {
              CustomSnackbar.showErrorToast("Comment cannot be empty");
              return;
            }
            if (postController.replyCommentId.isNotEmpty) {
              await postController.replyComment(
                commentId: postController.replyCommentId,
                commentController: postController.commentController,
              );
              postController.replyCommentId = "";
              return;
            }
            await postController.commentOnPost(
              postModel: widget.postModel,
              commentController: postController.commentController,
            );
          },
        ),
      ),
    );
  }

  Expanded _buildAllComments(ScrollController scrollController) {
    return Expanded(
      child: Obx(() {
        if (postController.isFetchingComments.value) {
          return _buildLoader();
        }
        if (postController.comments.isEmpty) {
          return _buildEmptyList();
        }
        return ListView.builder(
          controller: scrollController,
          itemCount: postController.comments.length,
          itemBuilder: (context, index) {
            final comment = postController.comments[index];
            final userModel = userController.userModel.value;
            final isUserComment = userModel?.id == comment.authorId?.id;
            if (!isUserComment) {
              return CommentCard(
                comment: comment,
                isGhostCard: widget.isGhostCard,
              );
            }
            return Dismissible(
              key: ValueKey(comment.id),
              onDismissed: (direction) async {
                FocusManager.instance.primaryFocus?.unfocus();
                await onDismissed(direction, index, comment);
              },
              child: CommentCard(
                comment: comment,
                isGhostCard: widget.isGhostCard,
              ),
            );
          },
        );
      }),
    );
  }

  onDismissed(DismissDirection direction, int index, Comment comment) async {
    if (direction == DismissDirection.endToStart) {
      await postController.deleteComment(commentId: comment.id!);
      postController.comments.removeAt(index);
    }
  }

  Center _buildEmptyList() => const Center(child: Text("No comments yet"));

  Center _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}
