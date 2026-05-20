import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import 'package:flutter_task/features/banner/presentation/screens/admin/banner_screen.dart';
import 'package:flutter_task/features/home/presentation/home_screen.dart';
import 'package:flutter_task/features/poll/presentation/screens/admin/poll_result_screen.dart';
import 'package:flutter_task/features/poll/presentation/screens/comon/create_poll_screen.dart';
import 'package:flutter_task/features/poll/presentation/screens/comon/poll_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/admin/admin_profile_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/forget/forget_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/login/log_in_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/otp/otp_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/reset_pass/reset_password_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/sign_up/sign_up_screen.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/bottom_nav_user.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/poll/presentation/screens/user/poll_details_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/comon/announcements_details_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/comon/announcements_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/comon/create_announcements_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/admin/all_admin_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/admin/all_user_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/admin/profile_details_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/add_bio_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/add_contact_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/add_cv_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/add_education_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/add_job_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/edit_profile_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/job_specification_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/member_select_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/mother_select_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/personal_info_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/profile_information_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/user/support_screen.dart';
import 'package:flutter_task/features/request/presentation/screens/comon/reason_screen.dart';
import 'package:flutter_task/features/request/presentation/screens/comon/request_details_screen.dart';
import 'package:flutter_task/features/request/presentation/screens/comon/requested_screen.dart';
import 'package:flutter_task/features/request/presentation/screens/user/request_screen.dart';
import 'package:flutter_task/features/translation/presentation/language_screen.dart';
import 'package:flutter_task/features/profile/setting/change%20password/setting_change_password.dart';
import 'package:flutter_task/features/privacy/presentation/screens/privacy_policy_all_screen.dart';
import 'package:flutter_task/features/profile/setting/setting_screen.dart';
import 'package:flutter_task/features/splash/splash_screen.dart';
import 'package:flutter_task/features/tree/presentation/screens/admin_tree_screen.dart';
import 'package:flutter_task/features/tree/presentation/screens/tree_details_screen.dart';
import 'package:get/get.dart';

abstract class AppPages {
  AppPages._();

  static final List<GetPage> routes = [
    // ─── Splash ──────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.splashScreen, page: () => SplashScreen()),

    // ─── Auth ─────────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.loginScreen, page: () => LoginScreen()),
    GetPage(name: AppRoutes.signUpScreen, page: () => SignUpScreen()),
    GetPage(name: AppRoutes.forgotScreen, page: () => ForgetScreen()),
    GetPage(name: AppRoutes.otpScreen, page: () => OtpScreen()),
    GetPage(
      name: AppRoutes.resetPasswordScreen,
      page: () => ResetPasswordScreen(),
    ),

    // ─── Bottom Nav ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.bottomNavUserBar,
      page: () => BottomNavUserBar(),
      binding: BottomNavBinding(),
    ),

    // ─── Profile ──────────────────────────────────────────────────────────────
    GetPage(name: AppRoutes.languageScreen, page: () => LanguageScreen()),
    GetPage(name: AppRoutes.settingScreen, page: () => SettingScreen()),
    GetPage(
      name: AppRoutes.settingChangePassword,
      page: () => SettingChangePassword(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicyAllScreen,
      page: () => PrivacyPolicyAllScreen(),
    ),
    GetPage(name: AppRoutes.supportScreen, page: () => SupportScreen()),
    GetPage(
      name: AppRoutes.announcementsScreen,
      page: () => AnnouncementsScreen(),
    ),
    GetPage(
      name: AppRoutes.createAnnouncementsScreen,
      page: () => CreateAnnouncementsScreen(),
    ),
    GetPage(
      name: AppRoutes.announcementsDetailsScreen,
      page: () => AnnouncementsDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.memberSelectScreen,
      page: () => MemberSelectScreen(),
    ),
    GetPage(name: AppRoutes.editProfileScreen, page: () => EditProfileScreen()),
    GetPage(
      name: AppRoutes.profileDetailsScreen,
      page: () => ProfileDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.profileInformationScreen,
      page: () => ProfileInformationScreen(),
    ),
    GetPage(
      name: AppRoutes.personalInfoScreen,
      page: () => PersonalInfoScreen(),
    ),
    GetPage(name: AppRoutes.addBioScreen, page: () => AddBioScreen()),
    GetPage(name: AppRoutes.addContactScreen, page: () => AddContactScreen()),
    GetPage(
      name: AppRoutes.addEducationScreen,
      page: () => AddEducationScreen(),
    ),
    GetPage(name: AppRoutes.addJobScreen, page: () => AddJobScreen()),
    GetPage(name: AppRoutes.addCvScreen, page: () => AddCvScreen()),

    GetPage(name: AppRoutes.requestedScreen, page: () => RequestedScreen()),
    GetPage(
      name: AppRoutes.motherSelectScreen,
      page: () => MotherSelectScreen(),
    ),
    GetPage(name: AppRoutes.homeScreen, page: () => HomeScreen()),
    GetPage(
      name: AppRoutes.jobSpecificationScreen,
      page: () => JobSpecificationScreen(),
    ),

    GetPage(
      name: AppRoutes.adminDashboardScreen,
      page: () => AdminDashboardScreen(),
    ),

    GetPage(
      name: AppRoutes.adminProfileScreen,
      page: () => AdminProfileScreen(),
    ),

    GetPage(name: AppRoutes.pollDetailsScreen, page: () => PollDetailsScreen()),
    GetPage(name: AppRoutes.reasonScreen, page: () => ReasonScreen()),
    GetPage(name: AppRoutes.bannerScreen, page: () => BannerScreen()),
    GetPage(name: AppRoutes.pollScreen, page: () => PollScreen()),
    //GetPage(name: AppRoutes.adminRequestScreen, page: () => AdminRequestScreen()),
    GetPage(name: AppRoutes.pollResultScreen, page: () => PollResultScreen()),
    GetPage(name: AppRoutes.createPollScreen, page: () => CreatePollScreen()),
    GetPage(name: AppRoutes.adminTreeScreen, page: () => AdminTreeScreen()),
    GetPage(name: AppRoutes.requestScreen, page: () => RequestScreen()),
    GetPage(
      name: AppRoutes.requestDetailsScreen,
      page: () => RequestDetailsScreen(),
    ),
    GetPage(name: AppRoutes.treeDetailsScreen, page: () => TreeDetailsScreen()),
    GetPage(name: AppRoutes.allUserScreen, page: () => AllUserScreen()),
    GetPage(name: AppRoutes.allAdminScreen, page: () => AllAdminScreen()),
  ];
}

/// Bottom Nav feature — UserBar
class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
  }
}
