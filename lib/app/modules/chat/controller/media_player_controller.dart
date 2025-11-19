
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MediaPlayerController extends GetxController {
  VideoPlayerController? _videoController;
  // PlayerController? _audioController;
  final Rxn<PlayerController> _audioController = Rxn<PlayerController>(null);

  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final RxString localPath = ''.obs;
  final RxBool hasInitialized = false.obs;

  bool _isCancelled = false;
  String? _oldMediaUrl;
  ValueKey waveFormKey = ValueKey(DateTime.now().microsecondsSinceEpoch);

  // Video Controller Management
  Future<void> initializeVideoController(String mediaUrl) async {
    if (_videoController != null) {
      _videoController!.dispose();
    }

    if (mediaUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));

    _videoController!.addListener(() {
      if (!_isCancelled) update();
    });

    try {
      await _videoController!.initialize();
      if (!_isCancelled) {
        _videoController!.setVolume(1.0);
        hasInitialized.value = true;
      }
    } catch (error) {
      debugPrint("Video initialization error: $error");
    }
  }

  //Audio Controller Management
  Future<void> initializeAudioController(String mediaUrl) async {
    if (isLoading.value && mediaUrl == _oldMediaUrl) return;

    // Reset _isCancelled at the start of initialization
    _isCancelled = false;

    isLoading.value = true;
    await _disposeAudioController();

    try {
      final downloadedPath = await _downloadAudio(mediaUrl);
      if (_isCancelled || downloadedPath.isEmpty) {
        isLoading.value = false;
        return;
      }

      localPath.value = downloadedPath;
      _audioController.value = PlayerController();

      await _audioController.value!.preparePlayer(
        path: downloadedPath,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );

      if (_isCancelled) {
        await _disposeAudioController();
        isLoading.value = false;
        return;
      }

      _audioController.value!.onPlayerStateChanged.listen((state) {
        if (!_isCancelled) {
          isPlaying.value = state == PlayerState.playing;
        }
      });

      _audioController.value?.onCompletion.listen((_) async {
        _audioController.value?.seekTo(0);
        _audioController.value?.setRefresh(true);
        waveFormKey = ValueKey(DateTime.now().microsecondsSinceEpoch);
      });

      hasInitialized.value = true;
    } catch (e) {
      CustomSnackbar.showErrorToast("Error initializing audio");
      await _disposeAudioController();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _downloadAudio(String url) async {
    try {
      if (_isCancelled) return "";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200 || _isCancelled) return "";

      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$filename';
      final saveFile = File(savePath);

      await saveFile.writeAsBytes(response.bodyBytes);
      return savePath;
    } catch (e) {
      CustomSnackbar.showErrorToast("Failed to download audio");
      return "";
    }
  }

  Future<void> playPauseAudio() async {
    try {
      // Ensure _isCancelled is false before attempting to play
      if (_isCancelled) {
        _isCancelled = false;
      }

      final state = _audioController.value?.playerState;

      switch (state) {
        case PlayerState.playing:
          await _audioController.value?.pausePlayer();
          break;
        case PlayerState.paused:
        case PlayerState.initialized:
          await _audioController.value?.startPlayer();
          break;
        case PlayerState.stopped:
          await _reinitializeAudioController();
          break;
        default:
          if (_audioController.value == null) {
            // Handle reinitialization if needed
          }
      }
    } catch (e) {
      CustomSnackbar.showErrorToast("Error Playing audio");
    }
  }

  Future<void> _reinitializeAudioController() async {
    // Reset _isCancelled when reinitializing
    _isCancelled = false;

    _audioController.value = null;
    if (localPath.value.isNotEmpty) {
      _audioController.value = PlayerController();
      await _audioController.value!.preparePlayer(
        path: localPath.value,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );

      waveFormKey = ValueKey(DateTime.now().microsecondsSinceEpoch);

      if (!_isCancelled) {
        _audioController.value!.onPlayerStateChanged.listen((state) {
          if (!_isCancelled) {
            isPlaying.value = state == PlayerState.playing;
          }
        });
        await _audioController.value?.startPlayer();
      }
    }
  }

  Future<void> _disposeAudioController() async {
    if (_audioController.value == null) return;

    try {
      await _audioController.value!.pausePlayer();
      _audioController.value!.dispose();
    } catch (_) {}
    _audioController.value = null;
  }

  void reset() {
    _isCancelled = false;
    hasInitialized.value = false;
    isPlaying.value = false;
    isLoading.value = false;
    localPath.value = '';
  }

  VideoPlayerController? get videoController => _videoController;
  Rxn<PlayerController> get audioController => _audioController;

  @override
  void onInit() {
    super.onInit();
    _isCancelled = false;
  }

  @override
  void onClose() {
    _isCancelled = true;
    if (_audioController.value != null) {
      try {
        _audioController.value!.pausePlayer();
        _audioController.value!.dispose();
      } catch (_) {}
    }

    _videoController?.dispose();
    super.onClose();
  }
}
