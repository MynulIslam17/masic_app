import 'dart:io';

import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/data/repositories/profile_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class ProfileService {
  final ProfileRepository _repository;

  ProfileService({required ProfileRepository repository})
    : _repository = repository;

  Future<void> fetchUserProfile({
    int page = 1,
    int limit = 10,
    String? gender,
    String? employmentStatus,
    String? educationLevel,
    String? searchTerm,
    String? age,
    String? role,
  }) async {
    try {
      await Future.wait([
        _repository.fetchUserProfile(),
        _repository.fetchUsers(
          page: page,
          limit: limit,
          gender: gender?.toLowerCase(),
          employmentStatus: employmentStatus?.toLowerCase(),
          educationLevel: educationLevel?.toLowerCase(),
          searchTerm: searchTerm,
          age: age?.toLowerCase(),
          role: role,
        ),
      ]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
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
  }) async {
    return await _repository.fetchUsersMore(
      page: page,
      limit: limit,
      gender: gender?.toLowerCase(),
      employmentStatus: employmentStatus?.toLowerCase(),
      educationLevel: educationLevel?.toLowerCase(),
      searchTerm: searchTerm,
      age: age?.toLowerCase(),
      role: role,
    );
  }

  Future<UserModel> updateUserProfile(UserModel user, {File? image, File? cv,File? certificate}) async {
    return await _repository.updateUserProfile(user, image: image);
  }

  Future<void> updateRole(String userId,String role) async {
    return await _repository.updateRole(userId,role);
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  UserModel? getCachedUserData() {
    return _repository.getCachedUserData();
  }

  List<UserModel> getCachedUsers(String role) {
    return _repository.getCachedUsers(role);
  }
}
