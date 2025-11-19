import 'package:casarancha/app/controller/story_controller.dart';
import 'package:casarancha/app/modules/story/controllers/story_screen_controller.dart';
import 'package:casarancha/app/modules/story/widgets/create_story_widget.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateStoryScreen extends StatelessWidget {
  CreateStoryScreen({super.key});

  final _storyScreenController = Get.put(StoryScreenController());
  final _storyController = Get.find<StoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Add Image/Video',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: Get.height * 0.1,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        displayMediaOptionWidget(
                          context,
                          _storyScreenController,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: Get.height * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _storyScreenController.selectedMedia.length,
                          itemBuilder: (context, index) {
                            return MediaDisplayCard(
                              index: index,
                              storyScreenController: _storyScreenController,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description section
              const Text(
                'Add description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _storyScreenController.descriptionController,
                hintText: "Write here...",
                minLines: 3,
                maxLines: 4,
              ),
              SizedBox(height: Get.height * 0.2),

              // Post button
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        _storyScreenController.selectedMedia.isNotEmpty
                            ? () async {
                              final content =
                                  _storyScreenController.descriptionController;

                              await _storyController.createStory(
                                mediaFiles:
                                    _storyScreenController.selectedMedia,
                                content: content.text,
                                context: context,
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      fixedSize: Size(Get.width, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.4),
                    ),
                    child:
                        _storyController.isloading.value
                            ? const Loader1(color: Colors.white)
                            : const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Create a story',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      leading: InkWell(
        onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back_ios),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
