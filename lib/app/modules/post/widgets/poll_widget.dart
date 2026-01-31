import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/post/widgets/post_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/timeago.dart';
import 'package:casarancha/app/widgets/verification_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

Widget buildPollWidget({
  required PostModel post,
  bool? isGhodePost,
  required bool isProfilePost,
  VoidCallback? onDelete,
}) {
  // Check if this is a retweet
  bool isRetweet = post.originalPost != null;

  // If it's a retweet but the original post doesn't have a poll, return empty
  if (isRetweet && post.originalPost?.poll == null) {
    return const SizedBox();
  }

  // If it's not a retweet but there's no poll, return empty
  if (!isRetweet && post.poll == null) {
    return const SizedBox();
  }

  return VisibilityDetector(
    key: ValueKey(post.id),
    onVisibilityChanged: (info) {
      if (info.visibleFraction > 0.5) {
        Get.find<PostController>().addViewedPost(post.id);
      }
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main post header (retweeter's info)
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (isGhodePost == true) return;
                  Get.toNamed(
                    AppRoutes.profile,
                    arguments: {"userId": post.author?.id},
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: buildProfileImage(
                    post.author?.avatarUrl ?? "",
                    isGhodePost: isGhodePost,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGhodePost == true)
                    Row(
                      children: [
                        Text(
                          post.author?.anonymousId ?? "",
                          style: Get.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Text(
                          timeAgo(post.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (isGhodePost == true) return;
                                Get.toNamed(
                                  AppRoutes.profile,
                                  arguments: {"userId": post.author?.id},
                                );
                              },
                              child: VerifiedInlineText(
                                text: post.author?.displayName ?? "",
                                verified: post.author?.verificationBadges?.profile == true ||
                                    post.author?.isVerified == true,
                                style: Get.textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                badgeSize: 14,
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 3,
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Text(
                              timeAgo(post.createdAt),
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        if ((post.author?.education ?? "").isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: VerifiedInlineText(
                              text: post.author?.education ?? "",
                              verified: post.author?.verificationBadges?.school == true,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              badgeSize: 12,
                            ),
                          ),
                        if ((post.author?.work ?? "").isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: VerifiedInlineText(
                              text: post.author?.work ?? "",
                              verified: post.author?.verificationBadges?.work == true,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              badgeSize: 12,
                            ),
                          ),
                      ],
                    ),
                  // Show retweet indicator
                  if (isRetweet)
                    Row(
                      children: [
                        Icon(Icons.repeat, size: 12, color: Colors.green),
                        SizedBox(width: 3),
                        Text(
                          "Retweeted",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  post.location != null
                      ? Text(
                        post.location?.name ?? "",
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      )
                      : const SizedBox(),
                ],
              ),
              Spacer(),
              buildOptionAboutPost(
                postModel: post,
                isProfilePost: isProfilePost,
                onDelete: onDelete,
              ),
            ],
          ),
        ),

        // Retweet comment (if exists)
        if (isRetweet &&
            post.content?.text != null &&
            post.content!.text!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              post.content!.text!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

        // Original post content or regular post content
        if (isRetweet)
          // Show original poll post in a card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original post header
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: (){
                          if (isGhodePost == true) {
                            return;
                          }
                          Get.toNamed(
                            AppRoutes.profile,
                            arguments: {"userId": post.originalPost?.author?.id},
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: buildProfileImage(
                            post.originalPost?.author?.avatarUrl ?? "",
                            isGhodePost: isGhodePost,
                          ),
                        ),
                      ),
                      SizedBox(width: 7),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              isGhodePost == true
                                  ? Text(
                                    post.originalPost?.author?.displayName ?? "",
                                    style: Get.textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : InkWell(
                                    onTap: (){
                                      if (isGhodePost == true) {
                                        return;
                                      }
                                      Get.toNamed(
                                        AppRoutes.profile,
                                        arguments: {"userId": post.originalPost?.author?.id},
                                      );
                                    },
                                    child: VerifiedInlineText(
                                      text: post.originalPost?.author?.displayName ?? "",
                                      verified: post.originalPost?.author?.verificationBadges?.profile == true ||
                                          post.originalPost?.author?.isVerified == true,
                                      style: Get.textTheme.bodyMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      badgeSize: 12,
                                    ),
                                  ),
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              Text(
                                timeAgo(post.originalPost?.createdAt),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                          if (post.originalPost?.location != null)
                            Text(
                              post.originalPost?.location?.name ?? "",
                              style: GoogleFonts.montserrat(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Original post text
                if (post.originalPost?.content?.text != null &&
                    post.originalPost!.content!.text!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      post.originalPost!.content!.text!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Original post poll
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                    border: Border.all(width: 1, color: Colors.grey.shade200),
                  ),
                  child: PollWidget(post: post.originalPost!),
                ),
              ],
            ),
          )
        else
          // Regular poll post content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Regular post text
              if (post.content?.text != null && post.content!.text!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    post.content!.text!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

              // Regular poll container
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: const Color.fromARGB(26, 0, 0, 0),
                    ),
                  ],
                ),
                child: PollWidget(post: post),
              ),
            ],
          ),

        const SizedBox(height: 2),
        // Action buttons (always for the main post/retweet)
        buildPostActionRowWidget(postModel: post),
        const SizedBox(height: 5),
      ],
    ),
  );
}

class PollWidget extends StatelessWidget {
  final PostModel post;
  PollWidget({super.key, required this.post});

  final postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    return FlutterPolls(
      pollId: post.id,
      hasVoted: post.poll?.hasVoted ?? false,
      userVotedOptionId: post.poll?.selectedOptionId,
      onVoted: (PollOption pollOption, int newTotalVotes) async {
        return await postController.voteOnPoll(
          postId: post.id!,
          optionId: pollOption.id!,
        );
      },
      pollOptionsSplashColor: Colors.white,
      votedBackgroundColor: const Color.fromARGB(255, 240, 240, 240),
      heightBetweenOptions: 15,
      votesTextStyle: Get.textTheme.bodyMedium,
      votedPercentageTextStyle: Get.textTheme.bodyMedium?.copyWith(
        color: Colors.blueGrey,
      ),
      heightBetweenTitleAndOptions: 25,
      leadingVotedProgessColor: const Color.fromARGB(255, 226, 131, 129),
      pollTitle: Align(
        alignment: Alignment.centerLeft,
        child: Text(post.poll?.question ?? "", style: Get.textTheme.bodySmall),
      ),
      pollOptionsBorder: Border.all(width: 1, color: Colors.grey.shade300),
      pollOptions: buildOptions(),
      pollEnded:
          post.poll?.expiresAt != null &&
          post.poll!.expiresAt!.isBefore(DateTime.now()),
    );
  }

  List<PollOption> buildOptions() {
    if (post.poll?.options == null) {
      return [];
    }
    final pollOptions =
        post.poll!.options!.map((option) {
          return PollOption(
            id: option.id,
            title: Text(option.text ?? ""),
            votes: option.voteCount ?? 0,
          );
        }).toList();
    return pollOptions;
  }
}
