import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/storage_controller.dart';
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/home/controller/home_controller.dart';
import 'package:casarancha/app/modules/level/widgets/build_level_info_card.dart';
import 'package:casarancha/app/modules/post/widgets/poll_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_card_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_shimmer.dart';
import 'package:casarancha/app/modules/story/controllers/view_story_full_screen_controller.dart';
import 'package:casarancha/app/modules/story/views/create_story_screen.dart';
import 'package:casarancha/app/modules/story/views/view_story_full_screen.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controller/home_scroll_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storyController = Get.find<StoryController>();
  final userController = Get.find<UserController>();
  final controller = Get.put(HomeController());
  final postController = Get.put(PostController());
  RxBool isLoadingMore = false.obs;
  // ScrollController scrollController = ScrollController();
  final scrollController = Get.find<HomeScrollController>().scrollController;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final _viewStoryScreenController = Get.put(ViewStoryFullScreenController());

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    Get.find<HomeScrollController>().refreshIndicatorKey = _refreshIndicatorKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postController.startTimer();
      if (postController.posts.isEmpty) {
        postController.getFeed(showLoader: true);
      }
      if (!_storyController.isStoryFetched.value) {
        _storyController.getAllStories();
        _storyController.getUserPostedStories();
      }
    });
    scrollController.addListener(() async {
      if (isLoadingMore.value) return;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 1000) {
        isLoadingMore.value = true;
        await postController.getFeed(loadMore: true, showLoader: false);
        isLoadingMore.value = false;
      }
    });
    saveUserOneSignalId();
  }

  void saveUserOneSignalId() async {
    final userId = userController.userModel.value?.id;
    final subId = OneSignal.User.pushSubscription.id;
    final storageController = Get.find<StorageController>();

    if (userId == null || subId == null) return;

    final lastSaved = await storageController.getLastPushId(userId);

    if (lastSaved == subId) {
      return;
    }

    await userController.saveUserOneSignalId(oneSignalId: subId);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
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
            key: _refreshIndicatorKey,
            color: const Color.fromARGB(255, 196, 109, 107),
            onRefresh: () async {
              await Get.find<PostController>().refreshHomeFeed(
                showLoader: true,
              );
            },
            child: ListView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: Get.height * 0.03),
                buildHeader(),
                SizedBox(height: Get.height * 0.025),
                Obx(() {
                  if (controller.showTimedWidget.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BuildLevelInformaion(),
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(height: Get.height * 0.02),
                      _buildStory(),
                    ],
                  );
                }),
                SizedBox(height: Get.height * 0.025),
                Obx(() {
                  if (postController.isloading.value) {
                    return buildPostSkeletonList();
                  }
                  if (postController.posts.isEmpty) {
                    return SizedBox(
                      height: Get.height * 0.65,
                      width: Get.width,
                      child: Center(
                        child: Text(
                          "no_posts_found".tr,
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
                      final post = postController.posts[index];
                      if (post.poll != null ||
                          post.originalPost?.poll != null) {
                        return buildPollWidget(
                          post: post,
                          isProfilePost: false,
                        );
                      }
                      return PostCard(post: post);
                    },
                    separatorBuilder: (context, index) {
                      return Divider(height: 30);
                    },
                    itemCount: postController.posts.length,
                  );
                }),
                SizedBox(height: Get.height * 0.025),
                Obx(() {
                  if (isLoadingMore.value && postController.posts.isNotEmpty) {
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

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.toNamed(AppRoutes.profile),
            child: Obx(() {
              final userModel = userController.userModel.value;
              return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: userModel?.avatarUrl ?? "",
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                  placeholder: (context, url) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Colors.white,
                      child: Container(
                        height: 45,
                        width: 45,
                        color: Colors.grey,
                      ),
                    );
                  },
                  errorWidget: (context, error, stackTrace) {
                    return const Icon(Icons.person, size: 40);
                  },
                ),
              );
            }),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "welcome_back_user".tr,
                style: GoogleFonts.montserrat(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Obx(() {
                final userModel = userController.userModel.value;
                return Text(
                  userModel?.displayName ?? "",
                  style: Get.textTheme.bodyMedium,
                );
              }),
            ],
          ),
          Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed(AppRoutes.notification),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // expands the tap area
              child: Icon(FontAwesomeIcons.solidBell, size: 20),
            ),
          ),

          // SizedBox(width: 13),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed(AppRoutes.searchScreen),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(FontAwesomeIcons.magnifyingGlass, size: 20),
            ),
          ),

          // SizedBox(width: 13),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed(AppRoutes.ghostMode),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                "assets/icons/hat-glasses.svg",
                height: 20,
                width: 20,
              ),
            ),
          ),

          SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _buildStory() {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      height: Get.height * 0.088,
      child: Obx(() {
        final userModel = userController.userModel.value;
        if (_storyController.allstoriesList.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: buildUserPosted(url: userModel?.avatarUrl ?? ""),
          );
        }
        return ListView.builder(
          itemCount: _storyController.allstoriesList.length + 1,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final userId = userModel?.id ?? "";
            if (index == 0) {
              final hasUserStory =
                  _storyController.allstoriesList.isNotEmpty &&
                  _storyController.allstoriesList[0].userId == userId;
              return GestureDetector(
                onTap: () {
                  if (hasUserStory) {
                    _viewStoryScreenController.tapIndexHomePage.value = 0;
                    Get.to(() => const ViewStoryFullScreen());
                  } else {
                    Get.to(() => CreateStoryScreen());
                  }
                },
                child: buildUserPosted(url: userModel?.avatarUrl ?? ""),
              );
            }

            final storyIndex = index - 1;

            if (storyIndex >= _storyController.allstoriesList.length) {
              return const SizedBox.shrink();
            }
            final story = _storyController.allstoriesList[storyIndex];
            if (story.stories == null || story.stories!.isEmpty) {
              return const SizedBox.shrink();
            }

            bool isSeen =
                story.stories?.every(
                  (s) => s.viewedBy?.contains(userId) ?? false,
                ) ??
                false;
            if (userId == story.userId) {
              return const SizedBox();
            }
            return InkWell(
              onTap: () {
                _viewStoryScreenController.tapIndexHomePage.value = storyIndex;
                Get.to(() => const ViewStoryFullScreen());
              },
              child: buildImageStory(
                url: story.avatarUrl ?? "",
                isSeen: isSeen,
              ),
            );
          },
        );
      }),
    );
  }

  Stack buildUserPosted({required String url}) {
    return Stack(
      children: [
        buildImageStory(url: url, isSeen: false),
        Positioned(
          right: 5,
          bottom: 0,
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.createStory);
            },
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primaryColor,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Container buildImageStory({required String url, required bool isSeen}) {
    return Container(
      width: Get.width * 0.18,
      height: Get.height * 0.085,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSeen ? Colors.grey : AppColors.primaryColor,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }
}
