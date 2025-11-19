import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoMediaPlayer extends StatefulWidget {
  final String url;
  // final List<Media> mediaList;
  final PostModel postModel;
  const VideoMediaPlayer({
    super.key,
    required this.url,
    required this.postModel,
  });

  @override
  State<VideoMediaPlayer> createState() => _VideoMediaPlayerState();
}

class _VideoMediaPlayerState extends State<VideoMediaPlayer>
    with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));

    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primaryColor, // already played
            handleColor: Colors.white, // draggable circle
            backgroundColor: Colors.grey, // unplayed
            bufferedColor: Colors.grey.shade300, // buffered
          ),
          cupertinoProgressColors: ChewieProgressColors(
            playedColor: AppColors.primaryColor,
            handleColor: Colors.white,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.shade300,
          ),
          videoPlayerController: _videoController,
          autoPlay: false,
          looping: true,
          allowFullScreen: false,
          allowMuting: true,
          aspectRatio: _videoController.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_chewieController == null || !_videoController.value.isInitialized) {
      return buildLoader();
    }

    return VisibilityDetector(
      key: const Key("video_media_player"),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.7) {
          _videoController.play();
        } else {
          _chewieController?.pause();
          _videoController.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black.withValues(alpha: 0.7)),
          AspectRatio(
            aspectRatio: _videoController.value.aspectRatio,
            child: Chewie(controller: _chewieController!),
          ),
          Positioned(
            top: Get.height * 0.04,
            right: 5,
            child: IconButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.viewMediaFullScreen,
                  arguments: {
                    "mediaUrls": [Media(type: "video", url: widget.url)],
                    "postModel": widget.postModel,
                  },
                );
              },
              icon: Icon(Icons.fullscreen, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLoader() {
    return Container(
      height: Get.height * 0.3,
      width: Get.width,
      color: Colors.black12,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }
}
