
import 'package:casarancha/app/controller/story_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteStoryDialog extends StatelessWidget {
  final Function() onDelete;
  final Function() onCancel;

  DeleteStoryDialog({
    super.key,
    required this.onDelete,
    required this.onCancel,
  });

  final _storyController = Get.find<StoryController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              color: Colors.orange.shade700,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Delete Story?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Are you sure you want to delete this story? This action cannot be undone.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Obx(
                    () => _storyController.isloading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Delete",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class GoLiveWidget extends StatelessWidget {
//   GoLiveWidget({super.key});

//   final _liveController = Get.find<LiveStreamController>();

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       child: _buildDialogContent(context),
//     );
//   }

//   Widget _buildDialogContent(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.rectangle,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 10.0,
//             offset: Offset(0.0, 10.0),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration: BoxDecoration(
//               color: Colors.orange.shade50,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.live_tv,
//               color: Colors.orange.shade700,
//               size: 40,
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             "Go Live",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             "Do you want your live for public or matched people?",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () async {
//                     await _liveController.startLiveStream(
//                       visibility: "matches",
//                     );
//                   },
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(color: Colors.grey.shade300),
//                     ),
//                   ),
//                   child: const Text(
//                     "Matched",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     await _liveController.startLiveStream(visibility: "public");
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade700,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Obx(
//                     () => _liveController.isLoading.value
//                         ? const CircularProgressIndicator(
//                             color: Colors.white,
//                           )
//                         : const Text(
//                             "Public",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
