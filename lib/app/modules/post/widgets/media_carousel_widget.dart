import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/post/widgets/post_widget.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaCarousel extends StatefulWidget {
  final List<Media> mediaList;
  final double height;
  final RxInt viewCount;
  final bool isOriginalPost;
  final RxInt currentIndex;
  final PostModel postModel;

  const MediaCarousel({
    super.key,
    required this.mediaList,
    required this.height,
    required this.viewCount,
    required this.isOriginalPost,
    required this.currentIndex,
    required this.postModel,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  double _resolveHeight(double width) {
    if (widget.mediaList.isEmpty) {
      return widget.height;
    }
    final safeIndex = widget.currentIndex.value < 0
        ? 0
        : widget.currentIndex.value >= widget.mediaList.length
            ? widget.mediaList.length - 1
            : widget.currentIndex.value;
    final media = widget.mediaList[safeIndex];
    final declaredType = media.type?.toLowerCase();
    if (declaredType == "audio") {
      return widget.height;
    }
    final dimensions = media.dimensions;
    if (dimensions == null || dimensions.width <= 0 || dimensions.height <= 0) {
      return widget.height;
    }
    final aspectRatio = dimensions.width / dimensions.height;
    if (aspectRatio <= 0) return widget.height;
    return width / aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : Get.width;
        final height = _resolveHeight(width);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: height,
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.viewMediaFullScreen,
                    arguments: {
                      "mediaUrls": widget.mediaList,
                      "postModel": widget.postModel,
                    },
                  );
                },
                child: PageView.builder(
                  onPageChanged:
                      (index) =>
                          setState(() => widget.currentIndex.value = index),
                  itemCount: widget.mediaList.length,
                  itemBuilder: (context, index) {
                    Media media = widget.mediaList[index];
                    if (media.url?.isEmpty == true) {
                      return const SizedBox.shrink();
                    }
                    return buildMedia(
                      media: media,
                      fit: BoxFit.contain,
                      postModel: widget.postModel,
                    );
                  },
                ),
              ),
              if (widget.mediaList.length > 1) _buildPageIndicator(),
              _buildViewCounter(),
            ],
          ),
        );
      },
    );
  }

  // Build page indicator (1/3, 2/3, etc.)
  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 8,
      right: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "${widget.currentIndex.value + 1}/${widget.mediaList.length}",
          style: TextStyle(
            fontSize: widget.isOriginalPost ? 11 : 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Build view counter with media type icon
  Widget _buildViewCounter() {
    final media = widget.postModel.media![widget.currentIndex.value];
    final mediaType = getMediaType(media.url!);
    final isMusicOrVideo =
        mediaType == FileType.music || mediaType == FileType.video;
    return Positioned(
      top: isMusicOrVideo ? 10 : null,
      left: 5,
      bottom: isMusicOrVideo ? null : 8,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return AllPostViewersWidget(post: widget.postModel);
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isOriginalPost ? 10 : 12,
            vertical: widget.isOriginalPost ? 9 : 10,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(widget.isOriginalPost ? 8 : 10),
          ),
          child: Row(
            children: [
              Icon(
                _getMediaIcon(),
                size: widget.isOriginalPost ? 15 : 17,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Obx(
                () => Text(
                  widget.viewCount.value.toString(),
                  style: TextStyle(
                    fontSize: widget.isOriginalPost ? 11 : 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get appropriate icon based on media type
  IconData _getMediaIcon() {
    if (widget.currentIndex.value < widget.mediaList.length) {
      final media = widget.mediaList[widget.currentIndex.value];
      final declaredType = media.type?.toLowerCase();
      if (declaredType == "image") {
        return Icons.camera_alt;
      }
      if (declaredType == "audio") {
        return Icons.audiotrack;
      }
      if (declaredType == "video") {
        return Icons.video_camera_back_rounded;
      }
      final resolvedType = getMediaType(media.url ?? "");
      if (resolvedType == FileType.music) {
        return Icons.audiotrack;
      }
      if (resolvedType == FileType.video) {
        return Icons.video_camera_back_rounded;
      }
      return Icons.camera_alt;
    }
    return Icons.camera_alt;
  }
}
