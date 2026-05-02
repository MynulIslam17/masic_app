import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';

class ProfileRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  ProfileRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  // fetch user profile
  Future<UserModel> fetchUserProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfile);
      final data = response.data['data'];
      final user = UserModel.fromJson(data);

      await _cacheService.put(ApiConstants.cacheUserProfile, user.toJson());

      return user;
    } on AppException {
      final cached = getCachedUserData();
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  UserModel? getCachedUserData() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        ApiConstants.cacheUserProfile,
        defaultValue: null,
      );

      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error getting cached user data: $e');
      return null;
    }
  }

  Future<UserModel> updateUserProfile(
    UserModel user, {
     File? image,
  }) async {
    try {

      final bodyRequest = {
        'data': jsonEncode(user.toMap()),
      };

      final response = await _apiService.uploadFilePatch(
        ApiConstants.userProfileUpdate,
        data: bodyRequest,
        fieldName: 'image',
        file: image == null ? null : MultipartFile.fromFileSync(image.path, filename: image.path.split('/').last),
      );

      final data = response.data['data'];
      final updatedUser = UserModel.fromJson(data);
      await _cacheService.put(
        ApiConstants.cacheUserProfile,
        updatedUser.toJson(),
      );
      return updatedUser;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheUserProfile);
  }
}
