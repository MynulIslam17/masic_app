class ApiConstants {
  static const String baseUrl = 'https://mihad4173.merinasib.shop';

  /// ─── Auth Marker ───────────────────────────
  static const String requiresAuthHeader = 'X-Requires-Auth';
  static const Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// AUTH ──────────────────────────────────────────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/create';
  static const String forgot = '/api/v1/auth/forget-password';
  static const String otpVerify = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';




  /// USER ──────────────────────────────────────────────
  static const String userProfile = '/api/v1/users/me';
  static const String userProfileUpdate = '/api/v1/users/edit-profile';
  static const String usersProfile = '/api/v1/users';




  /// ─── Announcement Marker ───────────────────────────
  static String announcements(int page, int limit) => '/api/v1/announcement/all?page=$page&limit=$limit';
  static String announcementCreate = '/api/v1/announcement/create';
  static String announcementStatus(String announcementId) => '/api/v1/announcement/$announcementId';




  /// ─── poll Marker ───────────────────────────
  static String polls(int page, int limit) => '/api/v1/poll/?page=$page&limit=$limit';
  static String pollAns(String pollId) => '/api/v1/poll/$pollId/answer';
  static String pollDetails(String pollId) => '/api/v1/poll/$pollId/answers';
  static const String pollCreate = '/api/v1/poll/create';




  /// request ──────────────────────────────────────────────
  static const String requests = '/api/v1/request';
  static const String requestCreate = '/api/v1/request/create';
  static  String requestStatus(String requestId) => '/api/v1/super-admin/requests/update/$requestId';




  /// banner ──────────────────────────────────────────────
  static const String banner = '/api/v1/banner';
  static const String bannerCreate = '/api/v1/banner/upload';




  /// tree ──────────────────────────────────────────────
  static const String tree = '/api/v1/tree/full';
  static  String treeUserDetails(String userID) => '/api/v1/tree/$userID';




  /// Dashboard ──────────────────────────────────────────────

  static const String dashboard = '/api/v1/super-admin/stats';











  /// chach inpoint ──────────────────────────────────────────────

  static const String cacheUserProfile = 'user/me';
  static const String cacheUsersProfile = 'users/me';
  static const String cacheAnnouncements = 'announcements';
  static const String cacheMyAnnouncements = 'announcements_my';
  static const String cachePolls = 'poll';
  static const String cacheRequests = 'requests';
  static const String cacheBanner = 'banner';
  static const String cacheTree = 'tree';
  static const String cacheDashboard = 'dashboard';
}
