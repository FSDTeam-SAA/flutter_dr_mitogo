import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/profile/controller/view_media_full_screen_controller.dart';
import 'package:casarancha/app/modules/profile/widgets/view_media_full_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

class ViewMediaFullScreen extends StatefulWidget {
  final List<Media> mediaUrls;
  final PostModel postModel;
  final bool isProfilePost;
  const ViewMediaFullScreen({
    super.key,
    required this.mediaUrls,
    required this.postModel,
    required this.isProfilePost,
  });

  @override
  State<ViewMediaFullScreen> createState() => _ViewMediaFullScreenState();
}

class _ViewMediaFullScreenState extends State<ViewMediaFullScreen> {
  final PostController postController = Get.find<PostController>();
  final viewMediaController = Get.put(ViewMediaFullScreenController());

  @override
  void initState() {
    WakelockPlus.enable();
    String mediaType = widget.postModel.media?.first.type ?? "image";
    viewMediaController.mediaType.value = mediaType;
    viewMediaController.posts.add(widget.postModel);
    postController.startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // viewMediaController.initialLoad();
      await viewMediaController.getRelatedFeed();
    });
    super.initState();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    postController.stopTimer();
    viewMediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewMediaWidgets = ViewMediaFullScreenWidgets();
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      // appBar: buildAppBar(),
      body: Stack(
        children: [
          viewMediaWidgets.buildPost(isProfilePost: widget.isProfilePost),
          viewMediaWidgets.buildLoader(),
        ],
      ),
    );
  }
}
