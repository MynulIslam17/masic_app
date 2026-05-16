import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';

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
      final data = response.data['data'];
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
      return UserModel.fromJson(response.data['data']?['viewRoot']?['linkedUser'] ?? {});
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
