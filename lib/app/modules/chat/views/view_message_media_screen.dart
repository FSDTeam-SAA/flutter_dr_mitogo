
import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/data/models/message_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class ViewMessageMediaScreen extends StatefulWidget {
  final MessageModel message;
  const ViewMessageMediaScreen({
    super.key,
    required this.message,
  });

  @override
  State<ViewMessageMediaScreen> createState() => _ViewMessageMediaScreenState();
}

class _ViewMessageMediaScreenState extends State<ViewMessageMediaScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    _initializeMedia();
    super.initState();
  }

  void _initializeMedia() {
    if (widget.message.messageType == 'video') {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.message.mediaUrl ?? ""),
      );

      _videoController!.initialize().then((_) {
        // Create ChewieController after the video is initialized
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          // Add any additional customization here
          aspectRatio: _videoController!.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primaryColor,
            backgroundColor: Colors.grey,
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        setState(() {});
      }).catchError((error) {
        print("Video initialization error: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.message.messageType == 'video'
              ? (_chewieController != null
                  ? Expanded(
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ))
              : Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.mediaUrl ?? "",
                      fit: BoxFit.fitWidth,
                      width: Get.width,
                      height: Get.height,
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
