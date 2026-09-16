import 'package:masic_generation/features/auth/data/models/user_response_model.dart';

abstract class AuthRepository {
  Future<UserResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  });

  Future<UserResponseModel> register({
    required String name,
    required String arabicName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<bool> otpVerify({
    required String otp,
    required String email,
    String? fcmToken,
  });

  Future<void> resetPassword({
    required String newPassword,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// ─── CACHE GETTERS ───────────────────────────────
  bool isLoggedIn();

  String? getAccessToken();

  UserResponseModel? getCachedUser();

  Future<void> updateCachedUserTreeJoinStatus(String treeJoinStatus);

  /// ─── LOGOUT ──────────────────────────────────────
  Future<void> logout();
}
