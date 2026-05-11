import 'dart:io';

import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/data/repositories/tree_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class TreeService {
  final TreeRepository _repository;

  TreeService({required TreeRepository repository}) : _repository = repository;

  Future<void> fetchTree() async {
    try {
      await Future.wait([_repository.fetchTree()]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<UserModel> treeUserDetails(String userID) async {
    try {
      return await _repository.treeUserDetails(userID);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  TreeModel? getCachedUserData() {
    return _repository.getCachedTree();
  }
}
