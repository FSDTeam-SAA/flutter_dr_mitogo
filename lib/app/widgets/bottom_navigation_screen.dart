import 'package:casarancha/app/controller/user_controller.dart';
import 'package:casarancha/app/modules/chat/views/chat_list_screen.dart';
import 'package:casarancha/app/modules/group/views/group_list_screen.dart';
import 'package:casarancha/app/modules/home/views/home_screen.dart';
import 'package:casarancha/app/modules/post/views/create_post_screen.dart';
import 'package:casarancha/app/modules/settings/views/setting_screen.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavigationScreen extends StatelessWidget {
  BottomNavigationScreen({super.key});

  final RxInt _currentIndex = 0.obs;

  final List<Widget> _pages = [
    HomeScreen(),
    // SearchScreen(),
    CreatePostScreen(),
    ChatListScreen(),
    GroupListScreen(),
    SettingScreen(),
  ];

  final _userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            border:
                _userController.userModel.value!.ghostMode!.value
                    ? Border(
                      left: BorderSide(width: 2, color: Colors.red),
                      right: BorderSide(width: 2, color: Colors.red),
                    )
                    : null,
          ),
          child: _pages[_currentIndex.value],
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
                  horizontal: 15,
                  vertical: 13,
                ),

                tabBackgroundColor: AppColors.primaryColor,
                color: Colors.grey[600],
                tabs: const [
                  GButton(
                    icon: FontAwesomeIcons.house,
                    text: 'Home',
                    textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  // GButton(
                  //   icon: FontAwesomeIcons.magnifyingGlass,
                  //   text: 'Search',
                  //   textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  // ),
                  GButton(
                    icon: FontAwesomeIcons.plus,
                    text: 'Create',
                    textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  GButton(
                    icon: FontAwesomeIcons.solidMessage,
                    text: 'Chat',
                    textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  GButton(
                    icon: FontAwesomeIcons.userGroup,
                    text: 'Group',
                    textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  GButton(
                    icon: FontAwesomeIcons.gear,
                    text: 'Settings',
                    textStyle: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
                selectedIndex: _currentIndex.value,
                onTabChange: (index) {
                  _currentIndex.value = index;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
