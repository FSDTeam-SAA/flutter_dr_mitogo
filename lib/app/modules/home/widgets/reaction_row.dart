import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ReactionRowWidget extends StatefulWidget {
  final Function(String) onReactionSelected;
  final String selectedReaction;
  final int reactionCount;
  final Color? iconColor;
  final Color? textColor;

  const ReactionRowWidget({
    super.key,
    this.iconColor,
    this.textColor,
    required this.onReactionSelected,
    this.selectedReaction = '',
    required this.reactionCount,
  });

  @override
  State<ReactionRowWidget> createState() => _ReactionRowWidgetState();
}

class _ReactionRowWidgetState extends State<ReactionRowWidget>
    with TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _popupController;
  late AnimationController _emojiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _popupController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _emojiController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popupController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _popupController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _popupController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _popupController.dispose();
    _emojiController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _showReactionPopup() {
    HapticFeedback.mediumImpact();
    final RenderBox buttonRenderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final buttonSize = buttonRenderBox.size;
    final buttonPosition = buttonRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildReactionPopup(buttonPosition, buttonSize),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _popupController.forward();
  }

  Widget _buildReactionPopup(Offset buttonPosition, Size buttonSize) {
    return GestureDetector(
      onTap: () => _removeOverlay(), // Close on outside tap
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              left: buttonPosition.dx - 20,
              top: buttonPosition.dy - 40,
              child: Material(
                color: Colors.transparent,
                child: AnimatedBuilder(
                  animation: _popupController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  reactions.map((reaction) {
                                    int index = reactions.indexOf(reaction);
                                    bool isSelected =
                                        widget.selectedReaction == reaction;

                                    return AnimatedBuilder(
                                      animation: _emojiController,
                                      builder: (context, child) {
                                        double animationValue =
                                            (_emojiController.value +
                                                index * 0.1) %
                                            1.0;
                                        double scale =
                                            1.0 +
                                            0.1 *
                                                (0.5 +
                                                    0.5 *
                                                        math.sin(
                                                          animationValue *
                                                              2 *
                                                              math.pi,
                                                        ));

                                        return GestureDetector(
                                          onTap:
                                              () => _selectReaction(reaction),
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: Transform.scale(
                                              scale: scale,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      isSelected
                                                          ? Colors.blue
                                                              .withOpacity(0.2)
                                                          : Colors.transparent,
                                                  border:
                                                      isSelected
                                                          ? Border.all(
                                                            color: Colors.blue,
                                                            width: 1.5,
                                                          )
                                                          : null,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    reaction,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectReaction(String reaction) {
    HapticFeedback.lightImpact();

    // If the same reaction is selected, deselect it (pass empty string)
    if (widget.selectedReaction == reaction) {
      widget.onReactionSelected('');
    } else {
      widget.onReactionSelected(reaction);
    }

    _removeOverlay();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _popupController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
    }
  }

  void _handleTap() {
    bool hasReaction = widget.selectedReaction.isNotEmpty;

    if (hasReaction) {
      // If there's already a reaction, deselect it
      HapticFeedback.lightImpact();
      widget.onReactionSelected('');
    } else {
      // If no reaction, quick like
      HapticFeedback.lightImpact();
      widget.onReactionSelected('👍');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasReaction = widget.selectedReaction.isNotEmpty;

    return GestureDetector(
      key: _buttonKey,
      onTap: _handleTap, // Now handles both select and deselect
      onLongPressStart: (_) => _showReactionPopup(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasReaction) ...[
            Text(widget.selectedReaction, style: TextStyle(fontSize: 20)),
          ] else ...[
            Icon(
              FontAwesomeIcons.heart,
              size: 17,
              color:
                  widget.iconColor ??
                  const Color.fromARGB(255, 65, 6, 5).withOpacity(0.75),
            ),
          ],
          SizedBox(width: 4),
          Text(
            widget.reactionCount.toString(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color:
                  hasReaction
                      ? Colors.blue.shade700
                      : (widget.textColor ??
                          const Color.fromARGB(255, 24, 24, 24)),
            ),
          ),
        ],
      ),
    );
  }
}
