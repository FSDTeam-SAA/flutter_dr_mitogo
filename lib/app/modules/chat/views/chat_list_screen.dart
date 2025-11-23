import 'package:casarancha/app/controller/message_controller.dart';
import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/routes/app_routes.dart';
import 'package:casarancha/app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final messageController = Get.find<MessageController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!messageController.isChattedListFetched.value) {
        messageController.getChatList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.01),
              CustomTextField(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
                hintText: "search".tr,
                prefixIcon: Icons.search,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 255, 217, 217),
                    ),
                    child: Text(
                      "personal".tr,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 240, 240, 240),
                    ),
                    child: Text(
                      "ghost".tr,
                      style: Get.textTheme.bodyMedium!.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Obx(() {
                if (messageController.isChatListLoading.value) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) => _buildChatItemSkeleton(),
                  );
                }
                if (messageController.allChattedUserList.isEmpty) {
                  return _buildEmptyList();
                }
                return ListView.builder(
                  itemCount: messageController.allChattedUserList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final user = messageController.allChattedUserList[index];
                    return _buildUserCard(user: user);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildEmptyList() {
    final isDark = Get.isDarkMode;
    return Container(
      height: Get.height * 0.5,
      width: Get.width,
      decoration: BoxDecoration(
        color: isDark ? const Color.fromARGB(255, 26, 25, 25) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: isDark ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'no_conversations_yet'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard({required ChatListModel user}) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.chat, arguments: {'chatHead': user});
      },
      child: Container(
        width: Get.width,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
          contentPadding: EdgeInsets.only(
            left: 5,
            top: 6,
            bottom: 6,
            right: 10,
          ),
          horizontalTitleGap: 10,
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.avatar ?? ""),
          ),
          title: Row(
            children: [
              Text(user.displayName ?? "", style: Get.textTheme.bodyMedium),
              // const SizedBox(width: 5),
              // index == 1
              //     ? Icon(Icons.verified, size: 16, color: Colors.blue)
              //     : SizedBox(),
            ],
          ),
          subtitle: Text(
            user.lastMessage ?? "",
            style: Get.textTheme.bodySmall,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTapDown: (details) {
                  _buildCardMenuOption(details);
                },
                child: const Icon(Icons.more_horiz, size: 17),
              ),
              const SizedBox(height: 5),
              // const Text("11:00 PM", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _buildCardMenuOption(TapDownDetails details) {
    return showMenu(
      context: Get.context!,
      color: const Color.fromARGB(255, 248, 248, 248),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: const Color.fromARGB(75, 0, 0, 0),
      elevation: 5,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 1,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.block, color: Colors.red),
              const SizedBox(width: 5),
              Text(
                "block".tr,
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.report, color: Colors.red),
              const SizedBox(width: 5),
              Text(
                "report".tr,
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 5),
              Text(
                "delete".tr,
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFFFE7E6),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "chat_history".tr,
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

  Widget _buildChatItemSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Base and highlight colors for shimmer effect
    final Color baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    // Container colors for skeleton elements
    final Color primarySkeletonColor =
        isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color secondarySkeletonColor =
        isDark ? Colors.grey[600]! : Colors.grey[200]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primarySkeletonColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          title: Container(
            width: 100,
            height: 16,
            color: primarySkeletonColor,
            margin: const EdgeInsets.only(bottom: 8),
          ),
          subtitle: Container(
            width: 150,
            height: 14,
            color: secondarySkeletonColor,
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: primarySkeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
