import 'dart:ui';
import 'package:flutter/material.dart';


class ReactionRow extends StatelessWidget {
  final void Function(String emoji) onReactionSelected;
  const ReactionRow({super.key, required this.onReactionSelected});

  
  static const List<String> emojis = ['❤️', '😂', '👍', '😮', '😢', '👎'];
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final clampedOpacity = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clampedOpacity,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16), // Slide up 16px
            child: Transform.scale(
              scale: 0.85 + 0.15 * value, // Scale from 0.85 to 1.0
              child: child,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred/darkened background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: emojis.map((emoji) {
                return GestureDetector(
                  onTap: () => onReactionSelected(emoji),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.elasticOut,
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
