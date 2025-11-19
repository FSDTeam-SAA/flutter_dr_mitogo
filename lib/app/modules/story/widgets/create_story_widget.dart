import 'dart:io';

import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/data/models/story_model.dart';
import 'package:casarancha/app/modules/story/controllers/story_screen_controller.dart';
import 'package:casarancha/app/modules/story/controllers/view_story_full_screen_controller.dart';
import 'package:casarancha/app/modules/story/widgets/delete_dialog.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

Future<dynamic> displayMediaOptionWidget(
  BuildContext context,
  StoryScreenController controller,
) {
  return showModalBottomSheet(
    context: context,
    builder:
        (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.videocam, color: AppColors.primaryColor),
              title: Text(
                'Select a video',
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.selectVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text(
                'Select from gallery',
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                controller.selectImage();
              },
            ),
            const SizedBox(height: 45),
          ],
        ),
  );
}

class MediaDisplayCard extends StatelessWidget {
  final StoryScreenController storyScreenController;
  final int index;
  const MediaDisplayCard({
    super.key,
    required this.storyScreenController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            MediaPreviewWidget(
              mediaFile: storyScreenController.selectedMedia[index],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => storyScreenController.removeMedia(index),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaPreviewWidget extends StatefulWidget {
  final File mediaFile;

  const MediaPreviewWidget({super.key, required this.mediaFile});

  @override
  State<MediaPreviewWidget> createState() => _MediaPreviewWidgetState();
}

class _MediaPreviewWidgetState extends State<MediaPreviewWidget> {
  VideoPlayerController? _videoController;
  bool _isVideo = false;
  bool _isLoading = true;
  final double previewWidth = 80;
  final double previewHeight = 100;

  @override
  void initState() {
    super.initState();
    _checkFileTypeAndInitialize();
  }

  Future<void> _checkFileTypeAndInitialize() async {
    final String extension =
        path.extension(widget.mediaFile.path).toLowerCase();
    _isVideo = [
      '.mp4',
      '.mov',
      '.avi',
      '.flv',
      '.wmv',
      '.3gp',
    ].contains(extension);

    if (_isVideo) {
      _videoController = VideoPlayerController.file(widget.mediaFile)
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
          });

          _videoController!.setLooping(true);
          _videoController!.setVolume(0.0); // Mute the video
          _videoController!.play(); // Auto-play the video preview
        });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: previewWidth,
        height: previewHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isVideo &&
        _videoController != null &&
        _videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: previewWidth,
              height: previewHeight,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          widget.mediaFile,
          width: previewWidth,
          height: previewHeight,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}

Future<dynamic> displayDeleteStoryDialog({
  required BuildContext context,
  required String userId,
  required String storyUserId,
  required String storyId,
  required StoryController controller,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return DeleteStoryDialog(
        onDelete:
            userId == storyUserId
                ? () async {
                  await controller.deleteStory(storyId: storyId);
                }
                : () {},
        onCancel: () {
          Navigator.pop(context);
        },
      );
    },
  );
}

class ViewSoryViewersWidget extends StatefulWidget {
  final Stories stories;
  final StoryModel story;

  const ViewSoryViewersWidget({
    super.key,
    required this.stories,
    required this.story,
  });

  @override
  State<ViewSoryViewersWidget> createState() => _ViewSoryViewersWidgetState();
}

class _ViewSoryViewersWidgetState extends State<ViewSoryViewersWidget> {
  final _storyController = Get.find<StoryController>();
  final _viewStoryScreenController = Get.find<ViewStoryFullScreenController>();

  @override
  void initState() {
    super.initState();
    getViewers();
  }

  void getViewers() async {
    await _storyController.getStoryViewers(
      storyId: widget.story.id ?? "",
      storyItemId: widget.stories.id ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.5,
      minChildSize: 0.1,
      initialChildSize: 0.1,
      builder: (BuildContext context, ScrollController scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            if (notification.extent > 0.1 &&
                !_viewStoryScreenController.isPaused.value) {
              _viewStoryScreenController.pauseStory();
            }
            
            if (notification.extent <= 0.1 &&
                _viewStoryScreenController.isPaused.value) {
              _viewStoryScreenController.resumeStory();
            }
            return true;
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(211, 223, 141, 19),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
                    child: Obx(() {
                      final viewers = _storyController.allStoryViewers.length;
                      return Text(
                        'Viewed by $viewers',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 10),

                  // List of viewers
                  Obx(
                    () => ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _storyController.allStoryViewers.length,
                      itemBuilder: (context, index) {
                        final viewer = _storyController.allStoryViewers[index];
                        return ListTile(
                          minTileHeight: 50,
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              viewer.avatarUrl ?? "",
                            ),
                          ),
                          title: Text(
                            viewer.displayName ?? "",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
