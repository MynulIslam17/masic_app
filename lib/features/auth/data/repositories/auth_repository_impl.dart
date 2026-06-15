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
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          "name": name,
          "email": email,
          "password": password,
          "phone": phone
        },
      );

      final data = response.data?['data'];
      final model = UserResponseModel.fromJson(
        data is Map<String, dynamic> ? data : {},
      );

      await _cacheService.put(AppConstants.cacheUser, model.toJson());

      return model;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<UserResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
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
  Future<bool> otpVerify({required String otp, required String email}) async {
    try {
      final response = await _apiService.post(
        ApiConstants.otpVerify,
        data: {'email': email, 'otp': otp},
      );
      final responseData = response.data?['data'];
      final accessToken = responseData?['accessToken'];

      if (accessToken != null) {
        await _cacheService.put(
          AppConstants.accessToken,
          accessToken.toString(),
        );
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
