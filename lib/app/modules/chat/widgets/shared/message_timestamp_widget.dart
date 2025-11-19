import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTimestampWidget extends StatelessWidget {
  final DateTime? createdAt;
  final bool isReceiver;

  const MessageTimestampWidget({
    super.key,
    this.createdAt,
    this.isReceiver = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isReceiver
          ? const EdgeInsets.only(left: 5.0)
          : const EdgeInsets.only(right: 8.0),
      child: Text(
        createdAt != null ? DateFormat("hh:mm a").format(createdAt!) : "",
        style: TextStyle(
          fontSize: 8,
          color: isReceiver ? Colors.grey : Colors.white70,
        ),
      ),
    );
  }
}
