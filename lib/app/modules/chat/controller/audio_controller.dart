import 'dart:io';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class AudioController extends GetxController {
  RecorderController recorderController = RecorderController();
  PlayerController playerController = PlayerController();

  final Rxn<File> selectedFile = Rxn<File>(null);
  final RxBool isRecording = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool showAudioPreview = false.obs;
  final RxBool isRecordingPaused = false.obs;

  String? _audioFilePath;

  @override
  void onInit() {
    super.onInit();
    playerController.onCompletion.listen((_) async {
      if (selectedFile.value != null && isAudioFile(selectedFile.value!.path)) {
        await playerController.stopPlayer();
        await playerController.preparePlayer(
          path: selectedFile.value!.path,
        );
        isPlaying.value = false;
      }
    });
  }

  bool isAudioFile(String path) {
    return path.toLowerCase().endsWith('.aac') ||
        path.toLowerCase().endsWith('.mp3') ||
        path.toLowerCase().endsWith('.wav');
  }

  String? getFileType(String path) {
    if (isAudioFile(path)) {
      return "audio";
    }
    return null;
  }

  Future<void> startRecording() async {
    try {
      HapticFeedback.lightImpact();
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        CustomSnackbar.showErrorToast("Permission denied");
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      _audioFilePath =
          '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.aac';

      await recorderController.record(
        path: _audioFilePath,
        bitRate: 128000,
      );

      isRecording.value = true;
      showAudioPreview.value = true;
    } catch (e) {
      debugPrint("Error starting recording: $e");
      CustomSnackbar.showErrorToast("Failed to start recording");
      isRecording.value = false;
    }
  }

  Future<void> pauseRecording() async {
    HapticFeedback.lightImpact();
    try {
      final path = await recorderController.stop();
      isRecordingPaused.value = true;
      if (path == null) return;
      selectedFile.value = File(path);
      await playerController.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
        noOfSamples: 100,
      );
    } catch (e) {
      debugPrint("Error pausing recording: $e");
      CustomSnackbar.showErrorToast("Failed to pause recording");
    }
  }

  void deleteRecording() {
    HapticFeedback.lightImpact();
    try {
      selectedFile.value = null;
      isRecording.value = false;
      showAudioPreview.value = false;
      isRecordingPaused.value = false;
    } catch (_) {}
  }

  Future<void> resumeRecording() async {
    try {
      if (_audioFilePath == null) {
        CustomSnackbar.showErrorToast("No recording to resume");
        return;
      }
      await recorderController.record(path: _audioFilePath);
      // isRecording.value = true;
      isRecordingPaused.value = false;
    } catch (e) {
      debugPrint("Error resuming recording: $e");
      CustomSnackbar.showErrorToast("Failed to resume recording");
      isRecording.value = false;
    }
  }

  Future<void> togglePlayback() async {
    try {
      if (selectedFile.value == null ||
          !isAudioFile(selectedFile.value!.path)) {
        CustomSnackbar.showErrorToast("Invalid audio file");
        return;
      }

      final currentState = playerController.playerState;

      if (currentState == PlayerState.playing) {
        await playerController.pausePlayer();
        isPlaying.value = false;
        return;
      }

      // Always prepare the player before starting playback
      await playerController.preparePlayer(
        path: selectedFile.value!.path,
        noOfSamples: 44100,
        shouldExtractWaveform: true,
      );

      // Set up completion listener
      playerController.onCompletion.listen((_) {
        isPlaying.value = false;
        playerController.pausePlayer();
      });

      await playerController.startPlayer();
      isPlaying.value = true;
    } catch (e) {
      debugPrint("Error toggling playback: $e");
      CustomSnackbar.showErrorToast("Error playing audio");
      isPlaying.value = false;
    }
  }

  // Reset all state
  void resetState() {
    selectedFile.value = null;
    showAudioPreview.value = false;
    isPlaying.value = false;
    isRecordingPaused.value = false;
    isRecordingPaused.value = false;
    recorderController = RecorderController();
    playerController = PlayerController();
    if (isPlaying.value) {
      playerController.pausePlayer();
      isPlaying.value = false;
    }
  }

  @override
  void onClose() {
    resetState();
    recorderController.dispose();
    playerController.dispose();
    super.onClose();
  }
}
