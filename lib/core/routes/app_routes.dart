abstract class AppRoutes {
  AppRoutes._();

  // ─── Initial ─────────────────────────────────────────────────────────────
  static const String initial = '/';

  // ─── Auth ─────────────────────────────────────────────────────────────────
  static const String splashScreen = '/';
  static const String loginScreen = '/login';
  static const String signUpScreen = '/sign-up';
  static const String forgotScreen = '/forgot';
  static const String otpScreen = '/otp';
  static const String resetPasswordScreen = '/reset-password';

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  static const String bottomNavUserBar = '/bottomNavUserBar';

  // ─── Profile ──────────────────────────────────────────────────────────────
  static const String languageScreen = '/language';
  static const String settingScreen = '/settings';
  static const String settingChangePassword = '/settings/change-password';
  static const String privacyPolicyAllScreen = '/privacy-policy';
  static const String supportScreen = '/support';
  static const String announcementsScreen = '/announcements';
  static const String createAnnouncementsScreen = '/announcements/create';
  static const String announcementsDetailsScreen = '/announcements/details';
  static const String memberSelectScreen = '/member-select';
  static const String editProfileScreen = '/profile/edit';
  static const String profileDetailsScreen = '/profile/details';
  static const String profileInformationScreen = '/profile/information';
  static const String personalInfoScreen = '/profile/personal-info';
  static const String addBioScreen = '/profile/add-bio';
  static const String addContactScreen = '/profile/add-contact';
  static const String addEducationScreen = '/profile/add-education';
  static const String addJobScreen = '/profile/add-job';
  static const String addCvScreen = '/profile/add-cv';
  static const String motherSelectScreen = '/mother-select';


  // ─── Request ──────────────────────────────────────────────────────────────
  static const String requestedScreen = '/home/requested';
  static const String requestDetailsScreen = '/home/request/details';
  static const String reasonScreen = '/home/request/reason';
  static const String requestScreen = '/home/request/request';
  static const String adminRequestScreen = '/home/request/admin';
  static const String jobSpecificationScreen = '/home/request/job-specification';


  // home ──────────────────────────────────────────────────────────────
  static const String homeScreen = '/home';





  // ─── Admin ──────────────────────────────────────────────────────────────
  static const String adminDashboardScreen = '/admin/home';
  static const String adminProfileScreen = '/admin/profile';
  static const String allUserScreen = '/admin/all-user';
  static const String allAdminScreen = '/admin/all-admin';


  // ─── Poll ──────────────────────────────────────────────────────────────
  static const String pollDetailsScreen = '/home/poll/details';
  static const String pollScreen = '/home/poll/all';
  static const String createPollScreen = '/home/poll/create';
  static const String pollResultScreen = '/home/poll/result';


  // tree ──────────────────────────────────────────────────────────────
  static const String treeDetailsScreen = '/home/tree';
  static const String adminTreeScreen = '/home/tree/admin';

  // banner ──────────────────────────────────────────────────────────────
  static const String bannerScreen = '/home/banner';

}
