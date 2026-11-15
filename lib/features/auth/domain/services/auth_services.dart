import 'package:masic_generation/features/auth/data/models/user_response_model.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({required AuthRepository repository}) : _repository = repository;

  /// ─── LOGIN ─────────────────────────────
  Future<UserResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    return _repository.login(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
  }

  /// ─── REGISTER ──────────────────────────
  Future<UserResponseModel> register({
    required String name,
    required String arabicName,
    required String email,
    required String phone,
    required String confirmPassword,
    String? fcmToken,
  }) async {
    return _repository.register(
      name: name,
      arabicName: arabicName,
      email: email,
      phone: phone,
      password: confirmPassword,
      fcmToken: fcmToken,
    );
  }

  Future<void> syncFcmToken(String fcmToken) =>
      _repository.syncFcmToken(fcmToken);

  /// ─── FORGOT PASSWORD ───────────────────
  Future<void> forgotPassword(String email) async {
    return await _repository.forgotPassword(email: email);
  }

  /// ─── OTP VERIFY ───────────────────
  Future<bool> otpVerify({
    required String email,
    required String otp,
    String? fcmToken,
  }) async {
    return _repository.otpVerify(
      email: email,
      otp: otp,
      fcmToken: fcmToken,
    );
  }

  /// ─── OTP VERIFY ───────────────────
  Future<void> resetPassword({
    required String newPassword,
  }) async {
    return await _repository.resetPassword(
      newPassword: newPassword,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  /// ─── SESSION ───────────────────────────
  bool isLoggedIn() => _repository.isLoggedIn();

  String? getToken() => _repository.getAccessToken();

  Future<void> logout() => _repository.logout();

  UserResponseModel? getCachedUser() => _repository.getCachedUser();

  Future<void> syncTreeJoinStatus(String treeJoinStatus) =>
      _repository.updateCachedUserTreeJoinStatus(treeJoinStatus);

  bool get isProfileSetupPending => _repository.isProfileSetupPending();

  Future<void> setProfileSetupPending(bool pending) =>
      _repository.setProfileSetupPending(pending);

  bool isTreePlaced([UserResponseModel? user]) {
    final currentUser = user ?? getCachedUser();
    return currentUser?.treeJoinStatus == 'placed';
  }
}
