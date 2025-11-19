import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final Function(Duration)? onDurationChanged;
  final Function()? onVideoCompleted;
  final bool isPaused;

  const VideoPlayerWidget({
    super.key, 
    required this.url,
    this.onDurationChanged,
    this.onVideoCompleted,
    this.isPaused = false,
  });

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          
          // Notify parent about video duration
          if (widget.onDurationChanged != null && _controller.value.duration != Duration.zero) {
            widget.onDurationChanged!(_controller.value.duration);
          }
          
          // Start playing
          _controller.play();
        }
      });

    // Listen for video completion
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        widget.onVideoCompleted?.call();
      }
    });
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle pause/resume based on isPaused prop
    if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.pause();
      } else {
        _controller.play();
      }
    }
    
    // Handle URL changes
    if (widget.url != oldWidget.url) {
      _controller.dispose();
      _isInitialized = false;
      _initializeController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to pause video
  void pause() {
    if (_isInitialized) {
      _controller.pause();
    }
  }

  // Method to resume video
  void play() {
    if (_isInitialized) {
      _controller.play();
    }
  }

  // Get video duration
  Duration get duration => _controller.value.duration;

  // Get current position
  Duration get position => _controller.value.position;

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}