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
    int? age,
  }) async {
    try {
      await Future.wait([
        _repository.fetchUserProfile(),
        _repository.fetchUsers(
          page: page,
          limit: limit,
          gender: gender,
          employmentStatus: employmentStatus,
          educationLevel: educationLevel,
          searchTerm: searchTerm,
          age: age,
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
    int? age,
  }) async {
    return await _repository.fetchUsers(
      page: page,
      limit: limit,
      gender: gender,
      employmentStatus: employmentStatus,
      educationLevel: educationLevel,
      searchTerm: searchTerm,
      age: age,
    );
  }

  Future<UserModel> updateUserProfile(UserModel user, {File? image}) async {
    return await _repository.updateUserProfile(user, image: image);
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  UserModel? getCachedUserData() {
    return _repository.getCachedUserData();
  }

  List<UserModel> getCachedUsers() {
    return _repository.getCachedUsers();
  }
}
