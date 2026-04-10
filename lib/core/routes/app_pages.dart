import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import 'package:flutter_task/features/admin/profile/presentation/admin_profile_screen.dart';
import 'package:flutter_task/features/auth/forget/forget_screen.dart';
import 'package:flutter_task/features/auth/login/log_in_screen.dart';
import 'package:flutter_task/features/auth/otp/otp_screen.dart';
import 'package:flutter_task/features/auth/reset_pass/reset_password_screen.dart';
import 'package:flutter_task/features/auth/sign_up/sign_up_screen.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/bottom_nav_user.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/profile/add_bio_screen.dart';
import 'package:flutter_task/features/profile/add_contact_screen.dart';
import 'package:flutter_task/features/profile/add_cv_screen.dart';
import 'package:flutter_task/features/profile/add_education_screen.dart';
import 'package:flutter_task/features/profile/add_job_screen.dart';
import 'package:flutter_task/features/profile/announcements_details_screen.dart';
import 'package:flutter_task/features/profile/announcements_screen.dart';
import 'package:flutter_task/features/profile/create_announcements_screen.dart';
import 'package:flutter_task/features/profile/edit_profile_screen.dart';
import 'package:flutter_task/features/request/request_screen.dart';
import 'package:flutter_task/features/translation/presentation/language_screen.dart';
import 'package:flutter_task/features/profile/member_select_screen.dart';
import 'package:flutter_task/features/profile/personal_info_screen.dart';
import 'package:flutter_task/features/profile/profile_information_screen.dart';
import 'package:flutter_task/features/profile/setting/change%20password/setting_change_password.dart';
import 'package:flutter_task/features/profile/setting/privacy_policy_all_screen.dart';
import 'package:flutter_task/features/profile/setting/setting_screen.dart';
import 'package:flutter_task/features/profile/support_screen.dart';
import 'package:flutter_task/features/splash/splash_screen.dart';
import 'package:get/get.dart';

abstract class AppPages {
  AppPages._();

  static final List<GetPage> routes = [

    // ─── Splash ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.splashScreen,
      page: () => SplashScreen(),
    ),

    // ─── Auth ─────────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signUpScreen,
      page: () => SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotScreen,
      page: () => ForgetScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otpScreen,
      page: () => OtpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPasswordScreen,
      page: () => ResetPasswordScreen(),
      binding: AuthBinding(),
    ),

    // ─── Bottom Nav ───────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.bottomNavUserBar,
      page: () => BottomNavUserBar(),
      binding: BottomNavBinding(),
       //middlewares: [AuthMiddleware()],
    ),

    // ─── Profile ──────────────────────────────────────────────────────────────
    GetPage(
      name: AppRoutes.languageScreen,
      page: () => LanguageScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: AppRoutes.settingScreen,
      page: () => SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: AppRoutes.settingChangePassword,
      page: () => SettingChangePassword(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicyAllScreen,
      page: () => PrivacyPolicyAllScreen(),
    ),
    GetPage(
      name: AppRoutes.supportScreen,
      page: () => SupportScreen(),
    ),
    GetPage(
      name: AppRoutes.announcementsScreen,
      page: () => AnnouncementsScreen(),
      binding: AnnouncementsBinding(),
    ),
    GetPage(
      name: AppRoutes.createAnnouncementsScreen,
      page: () => CreateAnnouncementsScreen(),
      binding: AnnouncementsBinding(),
    ),
    GetPage(
      name: AppRoutes.announcementsDetailsScreen,
      page: () => AnnouncementsDetailsScreen(),
      binding: AnnouncementsBinding(),
    ),
    GetPage(
      name: AppRoutes.memberSelectScreen,
      page: () => MemberSelectScreen(),
      binding: MemberBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfileScreen,
      page: () => EditProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.profileInformationScreen,
      page: () => ProfileInformationScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.personalInfoScreen,
      page: () => PersonalInfoScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addBioScreen,
      page: () => AddBioScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addContactScreen,
      page: () => AddContactScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addEducationScreen,
      page: () => AddEducationScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addJobScreen,
      page: () => AddJobScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.addCvScreen,
      page: () => AddCvScreen(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.requestScreen,
      page: () => RequestScreen(),
      //binding: ProfileBinding(),
    ),


    GetPage(
      name: AppRoutes.adminDashboardScreen,
      page: () => AdminDashboardScreen(),
      //binding: ProfileBinding(),
    ),

    GetPage(
      name: AppRoutes.adminProfileScreen,
      page: () => AdminProfileScreen(),
      //binding: ProfileBinding(),
    ),
  ];
}



/// Auth feature — Login, SignUp, Forgot, OTP, ResetPassword
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AuthRepository>(() => AuthRepository(api: Get.find<ApiService>()));
    // Get.lazyPut<AuthController>(() => AuthController(repository: Get.find<AuthRepository>()));
  }
}


/// Bottom Nav feature — UserBar
class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());
  }
}

/// Profile feature — Edit, Information, PersonalInfo, Bio, Contact, Education, Job, CV
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<ProfileRepository>(() => ProfileRepository(api: Get.find<ApiService>()));
    // Get.lazyPut<ProfileController>(() => ProfileController(repository: Get.find<ProfileRepository>()));
  }
}

/// Announcements feature — List, Create, Details
class AnnouncementsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AnnouncementsRepository>(() => AnnouncementsRepository(api: Get.find<ApiService>()));
    // Get.lazyPut<AnnouncementsController>(() => AnnouncementsController(repository: Get.find<AnnouncementsRepository>()));
  }
}

/// Settings feature — Settings, ChangePassword
class SettingBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<SettingController>(() => SettingController());
  }
}

/// Language feature
class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<LanguageController>(() => LanguageController());
  }
}

/// Member select feature
class MemberBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<MemberController>(() => MemberController());
  }
}