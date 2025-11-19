import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatShimmerEffect extends StatefulWidget {
  final int itemCount;
  final bool showSenderCards;
  final bool showReceiverCards;
  final bool showImageCards;
  final bool showAudioCards;

  const ChatShimmerEffect({
    super.key,
    this.itemCount = 8,
    this.showSenderCards = true,
    this.showReceiverCards = true,
    this.showImageCards = true,
    this.showAudioCards = true,
  });

  @override
  State<ChatShimmerEffect> createState() => _ChatShimmerEffectState();
}

class _ChatShimmerEffectState extends State<ChatShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _buildShimmerCard(index);
          },
        );
      },
    );
  }

  Widget _buildShimmerCard(int index) {
    final cardTypes = <String>[];

    if (widget.showSenderCards) cardTypes.add('sender_text');
    if (widget.showReceiverCards) cardTypes.add('receiver_text');
    if (widget.showImageCards) {
      cardTypes.add('sender_image');
      cardTypes.add('receiver_image');
    }
    if (widget.showAudioCards) {
      cardTypes.add('sender_audio');
      cardTypes.add('receiver_audio');
    }

    final cardType = cardTypes[index % cardTypes.length];

    switch (cardType) {
      case 'sender_text':
        return _buildSenderTextShimmer();
      case 'receiver_text':
        return _buildReceiverTextShimmer();
      case 'sender_image':
        return _buildSenderImageShimmer();
      case 'receiver_image':
        return _buildReceiverImageShimmer();
      case 'sender_audio':
        return _buildSenderAudioShimmer();
      case 'receiver_audio':
        return _buildReceiverAudioShimmer();
      default:
        return _buildSenderTextShimmer();
    }
  }

  Widget _buildSenderTextShimmer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        constraints: BoxConstraints(maxWidth: Get.width * 0.68),
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: Get.width * 0.4),
            const SizedBox(height: 4),
            _buildShimmerLine(width: Get.width * 0.25),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildShimmerLine(width: 30, height: 10),
                const SizedBox(width: 4),
                _buildShimmerCircle(size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverTextShimmer() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        constraints: BoxConstraints(maxWidth: Get.width * 0.68),
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerLine(width: Get.width * 0.35),
            const SizedBox(height: 4),
            _buildShimmerLine(width: Get.width * 0.28),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildShimmerLine(width: 30, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderImageShimmer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
        constraints: BoxConstraints(maxWidth: Get.width * 0.558),
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width * 0.558,
              height: Get.height * 0.32,
              decoration: BoxDecoration(
                gradient: _createShimmerGradient(),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: Get.width * 0.3),
                  const SizedBox(height: 4),
                  _buildShimmerLine(width: Get.width * 0.2),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildShimmerLine(width: 30, height: 10),
                      const SizedBox(width: 4),
                      _buildShimmerCircle(size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverImageShimmer() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 5),
        constraints: BoxConstraints(maxWidth: Get.width * 0.558),
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width * 0.558,
              height: Get.height * 0.32,
              decoration: BoxDecoration(
                gradient: _createShimmerGradient(),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: Get.width * 0.25),
                  const SizedBox(height: 4),
                  _buildShimmerLine(width: Get.width * 0.18),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildShimmerLine(width: 30, height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderAudioShimmer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        width: Get.width * 0.8,
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildShimmerCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: Get.width * 0.4, height: 4),
                  const SizedBox(height: 6),
                  _buildShimmerLine(width: Get.width * 0.2, height: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                _buildShimmerLine(width: 30, height: 10),
                const SizedBox(height: 4),
                _buildShimmerCircle(size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverAudioShimmer() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        width: Get.width * 0.8,
        decoration: BoxDecoration(
          gradient: _createShimmerGradient(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildShimmerCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(width: Get.width * 0.35, height: 4),
                  const SizedBox(height: 6),
                  _buildShimmerLine(width: Get.width * 0.25, height: 8),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildShimmerLine(width: 30, height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, double height = 12}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: _createShimmerGradient(),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildShimmerCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _createShimmerGradient(),
        shape: BoxShape.circle,
      ),
    );
  }

  LinearGradient _createShimmerGradient() {
    final isDarkMode = Get.isDarkMode;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode 
        ? [
            Colors.grey[800]!,
            Colors.grey[600]!,
            Colors.grey[800]!,
          ]
        : [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(_animation.value),
    );
  }
}