import 'package:casarancha/app/data/models/chat_list_model.dart';
import 'package:casarancha/app/data/models/group_model.dart';
import 'package:casarancha/app/modules/auth/views/forgot_password_screen.dart';
import 'package:casarancha/app/modules/auth/views/login_screen.dart';
import 'package:casarancha/app/modules/auth/views/otp_screen.dart';
import 'package:casarancha/app/modules/auth/views/reset_password_screen.dart';
import 'package:casarancha/app/modules/chat/views/chat_list_screen.dart';
import 'package:casarancha/app/modules/chat/views/chat_screen.dart';
import 'package:casarancha/app/modules/group/views/create_group_screen.dart';
import 'package:casarancha/app/modules/group/views/group_feed_screen.dart';
import 'package:casarancha/app/modules/group/views/group_list_screen.dart';
import 'package:casarancha/app/modules/home/views/home_screen.dart';
import 'package:casarancha/app/modules/level/views/level_details_screen.dart';
import 'package:casarancha/app/modules/level/views/user_level_screen.dart';
import 'package:casarancha/app/modules/notification/views/notification_screen.dart';
import 'package:casarancha/app/modules/notification/views/notification_setting_screen.dart';
import 'package:casarancha/app/modules/post/views/create_post_screen.dart';
import 'package:casarancha/app/modules/post/views/create_poll_screen.dart';
import 'package:casarancha/app/modules/post/views/ghost_mode_screen.dart';
import 'package:casarancha/app/modules/profile/views/complete_profile_screen.dart';
import 'package:casarancha/app/modules/profile/views/edit_profile_screen.dart';
import 'package:casarancha/app/modules/profile/views/profile_screen.dart';
import 'package:casarancha/app/modules/profile/views/view_media_full_screen.dart';
import 'package:casarancha/app/modules/search/views/seach_screen.dart';
import 'package:casarancha/app/modules/settings/views/blocked_users_screen.dart';
import 'package:casarancha/app/modules/settings/views/language_setting_screen.dart';
import 'package:casarancha/app/modules/settings/views/organization_verification_screen.dart';
import 'package:casarancha/app/modules/settings/views/reported_users_screen.dart';
import 'package:casarancha/app/modules/settings/views/setting_screen.dart';
import 'package:casarancha/app/modules/settings/views/username_verification_screen.dart';
import 'package:casarancha/app/modules/story/views/create_story_screen.dart';
import 'package:casarancha/app/modules/support/views/support_screen.dart';
import 'package:casarancha/app/modules/verification/views/alt_verification_screen.dart';
import 'package:casarancha/app/modules/verification/views/group_verification_screen.dart';
import 'package:casarancha/app/modules/verification/views/name_verification_screen.dart';
import 'package:casarancha/app/modules/verification/views/school_verification_screen.dart';
import 'package:casarancha/app/modules/verification/views/verification_screen.dart';
import 'package:casarancha/app/modules/verification/views/work_verification_screen.dart';
import 'package:casarancha/app/widgets/bottom_navigation_screen.dart';
import 'package:casarancha/app/modules/splash/views/splash_screen.dart';
import 'package:casarancha/app/modules/onboarding/views/onboarding_screen.dart';
import 'package:casarancha/app/modules/auth/views/signup_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
    GetPage(name: AppRoutes.onboarding, page: () => OnboardingScreen()),
    GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(
      name: AppRoutes.otp,
      page: () {
        final args = Get.arguments ?? {};
        final email = args['email'] ?? "";
        final onTap = args['onTap'];
        if (email.isEmpty) {
          throw Exception("Email is required");
        }
        return OTPScreen(email: email, onTap: onTap);
      },
    ),
    GetPage(name: AppRoutes.resetPassword, page: () => ResetPasswordScreen()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: AppRoutes.home, page: () => HomeScreen()),
    GetPage(name: AppRoutes.searchScreen, page: () => SearchScreen()),
    GetPage(
      name: AppRoutes.createPost,
      page: () {
        final args = Get.arguments ?? {};
        final anonymous = args?['anonymous'] ?? false;
        final title = args?['title'];
        final originalPostId = args?['originalPostId'];
        final groupId = args?['groupId'];
        final groupName = args?['groupName'];

        return CreatePostScreen(
          anonymous: anonymous,
          title: title,
          originalPostId: originalPostId,
          groupId: groupId,
          groupName: groupName,
        );
      },
    ),
    GetPage(name: AppRoutes.levelDetails, page: () => LevelDetailsScreen()),
    GetPage(name: AppRoutes.userLevel, page: () => UserLevelScreen()),
    GetPage(name: AppRoutes.chatList, page: () => ChatListScreen()),
    GetPage(name: AppRoutes.chat, page: () {
      final args = Get.arguments ?? {};
      final chatHead = args['chatHead'] ?? ChatListModel();
      return ChatScreen(chatHead: chatHead);
    }),
    GetPage(name: AppRoutes.setting, page: () => SettingScreen()),
    GetPage(
      name: AppRoutes.notificationSetting,
      page: () => NotificationSettingScreen(),
    ),
    GetPage(
      name: AppRoutes.languageSetting,
      page: () => LanguageSettingScreen(),
    ),
    GetPage(name: AppRoutes.blockedUsers, page: () => BlockedUsersScreen()),
    GetPage(name: AppRoutes.reportedUsers, page: () => ReportedUsersScreen()),
    GetPage(name: AppRoutes.support, page: () => SupportScreen()),
    GetPage(name: AppRoutes.verification, page: () => VerificationScreen()),
    GetPage(
      name: AppRoutes.bottomNavigation,
      page: () => BottomNavigationScreen(),
    ),
    GetPage(
      name: AppRoutes.completeProfile,
      page: () => CompleteProfileScreen(),
    ),
    GetPage(name: AppRoutes.editProfile, page: () => EditProfileScreen()),
    GetPage(
      name: AppRoutes.profile,
      page: () {
        final args = Get.arguments ?? {};
        String? userId = args['userId'];
        return ProfileScreen(userId: userId);
      },
    ),
    GetPage(
      name: AppRoutes.viewMediaFullScreen,
      page: () {
        final args = Get.arguments ?? {};
        final mediaUrls = args['mediaUrls'] ?? [];
        final postModel = args['postModel'];
        bool isProfilePost = args['isProfilePost'] ?? false;
        if (postModel == null) {
          throw Exception("Post model is required");
        }
        return ViewMediaFullScreen(
          mediaUrls: mediaUrls,
          postModel: postModel,
          isProfilePost: isProfilePost,
        );
      },
    ),
    GetPage(
      name: AppRoutes.createPoll,
      page: () {
        final args = Get.arguments ?? {};
        final groupId = args['groupId'];
        final groupName = args['groupName'];
        return CreatePollScreen(groupId: groupId, groupName: groupName);
      },
    ),
    GetPage(name: AppRoutes.groupList, page: () => GroupListScreen()),
    GetPage(
      name: AppRoutes.groupFeed,
      page: () {
        final args = Get.arguments ?? {};
        final group = args['group'] ?? GroupModel();
        return GroupFeedScreen(group: group);
      },
    ),
    GetPage(name: AppRoutes.createGroup, page: () => CreateGroupScreen()),
    GetPage(name: AppRoutes.notification, page: () => NotificationScreen()),
    GetPage(name: AppRoutes.ghostMode, page: () => GhostModeScreen()),
    GetPage(
      name: AppRoutes.altVerification,
      page: () => AltVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.nameVerification,
      page: () => NameVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.usernameVerification,
      page: () => UsernameVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.organizationVerification,
      page: () => OrganizationVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.groupVerification,
      page: () => GroupVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.schoolVerification,
      page: () => SchoolVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.workVerification,
      page: () => WorkVerificationScreen(),
    ),
    GetPage(name: AppRoutes.createStory, page: () => CreateStoryScreen()),
  ];
}
