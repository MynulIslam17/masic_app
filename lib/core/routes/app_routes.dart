/// Route name constants for the entire application.
///
/// All route names are defined here as static constants. Use these constants
/// everywhere instead of string literals to prevent typos and to get
/// compile-time safety when navigating.
///
/// **Usage:**
/// ```dart
/// // Navigate to a named route
/// Get.toNamed(AppRoutes.homeScreen);
///
/// // Navigate and remove all previous routes
/// Get.offAllNamed(AppRoutes.loginScreen);
///
/// // Navigate with arguments
/// Get.toNamed(AppRoutes.announcementsDetailsScreen, arguments: {'id': '123'});
/// ```
///
/// **Adding a new route:**
/// 1. Add the constant here: `static const String profile = '/profile';`
/// 2. Add a [GetPage] entry in [AppPages.routes].
/// 3. Optionally create a [Bindings] class for that page.
abstract class AppRoutes {
  AppRoutes._();

  // ─── Initial ─────────────────────────────────────────────────────────────
  static const String initial = '/';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String splashScreen        = '/';
  static const String loginScreen         = '/login';
  static const String signUpScreen        = '/sign-up';
  static const String forgotScreen        = '/forgot';
  static const String otpScreen           = '/otp';
  static const String resetPasswordScreen = '/reset-password';

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  static const String bottomNavUserBar = '/bottomNavUserBar';

  // ─── Profile ──────────────────────────────────────────────────────────────
  static const String languageScreen             = '/language';
  static const String settingScreen              = '/settings';
  static const String settingChangePassword      = '/settings/change-password';
  static const String privacyPolicyAllScreen     = '/privacy-policy';
  static const String supportScreen              = '/support';
  static const String announcementsScreen        = '/announcements';
  static const String createAnnouncementsScreen  = '/announcements/create';
  static const String announcementsDetailsScreen = '/announcements/details';
  static const String memberSelectScreen         = '/member-select';
  static const String editProfileScreen          = '/profile/edit';
  static const String profileInformationScreen   = '/profile/information';
  static const String personalInfoScreen         = '/profile/personal-info';
  static const String addBioScreen               = '/profile/add-bio';
  static const String addContactScreen           = '/profile/add-contact';
  static const String addEducationScreen         = '/profile/add-education';
  static const String addJobScreen               = '/profile/add-job';
  static const String addCvScreen                = '/profile/add-cv';


// ─── Request ──────────────────────────────────────────────────────────────
  static const String requestScreen                = '/home/request';




  // ─── Admin ──────────────────────────────────────────────────────────────
  static const String adminDashboardScreen                = '/home/admin';
}