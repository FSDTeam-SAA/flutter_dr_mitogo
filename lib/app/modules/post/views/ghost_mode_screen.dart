import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/home/controller/home_controller.dart';
import 'package:casarancha/app/modules/level/widgets/build_level_info_card.dart';
import 'package:casarancha/app/modules/post/widgets/poll_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_card_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_shimmer.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GhostModeScreen extends StatefulWidget {
  const GhostModeScreen({super.key});

  @override
  State<GhostModeScreen> createState() => _GhostModeScreenState();
}

class _GhostModeScreenState extends State<GhostModeScreen> {
  final controller = Get.put(HomeController());
  final postController = Get.put(PostController());

  final userController = Get.find<UserController>();
  ScrollController scrollController = ScrollController();
  RxBool isLoadingMore = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postController.ghostPosts.isEmpty) {
        postController.getGhostFeed();
      }
    });
    postController.startTimer();
    scrollController.addListener(() async {
      if (isLoadingMore.value) return;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 1000) {
        isLoadingMore.value = true;
        await postController.getGhostFeed(loadMore: true, showLoader: false);
        isLoadingMore.value = false;
      }
    });
  }

  @override
  void dispose() {
    controller.clean();
    postController.stopTimer();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(gradient: AppColors.bgGradient),
          child: RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => postController.getGhostFeed(showLoader: false),
            child: ListView(
              controller: scrollController,
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(height: Get.height * 0.03),
                buildHeader(),
                Obx(() {
                  if (controller.showTimedWidget.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BuildLevelInformaion(),
                    );
                  }
                  return SizedBox.shrink();
                }),
                SizedBox(height: Get.height * 0.025),
                Obx(() {
                  if (postController.isGhostFeedLoading.value) {
                    return buildPostSkeletonList();
                  }
                  if (postController.ghostPosts.isEmpty) {
                    return SizedBox(
                      height: Get.height * 0.65,
                      width: Get.width,
                      child: Center(
                        child: Text(
                          "No posts found",
                          style: Get.textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final post = postController.ghostPosts[index];
                      if (post.poll != null ||
                          post.originalPost?.poll != null) {
                        return buildPollWidget(
                          post: post,
                          isGhodePost: true,
                          isProfilePost: false,
                        );
                      }
                      return PostCard(post: post, isGhostCard: true);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(height: 30);
                    },
                    itemCount: postController.ghostPosts.length,
                  );
                }),
                SizedBox(height: Get.height * 0.025),
                Obx(() {
                  if (isLoadingMore.value &&
                      postController.ghostPosts.isNotEmpty) {
                    return Loader1();
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryColor,
            child: FaIcon(FontAwesomeIcons.ghost, color: Colors.white),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Obx(() {
                final userModel = userController.userModel.value;
                return Text(
                  userModel?.anonymousId ?? "",
                  style: Get.textTheme.bodyMedium,
                );
              }),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(FontAwesomeIcons.house, size: 17),
            onPressed: () => Get.offAllNamed(AppRoutes.bottomNavigation),
          ),
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.createPost, arguments: {'anonymous': true});
            },
            child: Container(
              width: Get.width * 0.08,
              height: Get.height * 0.035,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.primaryColor,
              ),
              child: Icon(FontAwesomeIcons.plus, color: Colors.white, size: 15),
            ),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }
}
