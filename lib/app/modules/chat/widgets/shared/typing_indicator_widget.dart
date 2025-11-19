import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TypingIndicatorWidget extends StatelessWidget {
  const TypingIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 5,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Lottie.asset(
          "assets/images/typing.json",
          height: 50,
        ),
      ),
    );
  }
}
