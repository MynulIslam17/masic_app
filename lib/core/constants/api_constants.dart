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
  static  String announcements(int page, int limit) => '/api/v1/announcement/?page=$page&limit=$limit';
  static  String announcementCreate = '/api/v1/announcement/create';
  static  String announcementStatus(String announcementId) => '/api/v1/announcement/$announcementId';




  /// ─── poll Marker ───────────────────────────
  static  String polls(int page, int limit) => '/api/v1/poll/?page=$page&limit=$limit';
  static String pollAns(String pollId) => '/api/v1/poll/$pollId/answer';
  static String pollDetails(String pollId) => '/api/v1/poll/$pollId/answers';
  static const String pollCreate = '/api/v1/poll/create';


  /// request ──────────────────────────────────────────────
  static const  String requests = '/api/v1/request';












  /// chach inpoint ──────────────────────────────────────────────

  static const String cacheUserProfile = 'user/me';
  static const String cacheUsersProfile = 'users/me';
  static const String cacheAnnouncements = 'announcements';
  static const String cachePolls = 'poll';
  static const String cacheRequests = 'requests';

















  static const String config = '/api/v1/config';
  static const String banners = '/api/v1/banners';
  static const String categories = '/api/v1/categories';
  static const String popularFoods = '/api/v1/products/popular';
  static const String foodCampaigns = '/api/v1/campaigns/item';

  static String restaurants(int offset, int limit) =>
      '/api/v1/restaurants/get-restaurants/all?offset=$offset&limit=$limit';




  static const String cacheBanners = 'banners';
  static const String cacheCategories = 'categories';
  static const String cachePopularFoods = 'popularFoods';
  static const String cacheFoodCampaigns = 'foodCampaigns';
  static const String cacheRestaurants = 'restaurants';
  static const String cacheRestaurantsTotalSize = 'restaurantsTotalSize';
}
