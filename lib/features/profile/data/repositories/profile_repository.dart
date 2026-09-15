import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/image_upload_helper.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';

class ProfileRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  ProfileRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  String _cacheKey(String role) {
    switch (role) {
      case 'admin':
        return ApiConstants.cacheAdminProfile;
      default:
        return ApiConstants.cacheUsersProfile;
    }
  }

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

  Future<UserModel?> fetchCurrentUserProfile({String? userId}) async {
    try {
      return await fetchUserProfile();
    } on AppException {
      final cached = getCachedUserData();
      if (cached != null) return cached;
      return getCachedUserFromList(userId);
    }
  }

  Map<String, dynamic>? _readMapCache(String key) {
    final raw = _cacheService.get(key);
    if (raw == null) return null;
    if (raw is Map) {
      return Map<String, dynamic>.from(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return null;
  }

  UserModel? getCachedUserData() {
    try {
      final json = _readMapCache(ApiConstants.cacheUserProfile);
      if (json == null) return null;
      return UserModel.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error getting cached user data: $e');
      return null;
    }
  }

  UserModel? getCachedUserFromList(String? userId) {
    if (userId == null) return null;
    for (final user in getCachedUsers('')) {
      if (user.sId == userId) return user;
    }
    return null;
  }

  Future<List<UserModel>> fetchUsers({
    int page = 1,
    int limit = 10,
    String? gender,
    String? employmentStatus,
    String? educationLevel,
    String? searchTerm,
    String? age,
    String? role,
    String? search,
    String? fieldOfWork,
    String? name,
  }) async {
    final cacheKey = _cacheKey(role ?? '');

    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'limit': limit,
        'searchTerm': search,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (searchTerm != null && searchTerm.isNotEmpty)
          'searchTerm': searchTerm,
        if (employmentStatus != null && employmentStatus.isNotEmpty)
          'employmentStatus': employmentStatus,
        if (educationLevel != null && educationLevel.isNotEmpty)
          'educationLevel': educationLevel,
        if (age != null && age.isNotEmpty) 'age': age,
        if (role != null && role.isNotEmpty) 'role': role,
        if (fieldOfWork != null && fieldOfWork.isNotEmpty)
          'fieldOfWork': fieldOfWork,
        if (name != null && name.isNotEmpty) 'name': name,
      };
      final response = await _apiService.get(
        ApiConstants.usersProfile,
        queryParameters: queryParameters,
      );

      final users = (response.data['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();

      await _cacheService.put(cacheKey, users.map((e) => e.toJson()).toList());

      return users;
    } on AppException {
      final cached = getCachedUsers(cacheKey);
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<UserModel> getCachedUsers(String role) {
    final cacheKey = _cacheKey(role);
    try {
      final jsonList =
          _cacheService.get<List>(cacheKey, defaultValue: []) ?? [];
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> fetchUsersMore({
    int page = 1,
    int limit = 10,
    String? gender,
    String? employmentStatus,
    String? educationLevel,
    String? searchTerm,
    String? age,
    String? role,
    String? fieldOfWork,
    String? name,
  }) async {
    final cacheKey = _cacheKey(role ?? '');
    final response = await fetchUsers(
      page: page,
      limit: limit,
      gender: gender,
      employmentStatus: employmentStatus,
      educationLevel: educationLevel,
      searchTerm: searchTerm,
      age: age,
      role: role,
      fieldOfWork: fieldOfWork,
      name: name,
    );
    if (response.isNotEmpty) {
      final currentCached = getCachedUsers(cacheKey);
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        _cacheKey(role ?? ''),
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }

  Future<UserModel> updateUserProfile(
      UserModel user, {
        File? image,
        File? cv,
        File? certificate,
      }) async {
    try {
      final uploadImage =
          image != null ? await ImageUploadHelper.prepareProfileImage(image) : null;
      final uploadCv =
          cv != null ? await ImageUploadHelper.prepareIfImageFile(cv) : null;
      final uploadCertificate = certificate != null
          ? await ImageUploadHelper.prepareIfImageFile(certificate)
          : null;

      final formData = FormData.fromMap({
        'data': jsonEncode(user.toMap()),
        if (uploadImage != null)
          'image': await MultipartFile.fromFile(
            uploadImage.path,
            filename: 'profile.jpg',
          ),
        if (uploadCv != null)
          'cv': await MultipartFile.fromFile(
            uploadCv.path,
            filename: uploadCv.path.split('/').last,
          ),
        if (uploadCertificate != null)
          'certificates': await MultipartFile.fromFile(
            uploadCertificate.path,
            filename: uploadCertificate.path.split('/').last,
          ),
      });

      final response = await _apiService.dio.patch(
        ApiConstants.userProfileUpdate,
        data: formData,
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

  Future<void> updateRole(String userId, String role) async {
    try {
      await _apiService.patch(
        ApiConstants.updateRole(userId),
        data: {'role': role},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  Future<void> motherTreeSelect (String userId) async {
    try {
      await _apiService.post(ApiConstants.motherTreeSelect(userId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> addMember (String userId,String motherId) async {
    try {
      await _apiService.post(ApiConstants.addMember(userId,motherId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  Future<void> blockUser (String userId,{required String  type}) async {
    try {
      await _apiService.patch(ApiConstants.blockUser(userId),
        data: {
          'type': type,
        }
      );
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
