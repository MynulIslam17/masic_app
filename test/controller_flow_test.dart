import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import 'package:masic_generation/features/profile/domain/services/profile_service.dart';

import 'helpers/test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeApiService fakeApi;
  late FakeCacheService fakeCache;

  setUp(() {
    Get.reset();
    fakeApi = FakeApiService();
    fakeCache = FakeCacheService();
  });

  tearDown(() {
    Get.reset();
  });

  group('Controller Flow & Role Routing Decisions', () {
    test('Role recognition logic matches admin roles accurately', () {
      expect(AuthController.isAdminRole('admin'), isTrue);
      expect(AuthController.isAdminRole('ADMIN'), isTrue);
      expect(AuthController.isAdminRole('superadmin'), isTrue);
      expect(AuthController.isAdminRole('super_admin'), isTrue);
      expect(AuthController.isAdminRole('SUPER_ADMIN'), isTrue);
      expect(AuthController.isAdminRole('user'), isFalse);
      expect(AuthController.isAdminRole(''), isFalse);
      expect(AuthController.isAdminRole(null), isFalse);
    });

    test('SuperAdmin recognition logic matches superadmin only', () {
      expect(AuthController.isSuperAdminRole('superadmin'), isTrue);
      expect(AuthController.isSuperAdminRole('super_admin'), isTrue);
      expect(AuthController.isSuperAdminRole('admin'), isFalse);
      expect(AuthController.isSuperAdminRole('user'), isFalse);
    });

    test('ProfileService fetchUserProfile executes GET /api/v1/users/me and GET /api/v1/users', () async {
      final profileRepo = ProfileRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
      final profileService = ProfileService(repository: profileRepo);

      await profileService.fetchUserProfile(page: 1, limit: 10);

      // Verifies both endpoints are invoked concurrently for the dashboard
      expect(fakeApi.hasCalled('GET', ApiConstants.userProfile), isTrue);
      expect(fakeApi.hasCalled('GET', ApiConstants.usersProfile), isTrue);

      final userCall = fakeApi.callsMatching('GET', ApiConstants.usersProfile).first;
      expect(userCall.queryParameters?['page'], equals(1));
      expect(userCall.queryParameters?['limit'], equals(10));
    });

    test('Pagination: fetchUsersMore increments page and calls GET /api/v1/users with page: 2', () async {
      final profileRepo = ProfileRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
      final profileService = ProfileService(repository: profileRepo);

      final nextUsers = await profileService.fetchUsersMore(page: 2, limit: 10);

      final userCalls = fakeApi.callsMatching('GET', ApiConstants.usersProfile);
      expect(userCalls.length, equals(1));
      expect(userCalls.first.queryParameters?['page'], equals(2));
      expect(nextUsers.isNotEmpty, isTrue);
    });

    test('Filtered query: search and filters are correctly passed in queryParameters', () async {
      final profileRepo = ProfileRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
      final profileService = ProfileService(repository: profileRepo);

      await profileService.fetchUserProfile(
        page: 1,
        limit: 10,
        gender: 'Female',
        employmentStatus: 'employed',
        searchTerm: 'Sarah',
        role: 'user',
        treeJoinStatus: 'placed',
      );

      final call = fakeApi.callsMatching('GET', ApiConstants.usersProfile).first;
      expect(call.queryParameters?['gender'], equals('female'));
      expect(call.queryParameters?['employmentStatus'], equals('employed'));
      expect(call.queryParameters?['searchTerm'], equals('Sarah'));
      expect(call.queryParameters?['role'], equals('user'));
      expect(call.queryParameters?['treeJoinStatus'], equals('placed'));
    });
  });
}
