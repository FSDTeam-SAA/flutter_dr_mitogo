import 'dart:async';
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/data/models/story_model.dart';
import 'package:casarancha/app/modules/story/widgets/story_video_player.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ViewStoryFullScreenController extends GetxController
    with GetTickerProviderStateMixin {
  RxInt currentUserIndex = 0.obs;
  RxInt currentStoryIndex = 0.obs;
  RxInt tapIndexHomePage = 0.obs;

  final _storyController = Get.find<StoryController>();

  // Callback for when story changes (used by the view to restart timers)
  Function()? onStoryChanged;

  final textController = TextEditingController();
  RxBool isKeyboardVisible = false.obs;

  late AnimationController progressAnimationController;
  late Animation<double> progressAnimation;
  Timer? storyTimer;

  // Gesture and state management
  RxBool isPaused = false.obs;
  RxDouble dragOffset = 0.0.obs;
  RxBool isDragging = false.obs;

  // Story duration constants
  Duration defaultStoryDuration = Duration(seconds: 5);
  RxDouble dragThreshold = 0.2.obs; // 20% of screen height

  // Video player reference
  GlobalKey<VideoPlayerWidgetState> videoPlayerKey = GlobalKey();

  void initializeProgressAnimation() {
    progressAnimationController = AnimationController(
      duration: defaultStoryDuration,
      vsync: this,
    );

    progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(progressAnimationController);

    progressAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !isPaused.value) {
        goToNextStory();
      }
    });
  }

  bool _hasValidStories() {
    if (_storyController.allstoriesList.isEmpty) return false;

    final index = currentUserIndex.value;
    if (index >= _storyController.allstoriesList.length) {
      currentUserIndex.value = 0;
      return _storyController.allstoriesList.isNotEmpty;
    }
    final storyModel = _storyController.allstoriesList[index];
    if (storyModel.stories == null || storyModel.stories!.isEmpty) {
      return false;
    }

    return true;
  }

  void startStoryTimer() {
    if (!_hasValidStories()) return;

    final storyModel = _getCurrentStoryModel();
    final stories = storyModel.stories;
    if (stories == null || stories.isEmpty) return;

    final story = stories[currentStoryIndex.value];

    progressAnimationController.reset();

    if (story.mediaType == 'video') {
      _handleVideoStory(story);
    } else {
      _handleImageStory();
    }
  }

  StoryModel _getCurrentStoryModel() {
    final index = currentUserIndex.value;
    if (index >= _storyController.allstoriesList.length) {
      currentUserIndex.value = 0;
      return _storyController.allstoriesList.first;
    }
    return _storyController.allstoriesList[index];
  }

  //Todo: Hanlde video start timer
  void _handleVideoStory(Stories story) {
    // We'll set the duration when the video player calls onDurationChanged
    // For now, start with default duration as fallback
    progressAnimationController.duration = defaultStoryDuration;
    progressAnimationController.forward();
  }

  void _handleImageStory() {
    progressAnimationController.duration = defaultStoryDuration;
    progressAnimationController.forward();
  }

  void init() {
    currentUserIndex.value = tapIndexHomePage.value;
    if (_storyController.allstoriesList.isEmpty) {
      return;
    }
    if (currentUserIndex.value >= _storyController.allstoriesList.length) {
      currentUserIndex.value = 0;
    }
    final userStory = _storyController.allstoriesList[currentUserIndex.value];
    if (userStory.stories?.isNotEmpty ?? false) {
      final story = userStory.stories?[currentStoryIndex.value];
      _storyController.markStoryAsSeen(
        userStory.id,
        story?.id,
        userStory.userId,
      );
    }
  }

  void goToNextStory() {
    progressAnimationController.reset();
    videoPlayerKey = GlobalKey();

    if (currentUserIndex.value >= _storyController.allstoriesList.length) {
      Navigator.maybePop(Get.context!);
      return;
    }

    final storyModel = _storyController.allstoriesList[currentUserIndex.value];
    final stories = storyModel.stories;
    final allStories = _storyController.allstoriesList;

    if (stories == null || stories.isEmpty) {
      Get.back();
      return;
    }

    if (currentStoryIndex.value < stories.length - 1) {
      currentStoryIndex.value++;
      // ADD BOUNDS CHECK HERE TOO:
      if (currentStoryIndex.value < stories.length) {
        final story = stories[currentStoryIndex.value];
        _storyController.markStoryAsSeen(
          storyModel.id,
          story.id ?? "",
          storyModel.userId ?? "",
        );
      }
    } else if (currentUserIndex.value < allStories.length - 1) {
      currentUserIndex.value++;
      currentStoryIndex.value = 0;
      if (currentUserIndex.value < allStories.length) {
        final nextStoryModel = allStories[currentUserIndex.value];
        if (nextStoryModel.stories?.isNotEmpty ?? false) {
          final story = nextStoryModel.stories![0];
          _storyController.markStoryAsSeen(
            nextStoryModel.id,
            story.id ?? "",
            nextStoryModel.userId ?? "",
          );
        }
      }
    } else {
      Get.back();
      return;
    }

    onStoryChanged?.call();
    if (_hasValidStories()) {
      startStoryTimer();
    }
  }

  void goToPreviousStory() {
    progressAnimationController.reset();
    videoPlayerKey = GlobalKey(); // Reset video player key for new story

    final storyModel = _storyController.allstoriesList[currentUserIndex.value];
    final stories = storyModel.stories;
    final allStories = _storyController.allstoriesList;

    if (stories == null || stories.isEmpty) {
      return;
    }

    if (currentStoryIndex.value > 0) {
      currentStoryIndex.value--;
      final story = stories[currentStoryIndex.value];
      _storyController.markStoryAsSeen(
        storyModel.id ?? "",
        story.id ?? "",
        storyModel.userId ?? "",
      );
    } else if (currentUserIndex.value > 0) {
      currentUserIndex.value--;
      final prevStoryModel = allStories[currentUserIndex.value];
      currentStoryIndex.value = (prevStoryModel.stories?.length ?? 1) - 1;
      if (prevStoryModel.stories?.isNotEmpty ?? false) {
        final story = prevStoryModel.stories![currentStoryIndex.value];
        _storyController.markStoryAsSeen(
          prevStoryModel.id ?? "",
          story.id ?? "",
          prevStoryModel.userId ?? "",
        );
      }
    }

    // Notify view that story changed
    onStoryChanged?.call();
    if (_hasValidStories()) {
      startStoryTimer();
    }
  }

  void pauseStory() {
    isPaused.value = true;
    progressAnimationController.stop();
    storyTimer?.cancel();
    videoPlayerKey.currentState?.pause();
  }

  void resumeStory() {
    isPaused.value = false;
    progressAnimationController.forward();
    videoPlayerKey.currentState?.play();
  }

  void onVideoDurationChanged(Duration duration) {
    progressAnimationController.duration = duration;
    progressAnimationController.reset();
    progressAnimationController.forward();
  }

  void onVideoCompleted() {
    if (!isPaused.value) {
      goToNextStory();
    }
  }

  void clean() {
    progressAnimationController.dispose();
    storyTimer?.cancel();
    storyTimer = null;
    textController.clear();
    videoPlayerKey = GlobalKey();
    dragOffset.value = 0.0;
    isDragging.value = false;
  }
}
