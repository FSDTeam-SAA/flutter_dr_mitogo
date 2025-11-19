import 'package:casarancha/app/controller/group_controller.dart';
import 'package:casarancha/app/data/models/group_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/utils/loaders.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupListScreen extends StatelessWidget {
  GroupListScreen({super.key});

  final RxInt selectedTab = 0.obs;
  final _tabs = ['All Groups', 'My Groups'];
  final List<Widget> _pages = [BuildAllGroup(), BuildMyGroups()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: Column(
          children: [
            SizedBox(height: Get.size.height * 0.02),
            CustomTextField(
              hintText: "Search",
              prefixIcon: FontAwesomeIcons.magnifyingGlass,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(width: 1, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            _buildNewAppBar(),
            SizedBox(height: 10),
            Obx(() => _pages[selectedTab.value]),
          ],
        ),
      ),
    );
  }

  InkWell buildCreateButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(width: 1, color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.plus,
              size: 20,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Text(
              "Create your own group",
              style: Get.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAppBar() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        return Obx(() {
          final isSelected = selectedTab.value == index;
          return Padding(
            padding: EdgeInsets.only(right: index != _tabs.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () {
                selectedTab.value = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color.fromARGB(255, 255, 223, 223)
                          : const Color.fromARGB(255, 236, 237, 238),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color:
                        isSelected ? AppColors.primaryColor : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Groups",
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
      leadingWidth: 45,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.createGroup);
            },
            child: CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              child: const Icon(
                FontAwesomeIcons.plus,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildMyGroups extends StatefulWidget {
  const BuildMyGroups({super.key});

  @override
  State<BuildMyGroups> createState() => _BuildMyGroupsState();
}

class _BuildMyGroupsState extends State<BuildMyGroups> {
  final groupController = Get.find<GroupController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupController.userGroups.isEmpty) {
        groupController.getUserGroups();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    groupController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (groupController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (groupController.userGroups.isEmpty) {
          return const Center(child: Text("No groups found"));
        }
        return ListView.builder(
          itemCount: groupController.userGroups.length,
          itemBuilder: (context, index) {
            final group = groupController.userGroups[index];
            return InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.groupFeed, arguments: {'group': group});
              },
              child: buildListTile(group),
            );
          },
        );
      }),
    );
  }

  Widget buildListTile(GroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(group.avatarUrl ?? ""),
          ),
          const SizedBox(width: 10),
          Text(
            group.name ?? "",
            style: Get.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}

class BuildAllGroup extends StatefulWidget {
  const BuildAllGroup({super.key});

  @override
  State<BuildAllGroup> createState() => _BuildAllGroupState();
}

class _BuildAllGroupState extends State<BuildAllGroup> {
  final groupController = Get.find<GroupController>();
  final selectedIndex = RxInt(-1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (groupController.groupList.isEmpty) {
        groupController.getAllPublicGroups();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (groupController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (groupController.groupList.isEmpty) {
          return const Center(child: Text("No groups found"));
        }
        return ListView.builder(
          itemCount: groupController.groupList.length,
          itemBuilder: (context, index) {
            final group = groupController.groupList[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryColor.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  width: 0.5,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Topic", style: Get.textTheme.bodySmall),
                        Text(
                          group.name ?? "",
                          style: Get.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          group.description ?? "",
                          style: Get.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 5),
                        buildJoinButton(index, group),
                      ],
                    ),
                  ),
                  Expanded(child: _buildStack(group: group)),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  InkWell buildJoinButton(int index, GroupModel group) {
    return InkWell(
      onTap: () async {
        selectedIndex.value = index;
        await groupController.joinGroup(groupId: group.id!);
        selectedIndex.value = -1;
      },
      child: Container(
        width: Get.width * 0.25,
        height: 33,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.primaryColor,
        ),
        child: Obx(() {
          return selectedIndex.value == index
              ? Loader1(color: Colors.white, size: 15)
              : Text(
                "Join",
                style: Get.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
        }),
      ),
    );
  }

  Widget _buildStack({required GroupModel group}) {
    return SizedBox(
      height: Get.height * 0.12,
      child: Stack(
        children: [
          // Positioned(
          //   bottom: 15,
          //   left: 0,
          //   child: CircleAvatar(
          //     radius: 20,
          //     backgroundColor: Colors.grey,
          //     backgroundImage: AssetImage("assets/images/pp.png"),
          //   ),
          // ),
          // Positioned(
          //   top: 3,
          //   left: 15,
          //   child: CircleAvatar(
          //     radius: 18,
          //     backgroundColor: Colors.yellow,
          //     backgroundImage: AssetImage("assets/images/story.png"),
          //   ),
          // ),
          Positioned(
            top: 5,
            right: 3,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: Colors.grey.shade50,
              backgroundImage: NetworkImage(group.avatarUrl ?? ""),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade50,
              backgroundImage: NetworkImage(group.ownerUrl ?? ""),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 1,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Text(
                group.postCount.toString(),
                style: Get.textTheme.bodyMedium!.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
