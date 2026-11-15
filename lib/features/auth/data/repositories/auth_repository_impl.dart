import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/auth/data/models/user_response_model.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  AuthRepositoryImpl({
    required ApiService apiService,

    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  @override
  Future<UserResponseModel> register({
    required String name,
    required String arabicName,
    required String email,
    required String phone,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          "name": name,
          "arabicName": arabicName,
          "email": email,
          "password": password,
          "phone": phone,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );

      final data = response.data?['data'];
      final model = UserResponseModel.fromJson(
        data is Map<String, dynamic> ? data : {},
      );

      await _cacheService.put(AppConstants.cacheUser, model.toJson());

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _markFcmSynced(fcmToken);
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> _markFcmSynced(String fcmToken) {
    return _cacheService.put(AppConstants.lastSyncedFcmToken, fcmToken);
  }

  @override
  Future<void> syncFcmToken(String fcmToken) async {
    if (!isLoggedIn() || fcmToken.isEmpty) return;

    final lastSynced = _cacheService.get<String>(AppConstants.lastSyncedFcmToken);
    if (lastSynced == fcmToken) return;

    final cachedUser = getCachedUser();
    final existing = cachedUser?.fcmToken ?? const <String>[];
    if (existing.contains(fcmToken)) {
      await _markFcmSynced(fcmToken);
      return;
    }

    try {
      await _apiService.patch(
        ApiConstants.userProfileUpdate,
        data: FormData.fromMap({
          'data': jsonEncode({'fcmToken': fcmToken}),
        }),
      );
      await _markFcmSynced(fcmToken);
    } catch (_) {
      // Login/OTP with fcmToken remains the reliable registration path.
    }
  }

  @override
  Future<UserResponseModel> login({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );

      final responseData = response.data?['data'];
      final userJson = responseData?['user'];
      final accessToken = responseData?['accessToken'];

      final model = UserResponseModel.fromJson(
        userJson is Map<String, dynamic> ? userJson : {},
      );

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }
      await _cacheService.put(AppConstants.cacheUser, model.toJson());

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _markFcmSynced(fcmToken);
      }

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiService.post(
        ApiConstants.forgot,
        data: {'email': email},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<bool> otpVerify({
    required String otp,
    required String email,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.otpVerify,
        data: {
          'email': email,
          'otp': otp,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );
      final responseData = response.data?['data'];
      final accessToken = responseData?['accessToken'];

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _markFcmSynced(fcmToken);
      }
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({
    required String newPassword,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.resetPassword,
        data: {
          "newPassword": newPassword,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  String? getAccessToken() {
    return _cacheService.get<String>(AppConstants.accessToken);
  }

  @override
  UserResponseModel? getCachedUser() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        AppConstants.cacheUser,
        defaultValue: null,
      );

      if (json == null) return null;

      return UserResponseModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateCachedUserTreeJoinStatus(String treeJoinStatus) async {
    final user = getCachedUser();
    if (user == null) return;

    await _cacheService.put(
      AppConstants.cacheUser,
      user.copyWith(treeJoinStatus: treeJoinStatus).toJson(),
    );
  }

  @override
  bool isProfileSetupPending() =>
      _cacheService.get<bool>(AppConstants.profileSetupPending) ?? false;

  @override
  Future<void> setProfileSetupPending(bool pending) => pending
      ? _cacheService.put(AppConstants.profileSetupPending, true)
      : _cacheService.delete(AppConstants.profileSetupPending);

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.changePassword,
        data: {
          "currentPassword": oldPassword,
          "newPassword": newPassword,
        },
      );

      final accessToken = response.data?['data']?['accessToken'];

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
      }

    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  bool isLoggedIn() {
    return _cacheService.containsKey(AppConstants.accessToken);
  }

  @override
  Future<void> logout() {
    return _cacheService.clear();
  }

}
