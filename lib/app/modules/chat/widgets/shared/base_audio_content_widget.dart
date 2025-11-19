import 'package:casarancha/app/data/models/message_model.dart';
import 'package:flutter/material.dart';

abstract class BaseAudioContentWidget extends StatelessWidget {
  final MessageModel messageModel;
  final bool isReceiver;

  const BaseAudioContentWidget({
    super.key,
    required this.messageModel,
    this.isReceiver = false,
  });

  // Abstract methods to be implemented by subclasses
  Widget buildPlayPauseButton();
  Widget buildWaveform();
  Widget buildSpeedButton() => const SizedBox.shrink();

  // Computed properties based on receiver/sender type
  Color get iconColor => isReceiver ? Colors.black54 : Colors.white;
  Color get waveformFixedColor =>
      isReceiver ? Colors.black38 : const Color.fromARGB(255, 206, 206, 206);
  Color get waveformLiveColor => isReceiver ? Colors.black87 : Colors.white;
  Color get loadingColor => isReceiver ? Colors.black54 : Colors.white;

  @override
  Widget build(BuildContext context) {
    if (messageModel.status == "sending") {
      return buildLoadingState();
    }

    if (messageModel.mediaUrl == null || messageModel.mediaUrl!.isEmpty) {
      return buildUnavailableState();
    }

    return buildAudioPlayer();
  }

  Widget buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: containerDecoration(),
      child: const LinearProgressIndicator(
        color: Colors.white,
      ),
    );
  }

  Widget buildUnavailableState() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: containerDecoration(),
      child: Center(
        child: Text(
          "Audio unavailable",
          style: TextStyle(color: iconColor),
        ),
      ),
    );
  }

  Widget buildAudioPlayer() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: containerDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          !isReceiver ? buildSpeedButton() : const SizedBox.shrink(),
          !isReceiver ? const SizedBox(width: 8) : const SizedBox.shrink(),
          buildPlayPauseButton(),
          const SizedBox(width: 8),
          Expanded(child: buildWaveform()),
          const SizedBox(width: 8),
          isReceiver ? buildSpeedButton() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  BoxDecoration containerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    );
  }
}
