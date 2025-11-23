import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/data/models/user_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/staggered_column_animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userController.blockedUsers.isEmpty) {
        _userController.getBlockedUsers();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userController.clean();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await _userController.getBlockedUsers(showLoader: false);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: StaggeredColumnAnimation(
              children: [
                SizedBox(height: Get.height * 0.02),
                Obx(() {
                  if (_userController.blockedUsers.isEmpty) {
                    return SizedBox(
                      height: Get.height * 0.6,
                      width: Get.width,
                      child: Center(child: Text("no_blocked_users".tr)),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _userController.blockedUsers.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final blockedUser = _userController.blockedUsers[index];
                      return _buildBlockedTile(blockedUser: blockedUser);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockedTile({required UserModel blockedUser}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 0),
            color: const Color.fromARGB(19, 0, 0, 0),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(blockedUser.avatarUrl ?? ""),
        ),
        title: Text(
          blockedUser.displayName ?? "",
          style: Get.textTheme.bodyMedium!.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: IconButton(
          onPressed: () async {
            await _userController.toggleBlock(blockId: blockedUser.id ?? "");
          },
          icon: Icon(FontAwesomeIcons.lockOpen, size: 18),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "blocked".tr,
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
    );
  }
}
