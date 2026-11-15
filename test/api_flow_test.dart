import 'package:flutter_test/flutter_test.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/features/admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:masic_generation/features/banner/data/repositories/banner_repository.dart';
import 'package:masic_generation/features/notification/data/repositories/notification_repository.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import 'package:masic_generation/features/privacy/data/repositories/privacy_repository.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import 'package:masic_generation/features/request/data/repositories/request_repository.dart';
import 'package:masic_generation/features/tree/data/repositories/tree_repository.dart';

import 'helpers/test_fakes.dart';

void main() {
  late FakeApiService fakeApi;
  late FakeCacheService fakeCache;

  setUp(() {
    fakeApi = FakeApiService();
    fakeCache = FakeCacheService();
  });

  group('Flow 1: App Launch & Session Determination', () {
    test('Logged out state: no session token exists, user is unauthenticated', () {
      final authRepo = AuthRepositoryImpl(
        apiService: fakeApi,
        cacheService: fakeCache,
      );

      // App starts up fresh without any stored token in cache
      expect(authRepo.isLoggedIn(), isFalse);
      expect(authRepo.getAccessToken(), isNull);
      expect(authRepo.getCachedUser(), isNull);

      // In this state, protected APIs (like /api/v1/users/me) must NOT be called
      expect(fakeApi.hasCalled('GET', ApiConstants.userProfile), isFalse);
    });

    test('Logged in state: session token exists, user is authenticated', () async {
      final authRepo = AuthRepositoryImpl(
        apiService: fakeApi,
        cacheService: fakeCache,
      );

      await fakeCache.put(AppConstants.accessToken, 'valid_bearer_token');
      await fakeCache.put(AppConstants.cacheUser, {
        '_id': 'user_123',
        'email': 'test@example.com',
        'role': 'user',
        'treeJoinStatus': 'placed',
      });

      expect(authRepo.isLoggedIn(), isTrue);
      expect(authRepo.getAccessToken(), equals('valid_bearer_token'));
      expect(authRepo.getCachedUser()?.id, equals('user_123'));
    });
  });

  group('Flow 2: Authentication Flows', () {
    late AuthRepositoryImpl authRepo;

    setUp(() {
      authRepo = AuthRepositoryImpl(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('Login flow calls POST /api/v1/auth/login with credentials and caches session', () async {
      final user = await authRepo.login(
        email: 'user@example.com',
        password: 'password123',
        fcmToken: 'fcm_device_token_xyz',
      );

      expect(fakeApi.hasCalled('POST', ApiConstants.login), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.login).first;
      expect(call.data['email'], equals('user@example.com'));
      expect(call.data['password'], equals('password123'));
      expect(call.data['fcmToken'], equals('fcm_device_token_xyz'));

      expect(fakeCache.get<String>(AppConstants.accessToken), equals('jwt_access_token_123'));
      expect(user.email, equals('user@example.com'));
    });

    test('Registration flow calls POST /api/v1/auth/create with user details', () async {
      await authRepo.register(
        name: 'Ahmed',
        arabicName: 'أحمد',
        email: 'ahmed@example.com',
        phone: '0501234567',
        password: 'password123',
        fcmToken: 'fcm_token_1',
      );

      expect(fakeApi.hasCalled('POST', ApiConstants.register), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.register).first;
      expect(call.data['name'], equals('Ahmed'));
      expect(call.data['arabicName'], equals('أحمد'));
      expect(call.data['email'], equals('ahmed@example.com'));
      expect(call.data['phone'], equals('0501234567'));
      expect(call.data.containsKey('motherTreeMemberId'), isFalse);
      expect(call.data.containsKey('dateOfBirth'), isFalse);
    });

    test('OTP Verification calls POST /api/v1/auth/verify-otp', () async {
      await authRepo.otpVerify(
        email: 'ahmed@example.com',
        otp: '1234',
        fcmToken: 'fcm_token_1',
      );

      expect(fakeApi.hasCalled('POST', ApiConstants.otpVerify), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.otpVerify).first;
      expect(call.data['email'], equals('ahmed@example.com'));
      expect(call.data['otp'], equals('1234'));
    });

    test('Forgot Password calls POST /api/v1/auth/forget-password', () async {
      await authRepo.forgotPassword(email: 'user@example.com');

      expect(fakeApi.hasCalled('POST', ApiConstants.forgot), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.forgot).first;
      expect(call.data['email'], equals('user@example.com'));
    });

    test('Reset Password calls POST /api/v1/auth/reset-password', () async {
      await authRepo.resetPassword(
        newPassword: 'newpassword123',
      );

      expect(fakeApi.hasCalled('POST', ApiConstants.resetPassword), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.resetPassword).first;
      expect(call.data['newPassword'], equals('newpassword123'));
    });

    test('Change Password calls POST /api/v1/auth/change-password', () async {
      await authRepo.changePassword(
        oldPassword: 'oldpassword123',
        newPassword: 'newpassword123',
      );

      expect(fakeApi.hasCalled('POST', ApiConstants.changePassword), isTrue);
      final call = fakeApi.callsMatching('POST', ApiConstants.changePassword).first;
      expect(call.data['currentPassword'], equals('oldpassword123'));
      expect(call.data['newPassword'], equals('newpassword123'));
    });

    test('Logout clears session token and user cache', () async {
      await fakeCache.put(AppConstants.accessToken, 'token_to_clear');
      await fakeCache.put(AppConstants.cacheUser, {'_id': 'u1'});

      await authRepo.logout();

      expect(fakeCache.containsKey(AppConstants.accessToken), isFalse);
      expect(fakeCache.containsKey(AppConstants.cacheUser), isFalse);
      expect(authRepo.isLoggedIn(), isFalse);
    });
  });

  group('Flow 3: User Profile & Directory Flow', () {
    late ProfileRepository profileRepo;

    setUp(() {
      profileRepo = ProfileRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('fetchUserProfile calls GET /api/v1/users/me for logged-in user profile', () async {
      final user = await profileRepo.fetchUserProfile();

      expect(fakeApi.hasCalled('GET', ApiConstants.userProfile), isTrue);
      expect(user.sId, equals('u1'));
      expect(user.email, equals('user@example.com'));
      expect(fakeCache.containsKey(ApiConstants.cacheUserProfile), isTrue);
    });

    test('fetchUsers calls GET /api/v1/users with search & pagination query parameters', () async {
      await profileRepo.fetchUsers(
        page: 2,
        limit: 15,
        searchTerm: 'Nawal',
        role: 'user',
        gender: 'female',
        treeJoinStatus: 'placed',
      );

      expect(fakeApi.hasCalled('GET', ApiConstants.usersProfile), isTrue);
      final call = fakeApi.callsMatching('GET', ApiConstants.usersProfile).first;
      expect(call.queryParameters?['page'], equals(2));
      expect(call.queryParameters?['limit'], equals(15));
      expect(call.queryParameters?['searchTerm'], equals('Nawal'));
      expect(call.queryParameters?['role'], equals('user'));
      expect(call.queryParameters?['gender'], equals('female'));
      expect(call.queryParameters?['treeJoinStatus'], equals('placed'));
    });

    test('Admin role update calls PATCH /api/v1/super-admin/role/update/{userId}', () async {
      await profileRepo.updateRole('user_99', 'admin');

      final expectedPath = ApiConstants.updateRole('user_99');
      expect(fakeApi.hasCalled('PATCH', expectedPath), isTrue);
      final call = fakeApi.callsMatching('PATCH', expectedPath).first;
      expect(call.data['role'], equals('admin'));
    });

    test('Admin block/unblock user calls PATCH /api/v1/super-admin/block-unblock/{userId}', () async {
      await profileRepo.blockUser('user_99', type: 'block');

      final expectedPath = ApiConstants.blockUser('user_99');
      expect(fakeApi.hasCalled('PATCH', expectedPath), isTrue);
      final call = fakeApi.callsMatching('PATCH', expectedPath).first;
      expect(call.data['type'], equals('block'));
    });

    test('User account deletion calls DELETE /api/v1/users/me and wipes cached profile', () async {
      await fakeCache.put(ApiConstants.cacheUserProfile, {'_id': 'u1'});

      await profileRepo.deleteAccount();

      expect(fakeApi.hasCalled('DELETE', ApiConstants.deleteMe), isTrue);
      expect(fakeCache.containsKey(ApiConstants.cacheUserProfile), isFalse);
    });

    test('Admin deletes user calls DELETE /api/v1/super-admin/users/{userId}', () async {
      await profileRepo.deleteUser('user_99');

      final expectedPath = ApiConstants.deleteUserByAdmin('user_99');
      expect(fakeApi.hasCalled('DELETE', expectedPath), isTrue);
    });

    test('fetchMotherTrees calls GET /api/v1/member/mother-trees', () async {
      await profileRepo.fetchMotherTrees();

      expect(fakeApi.hasCalled('GET', ApiConstants.motherTrees), isTrue);
    });
  });

  group('Flow 4: Family Tree Flow', () {
    late TreeRepository treeRepo;

    setUp(() {
      treeRepo = TreeRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('fetchTree calls GET /api/v1/tree/full and caches the full tree', () async {
      final tree = await treeRepo.fetchTree();

      expect(fakeApi.hasCalled('GET', ApiConstants.tree), isTrue);
      expect(tree.treeInfo?.sId, equals('info_1'));
      expect(fakeCache.containsKey(ApiConstants.cacheTree), isTrue);
    });

    test('treeUserDetails calls GET /api/v1/tree/{userId} for member details', () async {
      fakeApi.customResponses[ApiConstants.treeUserDetails('member_42')] = {
        'success': true,
        'data': {
          '_id': 'member_42',
          'name': 'Fahad',
          'role': 'user',
        },
      };

      final user = await treeRepo.treeUserDetails('member_42');

      expect(fakeApi.hasCalled('GET', ApiConstants.treeUserDetails('member_42')), isTrue);
      expect(user.sId, equals('member_42'));
      expect(user.name, equals('Fahad'));
    });
  });

  group('Flow 5: Announcements Flow', () {
    late AnnouncementRepository announcementRepo;

    setUp(() {
      announcementRepo = AnnouncementRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('getAnnouncements (all) calls GET /api/v1/announcement/all?page=1&limit=10', () async {
      final list = await announcementRepo.getAnnouncements(1, 10);

      final expectedPath = ApiConstants.announcements(1, 10);
      expect(fakeApi.hasCalled('GET', expectedPath), isTrue);
      expect(list.length, equals(1));
      expect(list.first.title, equals('Test Announcement'));
    });

    test('getAnnouncements (my requests) calls GET /api/v1/announcement/my-requests?page=1&limit=10', () async {
      await announcementRepo.getAnnouncements(1, 10, type: 'my');

      final expectedPath = ApiConstants.myAnnouncements(1, 10);
      expect(fakeApi.hasCalled('GET', expectedPath), isTrue);
    });

    test('deleteAnnouncement calls DELETE /api/v1/announcement/{id}', () async {
      await announcementRepo.deleteAnnouncement('announcement_123');

      final expectedPath = ApiConstants.announcementStatus('announcement_123');
      expect(fakeApi.hasCalled('DELETE', expectedPath), isTrue);
    });
  });

  group('Flow 6: Polls Flow', () {
    late PollRepository pollRepo;

    setUp(() {
      pollRepo = PollRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('getPolls calls GET /api/v1/poll/?page=1&limit=10', () async {
      final list = await pollRepo.getPolls(1, 10);

      final expectedPath = ApiConstants.polls(1, 10);
      expect(fakeApi.hasCalled('GET', expectedPath), isTrue);
      expect(list.length, equals(1));
      expect(list.first.title, equals('Sample Poll Title'));
    });

    test('answerPoll calls POST /api/v1/poll/{pollId}/answer with chosen option', () async {
      await pollRepo.pollAnswer(
        pollId: 'poll_1',
        optionId: 'opt_yes',
        answer: 'Yes',
      );

      final expectedPath = ApiConstants.pollAns('poll_1');
      expect(fakeApi.hasCalled('POST', expectedPath), isTrue);
      final call = fakeApi.callsMatching('POST', expectedPath).first;
      expect(call.data['optionId'], equals('opt_yes'));
      expect(call.data['answer'], equals('Yes'));
    });

    test('getPollResult calls GET /api/v1/poll/{pollId}/answers', () async {
      fakeApi.customResponses[ApiConstants.pollDetails('poll_1')] = {
        'success': true,
        'data': <String, dynamic>{
          '_id': 'poll_1',
          'totalResponses': 100,
        },
      };

      await pollRepo.pollResult('poll_1');

      final expectedPath = ApiConstants.pollDetails('poll_1');
      expect(fakeApi.hasCalled('GET', expectedPath), isTrue);
    });

    test('deletePoll calls DELETE /api/v1/poll/{pollId}/delete', () async {
      await pollRepo.deletePoll('poll_1');

      final expectedPath = ApiConstants.pollDelete('poll_1');
      expect(fakeApi.hasCalled('DELETE', expectedPath), isTrue);
    });
  });

  group('Flow 7: Requests Flow', () {
    late RequestRepository requestRepo;

    setUp(() {
      requestRepo = RequestRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('fetchRequests calls GET /api/v1/request with page and limit parameters', () async {
      final list = await requestRepo.fetchRequests(page: 1, limit: 10);

      expect(fakeApi.hasCalled('GET', ApiConstants.requests), isTrue);
      final call = fakeApi.callsMatching('GET', ApiConstants.requests).first;
      expect(call.queryParameters?['page'], equals(1));
      expect(call.queryParameters?['limit'], equals(10));
      expect(list.first.status, equals('pending'));
    });

    test('Admin approves/rejects request calls PATCH /api/v1/super-admin/requests/update/{requestId}', () async {
      await requestRepo.updateStatus('req_55', 'approved', 'Verified documentation');

      final expectedPath = ApiConstants.requestStatus('req_55');
      expect(fakeApi.hasCalled('PATCH', expectedPath), isTrue);
      final call = fakeApi.callsMatching('PATCH', expectedPath).first;
      expect(call.data['status'], equals('approved'));
      expect(call.data['declineReason'], equals('Verified documentation'));
    });
  });

  group('Flow 8: Banners Flow', () {
    late BannerRepository bannerRepo;

    setUp(() {
      bannerRepo = BannerRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('fetchBanner (public/active) calls GET /api/v1/banner/', () async {
      await bannerRepo.fetchBanner(isAll: false);

      expect(fakeApi.hasCalled('GET', ApiConstants.banner), isTrue);
    });

    test('fetchBanner (all/admin) calls GET /api/v1/banner/all', () async {
      await bannerRepo.fetchBanner(isAll: true);

      expect(fakeApi.hasCalled('GET', ApiConstants.bannerAll), isTrue);
    });

    test('deleteBanner calls DELETE /api/v1/banner/{bannerId}/delete', () async {
      await bannerRepo.deleteBanner('banner_99');

      final expectedPath = ApiConstants.bannerDelete('banner_99');
      expect(fakeApi.hasCalled('DELETE', expectedPath), isTrue);
    });
  });

  group('Flow 9: Notifications Flow', () {
    test('getNotifications calls GET /api/v1/notification with pagination', () async {
      final notifRepo = NotificationRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );

      final list = await notifRepo.getNotifications(1, 10);

      final expectedPath = ApiConstants.notifications(1, 10);
      expect(fakeApi.hasCalled('GET', expectedPath), isTrue);
      expect(list.length, equals(1));
      expect(list.first.title, equals('Notification 1'));
    });
  });

  group('Flow 10: Admin Dashboard Stats Flow', () {
    test('fetchDashboard calls GET /api/v1/super-admin/stats', () async {
      final dashboardRepo = DashboardRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );

      final stats = await dashboardRepo.fetchDashboard();

      expect(fakeApi.hasCalled('GET', ApiConstants.dashboard), isTrue);
      expect(stats.ageRange, isNotNull);
      expect(stats.gender, isNotNull);
    });
  });

  group('Flow 11: Static Pages Flow (Privacy, Terms, About)', () {
    late PrivacyRepository privacyRepo;

    setUp(() {
      privacyRepo = PrivacyRepository(
        apiService: fakeApi,
        cacheService: fakeCache,
      );
    });

    test('fetchOne("privacy") calls GET /api/v1/privacy', () async {
      await privacyRepo.fetchOne('privacy');
      expect(fakeApi.hasCalled('GET', ApiConstants.privacyPolicy), isTrue);
    });

    test('fetchOne("terms") calls GET /api/v1/terms', () async {
      await privacyRepo.fetchOne('terms');
      expect(fakeApi.hasCalled('GET', ApiConstants.termsAndCondition), isTrue);
    });

    test('fetchOne("about") calls GET /api/v1/about', () async {
      await privacyRepo.fetchOne('about');
      expect(fakeApi.hasCalled('GET', ApiConstants.aboutUs), isTrue);
    });
  });
}