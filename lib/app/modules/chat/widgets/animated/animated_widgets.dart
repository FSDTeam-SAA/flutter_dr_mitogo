import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnimatedImagePreview extends StatefulWidget {
  final bool? isSender;
  final String imageUrl;
  final double width;
  final double height;
  const AnimatedImagePreview({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.isSender = true,
  });
  @override
  State<AnimatedImagePreview> createState() => AnimatedImagePreviewState();
}

class AnimatedImagePreviewState extends State<AnimatedImagePreview> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Shimmer.fromColors(
          highlightColor:
              widget.isSender == false ? AppColors.primaryColor : Colors.white,
          baseColor: widget.isSender == false
              ? Colors.grey.shade100.withOpacity(0.1)
              : Colors.grey,
          child: Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.shade300,
          ),
        );
      },
    );
  }
}

class AnimatedVideoPreview extends StatefulWidget {
  final Widget child;
  const AnimatedVideoPreview({super.key, required this.child});
  @override
  State<AnimatedVideoPreview> createState() => AnimatedVideoPreviewState();
}

class AnimatedVideoPreviewState extends State<AnimatedVideoPreview> {
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _shown ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _shown ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
