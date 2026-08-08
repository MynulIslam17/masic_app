import 'dart:io';

import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class ProfileService {
  final ProfileRepository _repository;

  ProfileService({required ProfileRepository repository})
    : _repository = repository;

  Future<UserModel?> fetchCurrentUser({String? userId}) async {
    return _repository.fetchCurrentUserProfile(userId: userId);
  }

  Future<void> fetchUserProfile({
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
    try {
      await Future.wait([
        _repository.fetchUserProfile(),
        _repository.fetchUsers(
          page: page,
          limit: limit,
          search: search,
          gender: gender?.toLowerCase(),
          employmentStatus: _fixEmploymentCase(employmentStatus),
          educationLevel: educationLevel?.toLowerCase(),
          searchTerm: searchTerm,
          age: age?.toLowerCase(),
          role: role,
          fieldOfWork: fieldOfWork,
          name: name,
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
    String? fieldOfWork,
    String? name,
  }) async {
    return await _repository.fetchUsersMore(
      page: page,
      limit: limit,
      gender: gender?.toLowerCase(),
      employmentStatus: employmentStatus,
      educationLevel: educationLevel?.toLowerCase(),
      searchTerm: searchTerm,
      age: age?.toLowerCase(),
      role: role,
      fieldOfWork: fieldOfWork,
      name: name,
    );
  }

  /// Lowercase employment status for the API, except 'student' which the
  /// backend expects as 'Student' (capital S).
  String? _fixEmploymentCase(String? value) {
    if (value == null || value.isEmpty) return value;
    final lower = value.toLowerCase();
    if (lower == 'student') return 'Student';
    return lower;
  }

  Future<UserModel> updateUserProfile(UserModel user, {File? image, File? cv,File? certificate}) async {
    return await _repository.updateUserProfile(user, image: image, cv: cv,certificate: certificate);
  }

  Future<void> updateRole(String userId,String role) async {
    return await _repository.updateRole(userId,role);
  }


  Future<void> motherTreeSelect(String userId) async {
    return await _repository.motherTreeSelect(userId);
  }

  Future<void> addMember(String userId,String motherId) async {
    return await _repository.addMember(userId,motherId);
  }


  Future<void> blockUser(String userId,{required String  type}) async {
    return await _repository.blockUser(userId,type: type);
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
