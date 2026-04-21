class ApiConstants {


  static const String baseUrl = 'https://mihad4173.merinasib.shop';

/// ─── Auth Marker ───────────────────────────
  static const String requiresAuthHeader = 'X-Requires-Auth';






  /// AUTH ──────────────────────────────────────────────
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/create';
  static const String forgot = '/api/v1/auth/forget-password';
  static const String otpVerify = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';


























  static const String config = '/api/v1/config';
  static const String banners = '/api/v1/banners';
  static const String categories = '/api/v1/categories';
  static const String popularFoods = '/api/v1/products/popular';
  static const String foodCampaigns = '/api/v1/campaigns/item';

  static String restaurants(int offset, int limit) =>
      '/api/v1/restaurants/get-restaurants/all?offset=$offset&limit=$limit';

  static const Map<String, dynamic> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };



  static const String cacheBanners = 'banners';
  static const String cacheCategories = 'categories';
  static const String cachePopularFoods = 'popularFoods';
  static const String cacheFoodCampaigns = 'foodCampaigns';
  static const String cacheRestaurants = 'restaurants';
  static const String cacheRestaurantsTotalSize = 'restaurantsTotalSize';
}
