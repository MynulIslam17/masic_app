import 'package:flutter/material.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';

class TreeRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  TreeRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<TreeModel> fetchTree() async {
    try {
      final response = await _apiService.get(ApiConstants.tree);
      final raw = response.data['data'] ?? response.data;
      final data = raw is Map
          ? Map<String, dynamic>.from(
              raw.map((key, value) => MapEntry(key.toString(), value)),
            )
          : <String, dynamic>{};
      final tree = TreeModel.fromJson(data);

      await _cacheService.put(ApiConstants.cacheTree, tree.toJson());

      return tree;
    } on AppException {
      final cached = getCachedTree();
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  TreeModel? getCachedTree() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        ApiConstants.cacheTree,
        defaultValue: null,
      );

      if (json == null) return null;
      return TreeModel.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error getting cached user data: $e');
      return null;
    }
  }

  Future<UserModel> treeUserDetails(String userID) async {
    try {
      final response = await _apiService.get(
        ApiConstants.treeUserDetails(userID),
      );
      final data = response.data['data'];
      Map<String, dynamic> json = {};
      if (data is Map) {
        final linked = data['linkedUser'] ??
            data['user'] ??
            (data['viewRoot'] is Map
                ? (data['viewRoot']['linkedUser'] ??
                    data['viewRoot']['user'] ??
                    data['viewRoot'])
                : null) ??
            (data['root'] is Map
                ? (data['root']['linkedUser'] ??
                    data['root']['user'] ??
                    data['root'])
                : null) ??
            data;
        if (linked is Map) {
          json = Map<String, dynamic>.from(
            linked.map((key, value) => MapEntry(key.toString(), value)),
          );
        }
      }
      return UserModel.fromJson(json);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.post(ApiConstants.deleteUser(userId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheTree);
  }
}
