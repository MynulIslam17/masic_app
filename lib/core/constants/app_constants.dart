class AppConstants{
  AppConstants._();
  static const String accessToken = "accessToken";
  static const String refreshToken = "refreshToken";
  static const String cacheUserRole = "cacheUserRole";
  static const String cacheUser = "cacheUser";
  static const String lastSyncedFcmToken = 'last_synced_fcm_token';
  /// True from OTP verification until the Setup Profile step is saved, so a
  /// restart resumes sign-up on Setup Profile instead of skipping it.
  static const String profileSetupPending = 'profile_setup_pending';






















  static RegExp emailValidate = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static bool validatePassword(String value) {
    RegExp regex = RegExp(r'^(?=.*[0-9])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(value);
  }



}