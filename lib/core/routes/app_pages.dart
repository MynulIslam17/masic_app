import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import 'package:flutter_task/features/admin/profile/presentation/admin_profile_screen.dart';
import 'package:flutter_task/features/announcement/data/repositories/announcement_repository.dart';
import 'package:flutter_task/features/announcement/domain/services/announcement_services.dart';
import 'package:flutter_task/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:flutter_task/features/auth/presentation/pages/forget/forget_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/login/log_in_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/otp/otp_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/reset_pass/reset_password_screen.dart';
import 'package:flutter_task/features/auth/presentation/pages/sign_up/sign_up_screen.dart';
import 'package:flutter_task/features/banner/data/repositories/banner_repository.dart';
import 'package:flutter_task/features/banner/domain/services/banner_services.dart';
import 'package:flutter_task/features/banner/presentation/controllers/banner_controller.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/bottom_nav_user.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/home/domain/services/home_service.dart';
import 'package:flutter_task/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_task/features/poll/data/repositories/poll_repository.dart';
import 'package:flutter_task/features/poll/domain/services/poll_services.dart';
import 'package:flutter_task/features/poll/presentation/controllers/poll_controller.dart';
import 'package:flutter_task/features/poll/presentation/screens/poll_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/add_bio_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/add_contact_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/add_cv_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/add_education_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/add_job_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/user/announcements_details_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/user/announcements_screen.dart';
import 'package:flutter_task/features/announcement/presentation/screens/comon/create_announcements_screen.dart';
import 'package:flutter_task/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_task/features/profile/domain/services/profile_service.dart';
import 'package:flutter_task/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/profile/presentation/screens/support_screen.dart';
import 'package:flutter_task/features/request/data/repositories/request_repository.dart';
import 'package:flutter_task/features/request/domain/services/request_services.dart';
import 'package:flutter_task/features/request/presentation/controllers/request_controller.dart';
import 'package:flutter_task/features/request/presentation/screens/request_screen.dart';
import 'package:flutter_task/features/translation/presentation/language_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/member_select_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/personal_info_screen.dart';
import 'package:flutter_task/features/profile/presentation/screens/profile_information_screen.dart';
import 'package:flutter_task/features/profile/setting/change%20password/setting_change_password.dart';
import 'package:flutter_task/features/profile/setting/privacy_policy_all_screen.dart';
import 'package:flutter_task/features/profile/setting/setting_screen.dart';
import 'package:flutter_task/features/splash/splash_screen.dart';
import 'package:flutter_task/features/tree/data/repositories/tree_repository.dart';
import 'package:flutter_task/features/tree/domain/services/tree_service.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
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

    GetPage(name: AppRoutes.requestScreen, page: () => RequestScreen()),

    GetPage(
      name: AppRoutes.adminDashboardScreen,
      page: () => AdminDashboardScreen(),
    ),

    GetPage(
      name: AppRoutes.adminProfileScreen,
      page: () => AdminProfileScreen(),
    ),

    GetPage(name: AppRoutes.pollScreen, page: () => PollScreen()),
    GetPage(name: AppRoutes.treeDetailsScreen, page: () => TreeDetailsScreen()),
  ];
}

/// Bottom Nav feature — UserBar
class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BottomNavBarController>(() => BottomNavBarController());


    Get.lazyPut<TreeRepository>(
          () => TreeRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TreeService>(
          () => TreeService(repository: Get.find<TreeRepository>()),
      fenix: true,
    );

    Get.lazyPut<TreeController>(
          () => TreeController(
        service: Get.find<TreeService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeService>(
      () => HomeService(
        repository: Get.find<AnnouncementRepository>(),
        pollRepository: Get.find<PollRepository>(),
        bannerRepository: Get.find<BannerRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        service: Get.find<HomeService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileService>(
      () => ProfileService(repository: Get.find<ProfileRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        service: Get.find<ProfileService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AnnouncementRepository>(
      () => AnnouncementRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AnnouncementServices>(
      () =>
          AnnouncementServices(repository: Get.find<AnnouncementRepository>()),
      fenix: true,
    );

    Get.lazyPut<AnnouncementController>(
      () => AnnouncementController(
        service: Get.find<AnnouncementServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PollRepository>(
      () => PollRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PollServices>(
      () => PollServices(repository: Get.find<PollRepository>()),
      fenix: true,
    );

    Get.lazyPut<PollController>(
      () => PollController(
        service: Get.find<PollServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RequestRepository>(
      () => RequestRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RequestServices>(
      () => RequestServices(repository: Get.find<RequestRepository>()),
      fenix: true,
    );

    Get.lazyPut<RequestController>(
      () => RequestController(
        service: Get.find<RequestServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<BannerRepository>(
      () => BannerRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<BannerServices>(
      () => BannerServices(repository: Get.find<BannerRepository>()),
      fenix: true,
    );

    Get.lazyPut<BannerController>(
      () => BannerController(
        service: Get.find<BannerServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
  }
}
