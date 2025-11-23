// BottomNavigationScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../controller/post_controller.dart';
import '../controller/story_controller.dart';
import '../controller/user_controller.dart';
import '../modules/chat/views/chat_list_screen.dart';
import '../modules/group/views/group_list_screen.dart';
import '../modules/home/controller/home_scroll_controller.dart';
import '../modules/home/views/home_screen.dart';
import '../modules/post/views/create_post_screen.dart';
import '../modules/settings/views/setting_screen.dart';
import '../resources/app_colors.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final RxInt currentIndex = 0.obs;
  DateTime? _lastHomeTapTime;

  // Shared controllers
  final homeScrollCtrl = Get.find<HomeScrollController>();
  final userController = Get.find<UserController>();

  final List<Widget> _pages = [
    const HomeScreen(),
    CreatePostScreen(),
    const ChatListScreen(),
    GroupListScreen(),
    const SettingScreen(),
  ];

  void _refreshHomeFeed() {
    DPrint.log("Refresing ..");
    HapticFeedback.mediumImpact();

    // Jump to top instantly before refresh
    // homeScrollCtrl.jumpToTop();

    homeScrollCtrl.triggerRefresh();

    // Get.snackbar(
    //   "Refreshed",
    //   "You're all caught up!",
    //   snackPosition: SnackPosition.TOP,
    //   backgroundColor: Colors.black87,
    //   colorText: Colors.white,
    //   margin: const EdgeInsets.only(top: 90, left: 20, right: 20),
    //   borderRadius: 12,
    //   duration: const Duration(seconds: 1),
    //   icon: const Icon(Icons.check_circle, color: Colors.white),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            border:
                userController.userModel.value?.ghostMode?.value == true
                    ? const Border(
                      left: BorderSide(width: 2, color: Colors.red),
                      right: BorderSide(width: 2, color: Colors.red),
                    )
                    : null,
          ),
          child: IndexedStack(index: currentIndex.value, children: _pages),
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10,
              ),
              child: GNav(
                rippleColor: AppColors.primaryColor.withOpacity(0.1),
                hoverColor: AppColors.primaryColor.withOpacity(0.1),
                gap: 5,
                activeColor: Colors.white,
                iconSize: 18,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                tabBackgroundColor: AppColors.primaryColor,
                color: Colors.grey[600],
                tabs: const [
                  GButton(icon: FontAwesomeIcons.house, text: 'Home'),
                  GButton(icon: FontAwesomeIcons.plus, text: 'Create'),
                  GButton(icon: FontAwesomeIcons.solidMessage, text: 'Chat'),
                  GButton(icon: FontAwesomeIcons.userGroup, text: 'Groups'),
                  GButton(icon: FontAwesomeIcons.gear, text: 'Settings'),
                ],
                selectedIndex: currentIndex.value,
                onTabChange: (index) {
                  final now = DateTime.now();

                  if (index == 0) {
                    if (currentIndex.value == 0) {
                      // Double tap → Refresh
                      DPrint.info("Double tap → Refresh");
                      if (_lastHomeTapTime != null &&
                          now.difference(_lastHomeTapTime!).inMilliseconds <
                              500) {
                        _refreshHomeFeed();
                        _lastHomeTapTime = null;
                        return;
                      }
                      // Single tap → Scroll to top
                      homeScrollCtrl.scrollToTop();
                      _lastHomeTapTime = now;
                    } else {
                      // Coming from another tab
                      currentIndex.value = 0;
                      Future.delayed(const Duration(milliseconds: 150), () {
                        homeScrollCtrl.scrollToTop();
                      });
                    }
                    return;
                  }

                  _lastHomeTapTime = null;
                  currentIndex.value = index;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
