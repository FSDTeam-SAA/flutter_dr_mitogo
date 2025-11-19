import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SwipeableMessage extends StatefulWidget {
  final Widget child;
  final bool isSender;
  final VoidCallback? onSwipe;
  final double swipeThreshold;
  final Color? replyIconColor;
  final Color? replyBackgroundColor;

  const SwipeableMessage({
    super.key,
    required this.child,
    required this.isSender,
    this.onSwipe,
    this.swipeThreshold = 60.0,
    this.replyIconColor,
    this.replyBackgroundColor,
  });

  @override
  State<SwipeableMessage> createState() => _SwipeableMessageState();
}

class _SwipeableMessageState extends State<SwipeableMessage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  // ignore: unused_field
  bool _isDragging = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _animation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = 0;
      });
    });

    _animation.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _isDragging = true;
        });
        _animationController.stop();
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          // For sender (right side): allow left swipe (negative delta)
          // For receiver (left side): allow right swipe (positive delta)
          if (widget.isSender && details.delta.dx < 0) {
            _dragOffset = math.max(_dragOffset + details.delta.dx, -100);
          } else if (!widget.isSender && details.delta.dx > 0) {
            _dragOffset = math.min(_dragOffset + details.delta.dx, 100);
          }
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          _isDragging = false;
        });

        // Check if swipe threshold is reached
        bool shouldTriggerSwipe = false;
        if (widget.isSender && _dragOffset <= -widget.swipeThreshold) {
          shouldTriggerSwipe = true;
        } else if (!widget.isSender && _dragOffset >= widget.swipeThreshold) {
          shouldTriggerSwipe = true;
        }

        if (shouldTriggerSwipe) {
          HapticFeedback.lightImpact();
          widget.onSwipe?.call();
        }

        // Reset position with animation
        _resetPosition();
      },
      child: Stack(
        children: [
          // Reply icon background
          if (_dragOffset != 0)
            Positioned.fill(
              child: Container(
                alignment: widget.isSender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedOpacity(
                  opacity: (_dragOffset.abs() / 100).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (widget.replyBackgroundColor ?? Colors.blue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.reply,
                      color: widget.replyIconColor ?? Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          // Message bubble
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
