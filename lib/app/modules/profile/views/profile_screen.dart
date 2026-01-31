import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/modules/post/widgets/poll_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_card_widget.dart';
import 'package:casarancha/app/modules/post/widgets/post_widget.dart';
// import 'package:casarancha/app/modules/post/widgets/video_media_player.dart';
import 'package:casarancha/app/modules/profile/widgets/profile_setting_bottom_sheet.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_thumbnail_network.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/verification_badge.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final RxInt selectedTab = 0.obs;
  final RxBool isLoading = false.obs;
  // final RxBool isFollowing = false.obs;

  final _tabs = ['Posts', 'Photos', 'Videos', 'Music'];
  final userController = Get.find<UserController>();
  final postController = Get.find<PostController>();

  Rxn<UserModel> userModel = Rxn<UserModel>();

  final RxList<String> allUserPictures = RxList<String>([]);
  final RxList<String> allUserVideos = RxList<String>([]);
  final RxList<String> allUserMusic = RxList<String>([]);

  @override
  void initState() {
    super.initState();
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    postController.allPersonalPost.clear();
    userModel.value = null;
    allUserPictures.clear();
    allUserVideos.clear();
    allUserMusic.clear();
  }

  Future<void> fetchData() async {
    String userId = widget.userId ?? "";
    if (userId.isEmpty) {
      userId = userController.userModel.value?.id ?? "";
    }
    final res = await userController.getAllUserPost(userId: userId);
    if (res != null) postController.allPersonalPost.value = res;
    final user = await userController.getUserById(userId: userId);
    if (user != null) userModel.value = user;
    setState(() => isLoading.value = false);
    final pictures = await userController.getAllUserMedia(
      userId: userId,
      type: "image",
    );
    if (pictures != null) allUserPictures.value = pictures;
    final videos = await userController.getAllUserMedia(
      userId: userId,
      type: "video",
    );
    if (videos != null) allUserVideos.value = videos;
    final music = await userController.getAllUserMedia(
      userId: userId,
      type: "audio",
    );
    if (music != null) allUserMusic.value = music;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: AppColors.bgGradient),
          child:
              isLoading.value
                  ? const Center(child: Loader2())
                  : ListView(
                    children: [
                      SizedBox(
                        height: Get.height * 0.355,
                        child: _buildHeader(),
                      ),
                      _buildBio(),
                      _buildNewAppBar(),
                      SizedBox(height: 15),
                      _buildQuickActionButton(),
                      SizedBox(height: 5),
                      Obx(
                        () =>
                            [
                              // allUserPostScreen(),
                              AllProfilePost(),
                              photoSection(),
                              videoSection(),
                              musicSection(),
                            ][selectedTab.value],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Obx _buildQuickActionButton() {
    return Obx(() {
      if (selectedTab.value == 1) {
        return InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  FontAwesomeIcons.plus,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  "Add Photo",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (selectedTab.value == 2) {
        return InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  FontAwesomeIcons.plus,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  "Add Video",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  Padding _buildNewAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          return Obx(() {
            final isSelected = selectedTab.value == index;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index != _tabs.length - 1 ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    selectedTab.value = index;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color.fromARGB(255, 255, 223, 223)
                              : const Color.fromARGB(255, 236, 237, 238),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _tabs[index],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color:
                            isSelected
                                ? AppColors.primaryColor
                                : Colors.grey[600],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  Padding _buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VerifiedInlineText(
                text: userModel.value?.displayName ?? "",
                verified: userModel.value?.verificationBadges?.profile == true ||
                    userModel.value?.isVerified == true,
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                badgeSize: 16,
              ),
              widget.userId == null ||
                      widget.userId == userController.userModel.value?.id
                  ? SizedBox.shrink()
                  : IconButton(
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.chat,
                        arguments: {
                          'chatHead': ChatListModel(
                            userId: userModel.value?.id,
                            displayName: userModel.value?.displayName,
                            avatar: userModel.value?.avatarUrl,
                            online: false,
                          ),
                        },
                      );
                    },
                    icon: Icon(
                      FontAwesomeIcons.solidMessage,
                      color: AppColors.primaryColor,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 4),
          if ((userModel.value?.education ?? "").isNotEmpty)
            VerifiedInlineText(
              text: userModel.value?.education ?? "",
              verified: userModel.value?.verificationBadges?.school == true,
              style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[700]),
              badgeSize: 12,
            ),
          if ((userModel.value?.work ?? "").isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: VerifiedInlineText(
                text: userModel.value?.work ?? "",
                verified: userModel.value?.verificationBadges?.work == true,
                style: Get.textTheme.bodySmall!.copyWith(color: Colors.grey[700]),
                badgeSize: 12,
              ),
            ),
          // const SizedBox(height: 2),
          Obx(() {
            if (userModel.value?.id == userController.userModel.value?.id) {
              return SizedBox.shrink();
            }
            return CustomButton(
              width: Get.width * 0.45,
              height: 45,
              ontap: () async {
                userModel.value?.isFollowing!.value =
                    !userModel.value!.isFollowing!.value;
                if (userModel.value!.isFollowing!.value) {
                  userModel.value!.followerCount!.value++;
                } else {
                  userModel.value!.followerCount!.value--;
                }
                await userController.toggleFollow(
                  followId: widget.userId!,
                  showLoader: false,
                );
              },
              isLoading: false.obs,
              child: Text(
                userModel.value!.isFollowing!.value ? "Unfollow" : "Follow",
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
          const SizedBox(height: 5),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return FollowFollowingViers(
                        userId: userModel.value?.id ?? "",
                        isFollowers: true,
                      );
                    },
                  );
                },
                child: Obx(() {
                  return Text(
                    formatText(
                      userModel.value?.followerCount?.value,
                      "Follower",
                    ),
                    style: Get.textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ),
              Container(
                color: Colors.black,
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return FollowFollowingViers(
                        userId: userModel.value?.id ?? "",
                        isFollowers: false,
                      );
                    },
                  );
                },
                child: Obx(() {
                  return Text(
                    formatText(
                      userModel.value?.followingCount?.value,
                      "Following",
                    ),
                    style: Get.textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userModel.value?.bio ?? "",
            style: Get.textTheme.bodySmall!.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          if (userModel.value?.work != null) ...[
            Row(
              children: [
                Text(
                  "Work",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                // Icon(Icons.verified, size: 16, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 5),
            Text(userModel.value?.work ?? ""),
          ],

          const SizedBox(height: 10),
          if (userModel.value?.education != null) ...[
            Row(
              children: [
                Text(
                  "Education",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                // Icon(Icons.verified, size: 16, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 5),
            Text(userModel.value?.education ?? ""),
          ],
          Divider(height: 20),
        ],
      ),
    );
  }

  SizedBox _buildHeader() {
    return SizedBox(
      height: Get.height * 0.355,
      child: Stack(
        children: [
          buildCoverPhoto(),
          Container(
            margin: EdgeInsets.only(top: Get.height * 0.018),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: Get.context!,
                      builder: (context) {
                        return ProfileSettingBottomSheet();
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.more_vert_outlined, size: 13),
                  ),
                ),
              ],
            ),
          ),
          widget.userId?.isEmpty ?? true
              ? Positioned(
                bottom: Get.height * 0.067,
                right: 10,
                child: InkWell(
                  onTap: () async {
                    final image = await pickImage();
                    if (image == null) return;
                    String? coverPhotoUrl = await userController
                        .uploadCoverPhoto(imageFile: image);
                    if (coverPhotoUrl == null) return;
                    userModel.value?.coverPhotoUrl = coverPhotoUrl;
                    userModel.refresh();
                  },
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.camera, size: 13),
                  ),
                ),
              )
              : SizedBox.shrink(),
          Positioned(bottom: 0, left: 20, child: _buildAvater()),
          Positioned(
            bottom: Get.height * 0.02,
            right: 20,
            child: InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.editProfile);
              },
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
                  SizedBox(width: 3),
                  Text(
                    "Edit Profile Info",
                    style: Get.textTheme.bodyMedium!.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCoverPhoto() {
    return Obx(() {
      if (userController.isloading.value) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Image.asset(
            "assets/images/pp.png",
            height: Get.height * 0.3,
            width: Get.width,
            fit: BoxFit.cover,
          ),
        );
      }
      if (userModel.value?.coverPhotoUrl?.isEmpty ?? true) {
        return Image.asset(
          "assets/images/pp.png",
          height: Get.height * 0.3,
          width: Get.width,
          fit: BoxFit.cover,
        );
      }
      return CachedNetworkImage(
        imageUrl: userModel.value?.coverPhotoUrl ?? "",
        height: Get.height * 0.3,
        width: Get.width,
        fit: BoxFit.cover,
        placeholder: (context, url) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Image.asset(
              "assets/images/pp.png",
              height: Get.height * 0.3,
              width: Get.width,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    });
  }

  Widget _buildAvater() {
    return Stack(
      children: [
        Container(
          height: Get.height * 0.1,
          width: Get.height * 0.1,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(userModel.value?.avatarUrl ?? ""),
              fit: BoxFit.cover,
            ),
            border: Border.all(width: 2, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryColor,
              child: Icon(Icons.camera, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget allUserPostScreen() {
    return Obx(() {
      if (postController.allPersonalPost.isEmpty) {
        return SizedBox(
          height: Get.height * 0.65,
          width: Get.width,
          child: Center(
            child: Text("No posts found", style: Get.textTheme.bodyMedium),
          ),
        );
      }
      return ListView.builder(
        itemCount: postController.allPersonalPost.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        itemBuilder: (context, index) {
          Widget widget = SizedBox.shrink();
          final post = postController.allPersonalPost[index];
          if (post.poll != null || post.originalPost?.poll != null) {
            widget = buildPollWidget(post: post, isProfilePost: true);
          } else {
            widget = PostCard(post: post, isProfilePost: true);
          }
          return Column(children: [widget, Divider(height: 30)]);
        },
      );
    });
  }

  Widget photoSection() {
    return Obx(() {
      if (allUserPictures.isEmpty) {
        return SizedBox(
          height: Get.height * 0.2,
          width: Get.width,
          child: Center(
            child: Text("Empty Photo Post", style: Get.textTheme.bodyMedium),
          ),
        );
      }
      return GridView.builder(
        key: const PageStorageKey("photoSectionGrid"),
        itemCount: allUserPictures.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0.0,
          mainAxisSpacing: 0,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final photoPost = allUserPictures[index];
          return InkWell(
            onTap: () {
              Get.to(() => PictureFullScreen(imageUrl: photoPost));
              // Get.toNamed(AppRoutes.viewMediaFullScreen);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: photoPost,
                  fit: BoxFit.cover,
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
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget musicSection() {
    return Obx(() {
      if (allUserMusic.isEmpty) {
        return SizedBox(
          height: Get.height * 0.2,
          width: Get.width,
          child: Center(
            child: Text("Empty Music Post", style: Get.textTheme.bodyMedium),
          ),
        );
      }
      return ListView.builder(
        itemCount: allUserMusic.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final musicUrl = allUserMusic[index];
          return MusicCard(
            musicUrl: musicUrl,
            avaterUrl: userModel.value?.avatarUrl ?? "",
            index: index,
          );
        },
      );
    });
  }

  Widget videoSection() {
    return Obx(() {
      if (allUserVideos.isEmpty) {
        return SizedBox(
          height: Get.height * 0.2,
          width: Get.width,
          child: Center(
            child: Text("Empty Video Post", style: Get.textTheme.bodyMedium),
          ),
        );
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allUserVideos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0.2,
          mainAxisSpacing: 0.5,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          final videoPost = allUserVideos[index];

          return FutureBuilder(
            future: generateThumbnail(videoPost),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: Get.height * 0.2,
                    width: Get.width,
                    color: Colors.grey,
                  ),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                return Icon(Icons.error);
              }

              return InkWell(
                onTap: () {
                 Get.to(() => LittleVideoViewer(videoPost: videoPost));
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: MemoryImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(30), // circular shape
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    });
  }

  String formatText(int? count, String type) {
    if (count == null) return "0 $type";
    if (count < 1000) return "$count $type";
    if (count < 1000000) return "${count / 1000}K $type";
    return "${count / 1000000}M $type";
  }
}

class MusicCard extends StatefulWidget {
  final String musicUrl;
  final String avaterUrl;
  final int index;
  const MusicCard({
    super.key,
    required this.musicUrl,
    required this.avaterUrl,
    required this.index,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.musicUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.5),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        horizontalTitleGap: 0,
        leading: Text("${widget.index + 1}"),
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.avaterUrl),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Melody of the Stars",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Lorem ipsum",
                  style: Get.textTheme.bodySmall!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(width: 40, child: playPauseWidget()),
      ),
    );
  }

  Widget playPauseWidget() {
    if (!_isInitialized) {
      return const Center(child: Loader2(size: 20));
    }
    return Container(
      decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: IconButton(
        onPressed: () {
          setState(() {
            _isPlaying ? _controller.pause() : _controller.play();
          });
        },
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class AllProfilePost extends StatefulWidget {
  const AllProfilePost({super.key});

  @override
  State<AllProfilePost> createState() => _AllProfilePostState();
}

class _AllProfilePostState extends State<AllProfilePost>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final postController = Get.find<PostController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      if (postController.allPersonalPost.isEmpty) {
        return SizedBox(
          height: Get.height * 0.65,
          width: Get.width,
          child: Center(
            child: Text("No posts found", style: Get.textTheme.bodyMedium),
          ),
        );
      }
      return ListView.builder(
        itemCount: postController.allPersonalPost.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        addAutomaticKeepAlives: true,
        itemBuilder: (context, index) {
          Widget widget = SizedBox.shrink();
          final post = postController.allPersonalPost[index];
          if (post.poll != null || post.originalPost?.poll != null) {
            widget = buildPollWidget(post: post, isProfilePost: true);
          } else {
            widget = PostCard(post: post, isProfilePost: true);
          }
          return Column(children: [widget, Divider(height: 30)]);
        },
      );
    });
  }
}

class PictureFullScreen extends StatelessWidget {
  final String imageUrl;
  const PictureFullScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
      ),
    );
  }
}

class LittleVideoViewer extends StatelessWidget {
  final String videoPost;
  const LittleVideoViewer({super.key, required this.videoPost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Chewie(
        controller: ChewieController(
          videoPlayerController: VideoPlayerController.networkUrl(
            Uri.parse(videoPost),
          ),
        ),
      ),
    );
  }
}
