import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class LevelStepper extends StatelessWidget {
  final double progress;
  const LevelStepper({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    const totalSteps = 4;
    final List<String> labels = ['Level 1', 'Level 2', 'Level 3', 'Level 4'];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isEven) {
              int stepIndex = index ~/ 2 + 1;
              return _buildStepCircle(progress, stepIndex);
            } else {
              int between = index ~/ 2 + 1;
              return _buildProgressLine(progress, between);
            }
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            return Text(
              labels[index],
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color:
                    (progress.round() == index + 1)
                        ? Colors.red.shade800
                        : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepCircle(double progress, int level) {
    bool isCompleted = progress >= level;
    bool isCurrent = progress.floor() + 1 == level;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color:
            isCompleted
                ? Colors.red.shade800
                : isCurrent
                ? Colors.red.shade100
                : Colors.white,
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(double progress, int betweenStep) {
    double start = betweenStep.toDouble();
    double percent = 0;

    if (progress >= start) {
      percent = 1;
    } else if (progress > (start - 1)) {
      percent = progress - (start - 1);
    }

    return Expanded(
      child: Stack(
        children: [
          Container(height: 4, color: Colors.white),
          FractionallySizedBox(
            widthFactor: percent.clamp(0.0, 1.0),
            child: Container(height: 4, color: Colors.red.shade800),
          ),
        ],
      ),
    );
  }
}
