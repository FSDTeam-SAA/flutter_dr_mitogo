import 'package:flutter/material.dart';

class VerificationBadgeIcon extends StatelessWidget {
  final double size;
  const VerificationBadgeIcon({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: const Color(0xFF1DA1F2),
    );
  }
}

class VerifiedInlineText extends StatelessWidget {
  final String text;
  final bool verified;
  final TextStyle? style;
  final double badgeSize;

  const VerifiedInlineText({
    super.key,
    required this.text,
    required this.verified,
    this.style,
    this.badgeSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: style),
        if (verified) ...[
          const SizedBox(width: 4),
          VerificationBadgeIcon(size: badgeSize),
        ],
      ],
    );
  }
}
