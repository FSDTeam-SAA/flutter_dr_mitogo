import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/controller/socket_controller.dart';
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/data/models/story_model.dart';
import 'package:casarancha/app/modules/report/widgets/report_widget.dart';
import 'package:casarancha/app/modules/story/controllers/view_story_full_screen_controller.dart';
import 'package:casarancha/app/modules/story/widgets/create_story_widget.dart';
import 'package:casarancha/app/modules/story/widgets/story_video_player.dart';
import 'package:casarancha/app/resources/app_colors.dart';
// import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
// import 'package:uuid/uuid.dart';

class ViewStoryFullScreen extends StatefulWidget {
  const ViewStoryFullScreen({super.key});

  @override
  State<ViewStoryFullScreen> createState() => _ViewStoryFullScreenState();
}

class _ViewStoryFullScreenState extends State<ViewStoryFullScreen>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  final _userController = Get.find<UserController>();
  final _storyController = Get.find<StoryController>();
  final _viewStoryScreenController = Get.find<ViewStoryFullScreenController>();
  final _socketController = Get.find<SocketController>();

  @override
  void didPop() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _storyController.markAllStoryViewed();
    });
    super.didPop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void initState() {
    super.initState();
    _viewStoryScreenController.init();
    _viewStoryScreenController.initializeProgressAnimation();
    _viewStoryScreenController.startStoryTimer();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;

    if (newValue != _viewStoryScreenController.isKeyboardVisible.value) {
      _viewStoryScreenController.isKeyboardVisible.value = newValue;

      if (_viewStoryScreenController.isKeyboardVisible.value) {
        _viewStoryScreenController.pauseStory();
      } else {
        _viewStoryScreenController.resumeStory();
      }
    }
  }

  @override
  void dispose() {
   _viewStoryScreenController.clean();
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_hasValidStories()) {
        return _buildNoStoriesView();
      }

      final storyModel = _getCurrentStoryModel();
      final stories = storyModel.stories;
      if (stories == null || stories.isEmpty) {
        return _buildNoStoriesView();
      }

      final currentStoryIndex =
          _viewStoryScreenController.currentStoryIndex.value;
      if (currentStoryIndex >= stories.length) {
        _viewStoryScreenController.currentStoryIndex.value = 0;
        return _buildNoStoriesView();
      }
      final story = stories[currentStoryIndex];

      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: GestureDetector(
          onPanUpdate: (details) {
            _viewStoryScreenController.isDragging.value = true;
            _viewStoryScreenController.dragOffset.value += details.delta.dy;
            if (_viewStoryScreenController.dragOffset.value < 0) {
              _viewStoryScreenController.dragOffset.value = 0;
            }
          },
          onPanEnd: (details) {
            if (_viewStoryScreenController.dragOffset.value >
                MediaQuery.of(context).size.height *
                    _viewStoryScreenController.dragThreshold.value) {
              _viewStoryScreenController.pauseStory();
              Navigator.maybePop(Get.context!);
              return;
            } else {
              _viewStoryScreenController.isDragging.value = false;
              _viewStoryScreenController.dragOffset.value = 0.0;
            }
          },
          child: Obx(() {
            final offset = _viewStoryScreenController.dragOffset.value;
            final isDragging = _viewStoryScreenController.isDragging.value;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius:
                      isDragging
                          ? BorderRadius.circular(20 * (offset / 100))
                          : BorderRadius.zero,
                ),
                child: Stack(
                  children: [
                    _buildStoryMedia(story),
                    _buildGestureDetector(context, storyModel),
                    _buildAnimatedProgressIndicator(storyModel),
                    _buildStoryContent(story),
                    _buildStoryViewers(storyModel, story),
                    _buildDeleteIcon(storyModel, context),
                    _buildReportButton(context, storyModel),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Widget _buildReportButton(BuildContext context, StoryModel storyModel) {
    final userModel = _userController.userModel.value;
    if (userModel?.id == storyModel.userId) return const SizedBox.shrink();
    return Positioned(
      right: 15,
      top: 50,
      child: InkWell(
        onTap: () {
          _viewStoryScreenController.pauseStory();
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ReportBottomSheet(
                reportUser: storyModel.userId!,
                type: ReportType.story,
              );
            },
          ).then((_) {
            _viewStoryScreenController.resumeStory();
          });
        },
        child: const Icon(Icons.report),
      ),
    );
  }

  Obx _buildDeleteIcon(StoryModel storyModel, BuildContext context) {
    return Obx(() {
      final userId = _userController.userModel.value?.id ?? "";
      final bool isSender = userId == storyModel.userId;
      if (!isSender) return const SizedBox.shrink();
      return Positioned(
        right: 20,
        top: Get.height * 0.07,
        child: IconButton(
          onPressed: () async {
            _viewStoryScreenController.pauseStory();
            await displayDeleteStoryDialog(
              context: context,
              userId: userId,
              storyUserId: storyModel.userId ?? "",
              storyId: storyModel.id ?? "",
              controller: _storyController,
            );
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
        // child: InkWell(
        //   onTap: () async {
        //     await displayDeleteStoryDialog(
        //       context: context,
        //       userId: userId,
        //       storyUserId: storyModel.userId ?? "",
        //       storyId: storyModel.id ?? "",
        //       controller: _storyController,
        //     );
        //   },
        //   child: const Icon(
        //     Icons.delete,
        //     color: Colors.red,
        //   ),
        // ),
      );
    });
  }

  bool _hasValidStories() {
    if (_storyController.allstoriesList.isEmpty) return false;

    final index = _viewStoryScreenController.currentUserIndex.value;
    if (index >= _storyController.allstoriesList.length) {
      _viewStoryScreenController.currentUserIndex.value = 0;
      return _storyController.allstoriesList.isNotEmpty;
    }
    final storyModel = _storyController.allstoriesList[index];
    if (storyModel.stories == null || storyModel.stories!.isEmpty) {
      return false;
    }

    return true;
  }

  StoryModel _getCurrentStoryModel() {
    final index = _viewStoryScreenController.currentUserIndex.value;
    if (index >= _storyController.allstoriesList.length) {
      _viewStoryScreenController.currentUserIndex.value = 0;
      return _storyController.allstoriesList.first;
    }
    return _storyController.allstoriesList[index];
  }

  Widget _buildNoStoriesView() {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'No stories available',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStoryMedia(Stories story) {
    return Center(
      child:
          story.mediaType == 'video'
              ? Obx(
                () => VideoPlayerWidget(
                  key: _viewStoryScreenController.videoPlayerKey,
                  url: story.mediaUrl ?? "",
                  onDurationChanged:
                      _viewStoryScreenController.onVideoDurationChanged,
                  onVideoCompleted: _viewStoryScreenController.onVideoCompleted,
                  isPaused: _viewStoryScreenController.isPaused.value,
                ),
              )
              : CachedNetworkImage(
                imageUrl: story.mediaUrl ?? "",
                width: Get.width,
                height: Get.height * 0.67,
                errorWidget: (context, url, error) {
                  return Container(
                    width: Get.width,
                    height: Get.height * 0.67,
                    color: Colors.grey[800],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text(
                          'Media not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
                placeholder:
                    (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
              ),
    );
  }

  Widget _buildGestureDetector(BuildContext context, StoryModel storyModel) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: (_) => _viewStoryScreenController.pauseStory(),
      onLongPressEnd: (_) => _viewStoryScreenController.resumeStory(),
      onTapDown: (details) {
        if (_viewStoryScreenController.isDragging.value) return;

        final dx = details.globalPosition.dx;
        final screenWidth = Get.width;
        const edgeZoneWidth = 80.0;

        if (dx <= edgeZoneWidth) {
          _viewStoryScreenController.goToPreviousStory();
        } else if (dx >= screenWidth - edgeZoneWidth) {
          _viewStoryScreenController.goToNextStory();
        }
      },
    );
  }

  Widget _buildAnimatedProgressIndicator(StoryModel storyModel) {
    return Positioned(
      top: 40,
      left: 10,
      right: 10,
      child: Row(
        children:
            storyModel.stories!.asMap().entries.map((entry) {
              final index = entry.key;
              final currentIndex =
                  _viewStoryScreenController.currentStoryIndex.value;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: AnimatedBuilder(
                    animation: _viewStoryScreenController.progressAnimation,
                    builder: (context, child) {
                      double progress = 0.0;

                      if (index < currentIndex) {
                        progress = 1.0; // Completed stories
                      } else if (index == currentIndex) {
                        progress =
                            _viewStoryScreenController
                                .progressAnimation
                                .value; // Current story
                      } else {
                        progress = 0.0; // Future stories
                      }

                      return LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 3,
                      );
                    },
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStoryContent(Stories story) {
    if (story.content?.isEmpty == true) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: Get.height * 0.15,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
        child: Text(
          story.content ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildStoryViewers(StoryModel storyModel, Stories story) {
    return Obx(() {
      final userModel = _userController.userModel.value;
      if (userModel == null) return const SizedBox.shrink();
      final isOwner = userModel.id == storyModel.userId;

      if (isOwner) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ViewSoryViewersWidget(stories: story, story: storyModel),
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildTextField(storyModel),
          Obx(
            () => SizedBox(
              height:
                  _viewStoryScreenController.isKeyboardVisible.value
                      ? 10
                      : 65.0,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTextField(StoryModel storyModel) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          const SizedBox(width: 2),
          Expanded(
            child: TextFormField(
              controller: _viewStoryScreenController.textController,
              cursorColor: AppColors.primaryColor,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: -44.5,
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                FocusManager.instance.primaryFocus?.unfocus();
                if (_viewStoryScreenController.textController.text.isEmpty) {
                  return;
                }
                final userModel = _userController.userModel.value;
                final senderId = userModel?.id ?? "";
                final tempId = const Uuid().v4();
                final story =
                    storyModel.stories![_viewStoryScreenController
                        .currentStoryIndex
                        .value];
                MessageModel message = MessageModel(
                  senderId: senderId,
                  receiverId: storyModel.userId,
                  messageType: "text",
                  clientGeneratedId: tempId,
                  storyMediaUrl: story.mediaUrl,
                  message: _viewStoryScreenController.textController.text,
                );
                _socketController.sendMessage(message: message);
                _viewStoryScreenController.textController.clear();
              },
              icon: Icon(Icons.send, color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
    // return const SizedBox.shrink();
  }
}
