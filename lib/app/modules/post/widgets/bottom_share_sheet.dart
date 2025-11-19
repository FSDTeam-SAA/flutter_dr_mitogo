import 'package:casarancha/app/controller/post_controller.dart';
import 'package:casarancha/app/data/models/post_model.dart';
import 'package:casarancha/app/modules/report/widgets/report_widget.dart';
import 'package:casarancha/app/utils/get_file_type.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

void showShareBottomSheet({required PostModel post, RxInt? index}) {
  showModalBottomSheet(
    context: Get.context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => buildSocialShareSheet(post: post, index: index),
  );
}

Widget buildSocialShareSheet({required PostModel post, RxInt? index}) {
  return DraggableScrollableSheet(
    initialChildSize: 0.31,
    minChildSize: 0.3,
    maxChildSize: 0.8,
    builder: (context, scrollController) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Share",
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    Text(
                      "Quick Actions",
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Icons.copy,
                          label: "Copy Link",
                          color: Colors.blue,
                          onTap: () {
                            if (index == null) return;
                            final postUrl = post.media?[index.value].url;
                            if (postUrl == null) return;
                            Clipboard.setData(ClipboardData(text: postUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Link copied to clipboard"),
                              ),
                            );
                            Get.back();
                          },
                        ),
                        Obx(() {
                          final isBookmarked = post.isBookmarked!.value;
                          final icon =
                              isBookmarked
                                  ? FontAwesomeIcons.solidBookmark
                                  : FontAwesomeIcons.bookmark;
                          final color =
                              isBookmarked ? Colors.orange : Colors.grey;
                          final label =
                              isBookmarked ? "Unsave Post" : "Save Post";
                          return _buildQuickAction(
                            icon: icon,
                            label: label,
                            color: color,
                            onTap: () async {
                              final controller = Get.find<PostController>();
                              await controller.toggleSavePost(postId: post.id!);
                              Get.back();
                            },
                          );
                        }),
                        _buildQuickAction(
                          icon: Icons.download,
                          label: "Download",
                          color: Colors.green,
                          onTap: () async {
                            if (index == null) return;
                            CustomSnackbar.showSuccessToast(
                              "Downloading in progress.......",
                            );
                            await downloadCurrentMedia(context, post, index);
                            Get.back();
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.report_outlined,
                          label: "Report",
                          color: Colors.red,
                          onTap: () {
                            Get.back();
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return ReportBottomSheet(
                                  reportUser: post.author?.id ?? "",
                                  type: ReportType.post,
                                  referenceId: post.id,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // Share Options
                    // Text(
                    //   "Share to",
                    //   style: Get.textTheme.titleMedium?.copyWith(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //     color: Colors.black87,
                    //   ),
                    // ),
                    // SizedBox(height: 16),
                    // // Social Media Apps Row 1
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     _buildShareOption(
                    //       icon: Icons.messenger,
                    //       label: "Messenger",
                    //       color: Color(0xFF006AFF),
                    //       onTap: () => _shareToApp("Messenger"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.facebook,
                    //       label: "Facebook",
                    //       color: Color(0xFF1877F2),
                    //       onTap: () => _shareToApp("Facebook"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.camera_alt,
                    //       label: "Instagram",
                    //       color: Color(0xFFE4405F),
                    //       onTap: () => _shareToApp("Instagram"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.alternate_email,
                    //       label: "Twitter",
                    //       color: Color(0xFF1DA1F2),
                    //       onTap: () => _shareToApp("Twitter"),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 20),
                    // // Social Media Apps Row 2
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     _buildShareOption(
                    //       icon: Icons.message,
                    //       label: "WhatsApp",
                    //       color: Color(0xFF25D366),
                    //       onTap: () => _shareToApp("WhatsApp"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.telegram,
                    //       label: "Telegram",
                    //       color: Color(0xFF0088CC),
                    //       onTap: () => _shareToApp("Telegram"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.sms,
                    //       label: "SMS",
                    //       color: Color(0xFF34A853),
                    //       onTap: () => _shareToApp("SMS"),
                    //     ),
                    //     _buildShareOption(
                    //       icon: Icons.mail,
                    //       label: "Email",
                    //       color: Color(0xFF34A853),
                    //       onTap: () => _shareToApp("Email"),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildQuickAction({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget buildShareOption({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

void shareToApp(String appName) {
  Get.back();
  Get.snackbar("Sharing", "Opening $appName...");
  // Implement actual sharing logic here
}

void showReportDialog() {
  Get.dialog(
    AlertDialog(
      title: Text("Report Post"),
      content: Text("Why are you reporting this post?"),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
        TextButton(
          onPressed: () {
            Get.back();
            Get.snackbar("Reported", "Post has been reported");
          },
          child: Text("Report"),
        ),
      ],
    ),
  );
}

Future<void> downloadCurrentMedia(
  BuildContext context,
  PostModel post,
  RxInt? index,
) async {
  try {
    if (index == null) return;
    final i = index.value;
    final mediaList = post.media;
    if (mediaList == null || mediaList.isEmpty) return;
    if (i < 0 || i >= mediaList.length) return;
    final url = mediaList[i].url;
    if (url == null || url.isEmpty) return;

    final mediaType = getMediaType(url);

    // Derive filename with extension
    String fileName =
        Uri.parse(url).pathSegments.isNotEmpty
            ? Uri.parse(url).pathSegments.last
            : 'media_${post.id}_$i';
    if (!fileName.contains('.')) {
      // Append a reasonable extension if missing
      switch (mediaType) {
        case FileType.image:
          fileName = '$fileName.jpg';
          break;
        case FileType.video:
          fileName = '$fileName.mp4';
          break;
        case FileType.music:
          fileName = '$fileName.mp3';
          break;
        // default:
        //   fileName = '$fileName.bin';
      }
    }

    final dio = Dio();

    // Show light feedback while downloading (optional minimal)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading...')));

    if (mediaType == FileType.image) {
      // Download bytes and save to Photos/Gallery
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? <int>[]);
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (result != null && (result['isSuccess'] == true))
                ? 'Image saved to gallery'
                : 'Failed to save image',
          ),
        ),
      );
    } else if (mediaType == FileType.video) {
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, fileName);
      await dio.download(url, filePath);
      final result = await ImageGallerySaverPlus.saveFile(
        filePath,
        name: fileName,
      );
      final ok = result != null && (result['isSuccess'] == true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Video saved to gallery' : 'Failed to save video'),
        ),
      );
    } else if (mediaType == FileType.music) {
      // Download to temp file, then prompt user to pick destination
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, fileName);
      await dio.download(url, filePath);

      final params = SaveFileDialogParams(
        sourceFilePath: filePath,
        fileName: fileName,
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (savedPath != null && savedPath.isNotEmpty)
                ? 'Audio saved'
                : 'Failed to save audio',
          ),
        ),
      );
    } else {
      // Fallback: download and offer save dialog
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, fileName);
      await dio.download(url, filePath);
      final params = SaveFileDialogParams(
        sourceFilePath: filePath,
        fileName: fileName,
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (savedPath != null && savedPath.isNotEmpty)
                ? 'File saved'
                : 'Failed to save file',
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
  } finally {
    // Close sheet after action
    if (Get.isOverlaysOpen) {
      Get.back();
    }
  }
}
