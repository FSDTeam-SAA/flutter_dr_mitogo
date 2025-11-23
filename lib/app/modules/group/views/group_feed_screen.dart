import 'package:casarancha/app/controller/group_controller.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/group_model.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/post/widgets/poll_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_card_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_shimmer.dart';
import 'package:casarancha/app/modules/report/widgets/report_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class GroupFeedScreen extends StatefulWidget {
  final GroupModel group;
  const GroupFeedScreen({super.key, required this.group});

  @override
  State<GroupFeedScreen> createState() => _GroupFeedScreenState();
}

class _GroupFeedScreenState extends State<GroupFeedScreen> {
  final postController = Get.find<PostController>();
  final groupController = Get.find<GroupController>();
  //Pagination
  RxInt currentPage = 1.obs;
  RxBool hasNextPage = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool isFabVisible = true.obs;

  final RxList<PostModel> groupFeed = <PostModel>[].obs;

  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postController.startTimer();
      groupController.getGroupFeed(
        groupId: widget.group.id ?? "",
        currentPage: currentPage,
        hasNextPage: hasNextPage,
        groupFeed: groupFeed,
      );
    });

    scrollController.addListener(() async {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // hide FAB when scrolling down
        if (isFabVisible.value) isFabVisible.value = false;
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // show FAB when scrolling up
        if (!isFabVisible.value) isFabVisible.value = true;
      }

      if (isLoadingMore.value) return;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 1000) {
        isLoadingMore.value = true;
        await groupController.getGroupFeed(
          groupId: widget.group.id ?? "",
          currentPage: currentPage,
          hasNextPage: hasNextPage,
          groupFeed: groupFeed,
          loadMore: true,
          showLoader: false,
        );
        isLoadingMore.value = false;
      }
    });
  }

  @override
  void dispose() {
    postController.stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: buildFloatingAction(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (groupController.isLoading.value) {
                  return buildPostSkeletonList();
                }
                if (groupFeed.isEmpty) {
                  return Center(
                    child: Text(
                      "no_posts_found_profile".tr,
                      style: Get.textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollController,
                  itemCount: groupFeed.length,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final post = groupFeed[index];
                    if (post.poll != null || post.originalPost?.poll != null) {
                      return buildPollWidget(
                        post: post,
                        isProfilePost: false,
                        onDelete: () {
                          groupFeed.remove(post);
                          groupFeed.refresh();
                        },
                      );
                    }
                    return PostCard(
                      post: post,
                      onDelete: () {
                        groupFeed.remove(post);
                        groupFeed.refresh();
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 30);
                  },
                );
              }),
            ),

            Obx(() {
              if (isLoadingMore.value && groupFeed.isNotEmpty) {
                return Loader1();
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Obx buildFloatingAction() {
    return Obx(
      () => AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: isFabVisible.value ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          opacity: isFabVisible.value ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              Get.toNamed(
                AppRoutes.createPost,
                arguments: {
                  "groupId": widget.group.id,
                  "groupName": widget.group.name,
                },
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        widget.group.name ?? "",
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () => Get.back(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leadingWidth: 40,
      actions: [
        PopupMenuButton(
          icon: Icon(Icons.more_vert_outlined),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Text(
                  "report".tr,
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
                        reportUser: "uid",
                        type: ReportType.group,
                      );
                    },
                  );
                },
              ),
              PopupMenuItem(
                child: Text(
                  "post".tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.createPost);
                },
              ),
              PopupMenuItem(
                child: Text(
                  "copy".tr,
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
                  "leave".tr,
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
      ],
    );
  }
}
