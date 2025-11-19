import 'dart:io';
import 'package:casarancha/app/controller/group_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/utils/image_picker.dart';
import 'package:casarancha/app/widgets/custom_button.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final formKey = GlobalKey<FormState>();
  final RxInt index = 0.obs;
  final groupController = Get.find<GroupController>();
  final pickedFile = Rxn<File>(null);
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final membersId = <UserModel>[].obs;

  void selectImage() async {
    File? pM = await pickImage(imageSource: ImageSource.gallery);
    if (pM == null) return;
    pickedFile.value = pM;
  }

  @override
  void initState() {
    super.initState();
    groupController.getMembersToAdd();
  }

  @override
  void dispose() {
    groupController.membersToAdd.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: Get.width,
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.02),
              _buildAvater(),
              SizedBox(height: Get.height * 0.02),
              const SizedBox(height: 15),
              buildFormFields(),
              const SizedBox(height: 15),
              Text(
                "Add Members",
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      _buildCompactAddPeopleDialog(context);
                    },
                    child: Container(
                      width: 55,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  buildAllAddedMembers(),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                "Select One",
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              _buildGroupTypeSelection(),
              const SizedBox(height: 30),
              CustomButton(
                ontap: () async {
                  if (!formKey.currentState!.validate()) return;
                  if (pickedFile.value == null) {
                    CustomSnackbar.showErrorToast("Please select an image");
                    return;
                  }
                  List<String> ids =
                      membersId.map((e) => e.id.toString()).toList();
                  await groupController.createGroup(
                    name: nameController.text,
                    description: descriptionController.text,
                    visibilityType: index.value == 0 ? "public" : "private",
                    file: pickedFile.value!,
                    membersId: ids,
                  );
                },
                isLoading: groupController.isLoading,
                child: Text(
                  "Create",
                  style: Get.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
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

  Obx buildAllAddedMembers() {
    return Obx(() {
      if (membersId.isEmpty) {
        return const SizedBox();
      }
      return Expanded(
        child: SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: membersId.length,
            itemBuilder: (context, index) {
              final user = membersId[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/placeholder.png",
                          image: user.avatarUrl ?? "",
                          width: 55,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: InkWell(
                        onTap: () {
                          membersId.remove(user);
                        },
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primaryColor,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Form buildFormFields() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Topic",
            style: Get.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            controller: nameController,
            hintText: "Enter topic name",
            bgColor: const Color(0xFFF7F7F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Description",
            style: Get.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          CustomTextField(
            controller: descriptionController,
            hintText: "Enter description",
            minLines: 4,
            maxLines: 5,
            bgColor: const Color(0xFFF7F7F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ],
      ),
    );
  }

  Row _buildGroupTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => InkWell(
              onTap: () {
                index.value = index.value == 0 ? 1 : 0;
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color:
                      index.value == 0
                          ? const Color.fromARGB(255, 253, 242, 242)
                          : Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 0.75,
                    color:
                        index.value == 0
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      activeColor: AppColors.primaryColor,
                      value: index.value == 0,
                      onChanged: (value) {
                        index.value = value! ? 0 : 1;
                      },
                    ),

                    // const SizedBox(width: 5),
                    Text(
                      "Public",
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => InkWell(
              onTap: () {
                index.value = index.value == 1 ? 0 : 1;
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color:
                      index.value == 1
                          ? const Color.fromARGB(255, 253, 242, 242)
                          : Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 0.75,
                    color:
                        index.value == 1
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      activeColor: AppColors.primaryColor,
                      value: index.value == 1,
                      onChanged: (value) {
                        index.value = value! ? 1 : 0;
                      },
                    ),

                    // const SizedBox(width: 5),
                    Text(
                      "Private",
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<dynamic> _buildCompactAddPeopleDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          child: SizedBox(
            height: Get.height * 0.55,
            child: Column(
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Add Members",
                          style: Get.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search and List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Search Field
                        CustomTextField(
                          hintText: "Search members...",
                          bgColor: const Color(0xFFF7F7F9),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icons.search,
                        ),

                        const SizedBox(height: 15),

                        // Scrollable List
                        buildAllMembers(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildAllMembers() {
    return Expanded(
      child: Obx(() {
        if (groupController.membersToAdd.isEmpty) {
          return const Center(child: Text("No members found"));
        }
        return ListView.builder(
          itemCount: groupController.membersToAdd.length,
          itemBuilder: (context, index) {
            final user = groupController.membersToAdd[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(user.avatarUrl ?? ""),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user.displayName ?? "",
                      style: Get.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Obx(() {
                    final isAdded = membersId.contains(user);
                    return SizedBox(
                      width: 60,
                      height: 28,
                      child: CustomButton(
                        ontap: () {
                          if (membersId.contains(user)) {
                            membersId.remove(user);
                          } else {
                            membersId.add(user);
                          }
                        },
                        bgColor:
                            isAdded
                                ? Color(0xFFF9EDED)
                                : AppColors.primaryColor,
                        border:
                            isAdded
                                ? Border.all(
                                  width: 1,
                                  color: AppColors.primaryColor,
                                )
                                : null,
                        isLoading: false.obs,
                        child: Text(
                          isAdded ? "Added" : "Add",
                          style: GoogleFonts.poppins(
                            color:
                                isAdded ? AppColors.primaryColor : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Create Group",
        style: Get.textTheme.bodyLarge!.copyWith(color: AppColors.primaryColor),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
          onTap: () => Get.back(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ),
      leadingWidth: 40,
    );
  }

  Widget _buildAvater() {
    return Center(
      child: Stack(
        children: [
          Obx(
            () => Container(
              height: Get.height * 0.14,
              width: Get.height * 0.14,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image:
                      pickedFile.value == null
                          ? AssetImage("assets/images/placeholder.png")
                          : FileImage(pickedFile.value!),
                  fit: BoxFit.cover,
                ),
                border: Border.all(width: 3, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: selectImage,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
