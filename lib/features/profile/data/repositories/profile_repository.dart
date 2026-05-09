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

  Future<List<UserModel>> fetchUsers({
    int page = 1,
    int limit = 10,
    String? gender,
    String? employmentStatus,
    String? educationLevel,
    String? searchTerm,
    int? age,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
        if (employmentStatus != null && employmentStatus.isNotEmpty)
          'employmentStatus': employmentStatus,
        if (educationLevel != null && educationLevel.isNotEmpty)
          'educationLevel': educationLevel,
        if (age != null && age != 0) 'age': age,
      };
      final response = await _apiService.get(
        ApiConstants.usersProfile,
        queryParameters: queryParameters,
      );

      final users = (response.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      await _cacheService.put(
        ApiConstants.cacheUsersProfile,
        users.map((e) => e.toJson()).toList(),
      );
      return users;
    } on AppException {
      final cached = getCachedUsers();
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<UserModel> getCachedUsers() {
    try {
      final jsonList =
          _cacheService.get<List>(
            ApiConstants.cacheUsersProfile,
            defaultValue: [],
          ) ??
          [];
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<UserModel> updateUserProfile(UserModel user, {File? image,File? cv,File? certificate}) async {
    try {
      final bodyRequest = {'data': jsonEncode(user.toMap())};

      final files = <MultipartFile>[
        if (image != null)
          MultipartFile.fromFileSync(
            image.path,
            filename: image.path.split('/').last,
          ),
        if (cv != null)
          MultipartFile.fromFileSync(
            cv.path,
            filename: cv.path.split('/').last,
          ),
        if (certificate != null)
          MultipartFile.fromFileSync(
            certificate.path,
            filename: certificate.path.split('/').last,
          ),
      ];

      final response = await _apiService.uploadMultipleFilesPatch(
        ApiConstants.userProfileUpdate,
        data: bodyRequest,
        files: files,
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
