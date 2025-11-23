import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/modules/chat/controller/chat_controller.dart';
import 'package:casarancha/app/modules/chat/widgets/media/media_picker_bottom_sheet.dart';
import 'package:casarancha/app/modules/chat/widgets/shared/reply_to_content_widget.dart';
import 'package:casarancha/app/modules/chat/widgets/textfield/audio_input_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewChatInputFields extends StatelessWidget {
  final ChatController controller;
  final ChatListModel chatHead;

  const NewChatInputFields({
    super.key,
    required this.controller,
    required this.chatHead,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRecording = controller.audioController.isRecording.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            isRecording
                ? AudioInputPreview(controller: controller)
                : _buildInputFieldRow(context),
      );
    });
  }

  Widget _buildInputFieldRow(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.845,
                  minHeight: 45,
                ),
                margin: const EdgeInsets.all(2.5),
                // decoration: chatInputFieldDecoration(),
                child: Column(
                  children: [
                    ReplyToContent(
                      controller: controller,
                      chatHead: chatHead,
                      isSender: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // IconButton(
                        //   onPressed: () {
                        //     FocusManager.instance.primaryFocus?.unfocus();
                        //     Future.delayed(const Duration(milliseconds: 200), () {
                        //       controller.showEmojiPicker.toggle();
                        //     });
                        //   },
                        //   icon: const FaIcon(
                        //     FontAwesomeIcons.solidFaceSmile,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 10,
                              bottom: 10,
                              right: 5,
                            ),
                            child: CustomTextField(
                              minLines: 1,
                              maxLines: 3,
                              onTap: () {
                                controller.showEmojiPicker.value = false;
                                FocusManager.instance.primaryFocus
                                    ?.requestFocus();
                              },
                              controller: controller.textMessageController,
                              onChanged: controller.handleTyping,
                              textStyle: Get.textTheme.labelMedium?.copyWith(
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Write your reply here..",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              bgColor: Color.fromARGB(255, 240, 240, 243),
                              suffixIcon: Icons.attach_file,
                              suffixIconcolor: Colors.grey,
                              onSuffixTap: () {
                                _showMediaPickerBottomSheet(context);
                              },
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: TextField(
                        //     minLines: 1,
                        //     maxLines: 3,
                        //     onTap: () {
                        //       controller.showEmojiPicker.value = false;
                        //       FocusManager.instance.primaryFocus?.requestFocus();
                        //     },
                        //     cursorColor: AppColors.primaryColor,
                        //     controller: controller.textMessageController,
                        //     onChanged: controller.handleTyping,
                        //     style: Get.textTheme.labelMedium,
                        //     decoration: InputDecoration(
                        //       hintText: "Type a message...",
                        //       hintStyle: Get.textTheme.labelMedium,
                        //       border: InputBorder.none,
                        //       contentPadding: const EdgeInsets.symmetric(
                        //         vertical: 12,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.attach_file_rounded,
                        //     color: Colors.grey,
                        //   ),
                        //   onPressed: () => _showMediaPickerBottomSheet(context),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Obx(() {
                final hasTextOrMedia =
                    controller.wordsTyped.value.isNotEmpty ||
                    controller.mediaController.selectedFile.value != null ||
                    controller.audioController.selectedFile.value != null ||
                    controller.mediaController.multipleMediaSelected.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryColor,
                    child: IconButton(
                      icon: Icon(
                        hasTextOrMedia ? Icons.send : Icons.mic,
                        color: Colors.white,
                        size: hasTextOrMedia ? 18 : null,
                      ),
                      onPressed:
                          hasTextOrMedia
                              ? controller.sendMessage
                              : controller.audioController.startRecording,
                    ),
                  ),
                );
              }),
            ],
          ),
          // Emoji picker
          // _buildEmojiPicker(),
        ],
      ),
    );
  }

  // Obx buildEmojiPicker() {
  //   return Obx(() => controller.showEmojiPicker.value
  //       ? SizedBox(
  //           height: Get.height * 0.35,
  //           child: EmojiPicker(
  //             onEmojiSelected: (category, emoji) {
  //               final text = controller.textMessageController.text;
  //               final selection = controller.textMessageController.selection;
  //               final newText = text.replaceRange(
  //                 selection.start,
  //                 selection.end,
  //                 emoji.emoji,
  //               );
  //               controller.textMessageController.value = TextEditingValue(
  //                 text: newText,
  //                 selection: TextSelection.collapsed(
  //                   offset: selection.start + emoji.emoji.length,
  //                 ),
  //               );
  //             },
  //             config: Config(
  //               bottomActionBarConfig: BottomActionBarConfig(
  //                 backgroundColor: Get.theme.colorScheme.surface,
  //                 buttonColor: Get.theme.scaffoldBackgroundColor,
  //               ),
  //             ),
  //           ),
  //         )
  //       : const SizedBox());
  // }

  void _showMediaPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MediaPickerBottomSheet(controller: controller),
    );
  }
}
