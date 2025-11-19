import 'package:flutter/material.dart';
import 'dart:math' as math;


class WaveformWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final double waveStretch; // Controls wave frequency/compression
  final double
  middleAmplitude; // Amplitude percentage for middle section (0.0 to 1.0)
  final int numberOfWaves;

  const WaveformWidget({
    super.key,
    this.width = 300,
    this.height = 100,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
    this.waveStretch = 1.0,
    this.middleAmplitude = 0.75, // 75% amplitude in middle
    this.numberOfWaves = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: WaveformPainter(
        color: color,
        strokeWidth: strokeWidth,
        waveStretch: waveStretch,
        middleAmplitude: middleAmplitude,
        numberOfWaves: numberOfWaves,
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double waveStretch;
  final double middleAmplitude;
  final int numberOfWaves;

  WaveformPainter({
    required this.color,
    required this.strokeWidth,
    required this.waveStretch,
    required this.middleAmplitude,
    required this.numberOfWaves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final maxAmplitude = size.height * 0.4; // Maximum wave amplitude

    // Start from the left edge
    path.moveTo(0, centerY);

    // Generate waveform points
    for (double x = 0; x <= size.width; x += 2) {
      // Calculate position ratio (0 to 1)
      final positionRatio = x / size.width;

      // Create amplitude envelope - higher in middle, lower at edges
      double amplitudeMultiplier;
      if (positionRatio <= 0.2) {
        // Left edge: fade in
        amplitudeMultiplier = positionRatio * 5 * 0.3; // 30% amplitude at edges
      } else if (positionRatio >= 0.8) {
        // Right edge: fade out
        amplitudeMultiplier =
            (1 - positionRatio) * 5 * 0.3; // 30% amplitude at edges
      } else {
        // Middle section: use specified amplitude
        amplitudeMultiplier = middleAmplitude;
      }

      // Calculate wave value with stretching
      final waveValue = math.sin(
        x * numberOfWaves * math.pi / (size.width / waveStretch),
      );

      // Apply amplitude envelope
      final y = centerY + (waveValue * maxAmplitude * amplitudeMultiplier);

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WaveformPainter &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        other.waveStretch == waveStretch &&
        other.middleAmplitude == middleAmplitude &&
        other.numberOfWaves == numberOfWaves;
  }

  @override
  int get hashCode {
    return Object.hash(
      color,
      strokeWidth,
      waveStretch,
      middleAmplitude,
      numberOfWaves,
    );
  }
}
