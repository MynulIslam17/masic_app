import 'package:masic_generation/core/helpers/app_log.dart';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/document_upload_helper.dart';
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

  String _cacheKey(String role, {String? treeJoinStatus}) {
    final status = treeJoinStatus?.trim().toLowerCase() ?? '';
    if (status == 'placed') return ApiConstants.cachePlacedUsers;
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
      AppLog.error('Profile', 'Error getting cached user data: $e');
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
    String? treeJoinStatus,
  }) async {
    final cacheKey = _cacheKey(role ?? '', treeJoinStatus: treeJoinStatus);

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
        if (treeJoinStatus != null && treeJoinStatus.isNotEmpty) ...{
          'treeJoinStatus': treeJoinStatus,
          if (treeJoinStatus.toLowerCase() == 'placed') 'placedOnly': true,
        },
      };
      final response = await _apiService.get(
        ApiConstants.usersProfile,
        queryParameters: queryParameters,
      );

      final rawData = response.data['data'];
      final usersJson = rawData is List
          ? rawData
          : rawData is Map
              ? (rawData['users'] ??
                    rawData['items'] ??
                    rawData['results'] ??
                    rawData['data'] ??
                    const [])
              : const [];
      final users = (usersJson as List)
          .whereType<Map>()
          .map(
            (e) => UserModel.fromJson(
              Map<String, dynamic>.from(
                e.map((key, value) => MapEntry(key.toString(), value)),
              ),
            ),
          )
          .toList();

      if (page == 1) {
        await _cacheService.put(
          cacheKey,
          users.map((e) => e.toJson()).toList(),
        );
      }

      final total = _readTotalCount(response.data);
      if (total != null) {
        await _cacheService.put(_totalCacheKey(cacheKey), total);
      }

      return users;
    } on AppException {
      final cached = getCachedUsers(role ?? '', treeJoinStatus: treeJoinStatus);
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<UserModel> getCachedUsers(String role, {String? treeJoinStatus}) {
    final cacheKey = _cacheKey(role, treeJoinStatus: treeJoinStatus);
    try {
      final jsonList =
          _cacheService.get<List>(cacheKey, defaultValue: []) ?? [];
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  int? getCachedUsersTotal(String role, {String? treeJoinStatus}) {
    final cacheKey = _cacheKey(role, treeJoinStatus: treeJoinStatus);
    final value = _cacheService.get(_totalCacheKey(cacheKey));
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _totalCacheKey(String cacheKey) => '$cacheKey/total';

  int? _readTotalCount(dynamic body) {
    if (body is! Map) return null;
    final root = Map<String, dynamic>.from(
      body.map((key, value) => MapEntry(key.toString(), value)),
    );

    int? read(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    int? fromMeta(dynamic meta) {
      if (meta is! Map) return null;
      final map = Map<String, dynamic>.from(
        meta.map((key, value) => MapEntry(key.toString(), value)),
      );
      return read(map['total']) ??
          read(map['totalUsers']) ??
          read(map['totalCount']);
    }

    final data = root['data'];
    return fromMeta(root['meta']) ??
        fromMeta(root['pagination']) ??
        (data is Map ? fromMeta(data['meta']) : null) ??
        (data is Map ? fromMeta(data['pagination']) : null) ??
        read(root['total']);
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
    String? treeJoinStatus,
  }) async {
    final cacheKey = _cacheKey(role ?? '', treeJoinStatus: treeJoinStatus);
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
      treeJoinStatus: treeJoinStatus,
    );
    if (response.isNotEmpty) {
      final currentCached = getCachedUsers(
        role ?? '',
        treeJoinStatus: treeJoinStatus,
      );
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        cacheKey,
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

      var documentBudget = ImageUploadHelper.defaultMaxUploadBytes - 64 * 1024;
      if (uploadImage != null) {
        documentBudget -= await uploadImage.length();
      }
      if (documentBudget < 128 * 1024) {
        documentBudget = 128 * 1024;
      }

      final uploadCv = cv != null
          ? await DocumentUploadHelper.prepareForUpload(
              cv,
              maxBytes: documentBudget,
            )
          : null;
      if (uploadCv != null) {
        documentBudget -= await uploadCv.length();
        if (documentBudget < 64 * 1024) documentBudget = 64 * 1024;
      }
      final uploadCertificate = certificate != null
          ? await DocumentUploadHelper.prepareForUpload(
              certificate,
              maxBytes: documentBudget,
            )
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

      final response = await _apiService.patch(
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

  Future<void> deleteAccount() async {
    try {
      await _apiService.delete(ApiConstants.deleteMe);
      await _cacheService.delete(ApiConstants.cacheUserProfile);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete(ApiConstants.deleteUserByAdmin(userId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Mother trees for the Select Mother Tree page. Takes the same filter
  /// parameters as `GET /users`.
  Future<List<UserModel>> fetchMotherTrees({
    String? gender,
    String? employmentStatus,
    String? educationLevel,
    String? age,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (employmentStatus != null && employmentStatus.isNotEmpty)
          'employmentStatus': employmentStatus,
        if (educationLevel != null && educationLevel.isNotEmpty)
          'educationLevel': educationLevel,
        if (age != null && age.isNotEmpty) 'age': age,
      };
      final response = await _apiService.get(
        ApiConstants.motherTrees,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final rawData = response.data['data'];
      final list = rawData is List
          ? rawData
          : rawData is Map
              ? (rawData['motherTrees'] ??
                    rawData['trees'] ??
                    rawData['items'] ??
                    rawData['data'] ??
                    const [])
              : const [];
      return (list as List)
          .whereType<Map>()
          .map(
            (e) => UserModel.fromJson(
              Map<String, dynamic>.from(
                e.map((k, v) => MapEntry(k.toString(), v)),
              ),
            ),
          )
          .toList();
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
