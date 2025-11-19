import 'dart:async';

import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/profile/controller/view_media_full_screen_controller.dart';
import 'package:casarancha/app/modules/profile/widgets/view_media_full_screen_widgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// ignore: must_be_immutable
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final PostModel postModel;
  final bool isProfilePost;
  VideoPlayerController? videoPlayerController;

  FullScreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.postModel,
    required this.isProfilePost,
    this.videoPlayerController,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer>
    with TickerProviderStateMixin {

  final viewMediaController = Get.put(ViewMediaFullScreenController()); 
  final viewMediaWidgets = ViewMediaFullScreenWidgets();

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  bool _isPlaying = false;
  Timer? _hideTimer;

  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlsAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller =
          widget.videoPlayerController ??
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

      if (!_controller!.value.isInitialized) {
        await _controller!.initialize();
      }

      _controller!.setLooping(true);
      _controller!.addListener(_videoListener);

      await _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      final bool isPlaying = _controller!.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    }
  }

  void _togglePlayPause() async {
    if (_controller != null && _isInitialized) {
      if (_isPlaying) {
        await _controller!.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        await _controller!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    print("Toggled controls#$_showControls");
    if (_showControls) {
      _controlsAnimationController.forward();
      _startHideTimer();
    } else {
      _controlsAnimationController.reverse();
      _cancelHideTimer();
    }
  }

  void _startHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _onSeek(double value) {
    if (_controller != null && _isInitialized) {
      final Duration newPosition = Duration(
        milliseconds:
            (value * _controller!.value.duration.inMilliseconds).round(),
      );
      _controller!.seekTo(newPosition);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _cancelHideTimer();
    _controlsAnimationController.dispose();
    viewMediaController.dispose();
    _controller?.removeListener(_videoListener);
    // only dispose if widget created it
    if (widget.videoPlayerController == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
        child: Stack(
          children: [
            // Video Player
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

            // Tap detector for showing/hiding controls
            GestureDetector(
              onTap: _toggleControls,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),

            // Controls overlay
            if (_isInitialized)
              AnimatedBuilder(
                animation: _controlsAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _controlsAnimation.value,
                    child:
                        _showControls
                            ? _buildControls()
                            : const SizedBox.shrink(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar and time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller!,
                    builder: (context, value, child) {
                      final position = value.position;
                      final duration = value.duration;
                      final progress =
                          duration.inMilliseconds > 0
                              ? position.inMilliseconds /
                                  duration.inMilliseconds
                              : 0.0;

                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12.0,
                          ),
                          trackHeight: 3.0,
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            _onSeek(value);
                          },
                          onChangeStart: (value) {
                            _cancelHideTimer();
                          },
                          onChangeEnd: (value) {
                            _startHideTimer();
                          },
                        ),
                      );
                    },
                  ),

                  // Progress bar
                  // StreamBuilder(
                  //   stream: Stream.periodic(const Duration(milliseconds: 100)),
                  //   builder: (context, snapshot) {
                  //     if (_controller == null || !_isInitialized) {
                  //       return const SizedBox.shrink();
                  //     }

                  //     final position = _controller!.value.position;
                  //     final duration = _controller!.value.duration;
                  //     final progress =
                  //         duration.inMilliseconds > 0
                  //             ? position.inMilliseconds /
                  //                 duration.inMilliseconds
                  //             : 0.0;
                  //   },
                  // ),

                  // Time display and controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        // Play/Pause button
                        GestureDetector(
                          onTap: () {
                            _togglePlayPause();
                            _startHideTimer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Time display
                        StreamBuilder(
                          stream: Stream.periodic(
                            const Duration(milliseconds: 100),
                          ),
                          builder: (context, snapshot) {
                            if (_controller == null || !_isInitialized) {
                              return const Text(
                                '0:00 / 0:00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              );
                            }

                            final position = _controller!.value.position;
                            final duration = _controller!.value.duration;

                            return Text(
                              '${_formatDuration(position)} / ${_formatDuration(duration)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // Fullscreen button (optional)
                        GestureDetector(
                          onTap: () {
                            // Implement fullscreen functionality if needed
                            _startHideTimer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            viewMediaWidgets.buildContent(
              postModel: widget.postModel,
              isProfilePost: widget.isProfilePost,
            ),
          ],
        ),
      ),
    );
  }
}
