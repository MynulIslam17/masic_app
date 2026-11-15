import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/push_notification_service.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/banner/data/repositories/banner_repository.dart';
import 'package:masic_generation/features/home/domain/services/home_service.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import 'package:masic_generation/features/profile/domain/services/profile_service.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';

import 'helpers/test_fakes.dart';

class _Api extends FakeApiService {
  bool offline = false;
  Future<dynamic> Function(RecordedApiCall call)? respond;

  @override
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    final response = await super.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    final call = recordedCalls.last;
    if (offline) throw NoInternetException();
    if (respond != null) response.data = await respond!(call);
    return response;
  }
}

class _Push extends Fake implements PushNotificationService {}

Map<String, dynamic> _item(String id, {String status = 'pending'}) => {
  '_id': id,
  'title': id,
  'status': status,
};
Map<String, dynamic> _body(List<Map<String, dynamic>> items) => {'data': items};

Future<void> _settle() async {
  // Controller lifecycle calls start async loads without returning their futures.
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Api api;
  late FakeCacheService cache;
  late FakeConnectivityService connectivity;
  late AnnouncementRepository announcements;

  Future<void> signIn(String role) async {
    await cache.put(AppConstants.accessToken, 'test_token_$role');
    await cache.put(AppConstants.cacheUser, {
      '_id': 'me',
      'role': role,
      'treeJoinStatus': 'placed',
    });
    Get.put(
      AuthController(
        authService: AuthService(
          repository: AuthRepositoryImpl(apiService: api, cacheService: cache),
        ),
        pushNotificationService: _Push(),
      ),
    );
  }

  ProfileController directory() => Get.put(
    ProfileController(
      service: ProfileService(
        repository: ProfileRepository(apiService: api, cacheService: cache),
      ),
      connectivityService: connectivity,
    ),
  );

  AnnouncementController announcementController() => Get.put(
    AnnouncementController(
      service: AnnouncementServices(repository: announcements),
      connectivityService: connectivity,
    ),
  );

  List<RecordedApiCall> userCalls() => api.recordedCalls
      .where((call) => call.path == ApiConstants.usersProfile)
      .toList();

  List<RecordedApiCall> announcementCalls() => api.recordedCalls
      .where((call) => call.path.startsWith('/api/v1/announcement'))
      .toList();

  setUp(() {
    Get.testMode = true;
    api = _Api();
    cache = FakeCacheService();
    connectivity = FakeConnectivityService();
    announcements = AnnouncementRepository(
      apiService: api,
      cacheService: cache,
    );
  });
  tearDown(() async => Get.reset());

  group('Placed-only member directory', () {
    test(
      'normal member initial load and refresh send both placed filters',
      () async {
        await signIn('user');
        final controller = directory();
        await _settle();
        await controller.refresh();
        expect(userCalls(), isNotEmpty);
        for (final call in userCalls()) {
          expect(call.queryParameters?['treeJoinStatus'], 'placed');
          expect(call.queryParameters?['placedOnly'], true);
        }
      },
    );

    for (final role in ['admin', 'superAdmin']) {
      // Client requirement: no users outside the tree — admins included.
      test('$role directory only lists placed members', () async {
        await signIn(role);
        directory();
        await _settle();
        expect(userCalls().single.queryParameters?['treeJoinStatus'], 'placed');
        expect(userCalls().single.queryParameters?['placedOnly'], true);
      });
    }

    test('pagination retains placement and active search filters', () async {
      await signIn('user');
      api.customResponses[ApiConstants.usersProfile] = {
        'data': List.generate(
          10,
          (i) => {'_id': 'u$i', 'treeJoinStatus': 'placed'},
        ),
        'meta': {'total': 20},
      };
      final controller = directory();
      await _settle();
      controller.searchController.text = 'Sarah';
      await controller.loadMoreUsers();
      final call = userCalls().last;
      expect(call.queryParameters?['page'], 2);
      expect(call.queryParameters?['placedOnly'], true);
      expect(call.queryParameters?['searchTerm'], 'Sarah');
    });

    test('online search requests only placed members', () async {
      await signIn('user');
      final controller = directory();
      await _settle();
      await controller.search.search('not-in-local-cache');
      final call = userCalls().last;
      expect(call.queryParameters?['searchTerm'], 'not-in-local-cache');
      expect(call.queryParameters?['placedOnly'], true);
    });

    test(
      'offline search and directory never read unrestricted cache',
      () async {
        await signIn('user');
        connectivity.isConnected.value = false;
        await cache.put(ApiConstants.cacheUserProfile, {'_id': 'me'});
        await cache.put(ApiConstants.cacheUsersProfile, [
          {'_id': 'unplaced', 'name': 'Sarah unplaced'},
        ]);
        await cache.put(ApiConstants.cachePlacedUsers, [
          {'_id': 'placed', 'name': 'Sarah placed', 'treeJoinStatus': 'placed'},
        ]);
        final controller = directory();
        await _settle();
        expect(controller.usersData.map((u) => u.sId), ['placed']);
        await controller.search.search('Sarah');
        expect(controller.search.results.map((u) => u.sId), ['placed']);
        expect(userCalls(), isEmpty);
      },
    );

    test(
      'admin add-member picker can still include unplaced members',
      () async {
        await signIn('admin');
        final controller = directory();
        await _settle();
        await controller.startMotherTreePicker(placedOnly: false);
        expect(
          userCalls().last.queryParameters?.containsKey('placedOnly'),
          false,
        );
        // Backend defaults to placed, so the escape hatch must be explicit.
        expect(userCalls().last.queryParameters?['treeJoinStatus'], 'all');
        await controller.startMotherTreePicker(placedOnly: true);
        expect(userCalls().last.queryParameters?['placedOnly'], true);
      },
    );
  });

  group('Announcement requests and cache isolation', () {
    test(
      'public list uses documented route without an exact-status filter',
      () async {
        await announcements.getAnnouncements(1, 10);
        final call = announcementCalls().single;
        final uri = Uri.parse(call.path);
        expect(uri.path, '/api/v1/announcement');
        expect(uri.queryParameters, {'page': '1', 'limit': '10'});
        expect(call.queryParameters?.containsKey('status'), false);
      },
    );

    test(
      'admin pending request uses documented route with pending status',
      () async {
        await announcements.getAnnouncements(
          1,
          10,
          type: '',
          status: 'pending',
        );
        expect(
          Uri.parse(announcementCalls().single.path).path,
          '/api/v1/announcement',
        );
        expect(
          announcementCalls().single.queryParameters?['status'],
          'pending',
        );
        expect(announcements.hasCache('pending'), true);
        expect(announcements.hasCache('approved'), false);
      },
    );

    test(
      'my requests use dedicated route without approved-only filter',
      () async {
        await announcements.getAnnouncements(1, 10, type: 'my');
        final call = announcementCalls().single;
        expect(Uri.parse(call.path).path, '/api/v1/announcement/my-requests');
        expect(call.queryParameters?.containsKey('status'), false);
      },
    );

    test(
      'personal offline fallback never reads public or review caches',
      () async {
        await cache.put(ApiConstants.cacheApprovedAnnouncements, [
          _item('public'),
        ]);
        await cache.put(ApiConstants.cachePendingAnnouncements, [
          _item('review'),
        ]);
        await cache.put(ApiConstants.cacheMyAnnouncements, [_item('mine')]);
        api.offline = true;
        final result = await announcements.getAnnouncements(1, 10, type: 'my');
        expect(result.map((a) => a.sId), ['mine']);
      },
    );

    test(
      'missing personal cache propagates error without using public cache',
      () async {
        await cache.put(ApiConstants.cacheApprovedAnnouncements, [
          _item('public'),
        ]);
        api.offline = true;
        await expectLater(
          announcements.getAnnouncements(1, 10, type: 'my'),
          throwsA(isA<NoInternetException>()),
        );
      },
    );

    test(
      'legacy mixed cache is never treated as approved offline data',
      () async {
        await cache.put(ApiConstants.cacheAnnouncements, [
          _item('old-pending'),
        ]);
        api.offline = true;
        expect(announcements.hasCache('approved'), false);
        expect(announcements.getCachedAnnouncements('approved'), isEmpty);
        await expectLater(
          announcements.getAnnouncements(1, 10),
          throwsA(isA<NoInternetException>()),
        );
      },
    );

    test(
      'legacy personal cache contaminated by old pagination is not reused',
      () async {
        await cache.put('announcements_my', [_item('old-public-item')]);
        api.offline = true;
        expect(announcements.getCachedAnnouncements('my'), isEmpty);
        await expectLater(
          announcements.getAnnouncements(1, 10, type: 'my'),
          throwsA(isA<NoInternetException>()),
        );
      },
    );

    test(
      'approved pending declined and personal feeds remain separate',
      () async {
        for (final status in [
          'approved',
          'pending',
          'declined',
          'in_progress',
        ]) {
          api.respond = (_) async => _body([_item(status, status: status)]);
          await announcements.getAnnouncements(1, 10, type: '', status: status);
        }
        api.respond = (_) async => _body([_item('mine')]);
        await announcements.getAnnouncements(1, 10, type: 'my');
        for (final status in [
          'approved',
          'pending',
          'declined',
          'in_progress',
        ]) {
          expect(
            announcements.getCachedAnnouncements(status).single.sId,
            status,
          );
        }
        expect(announcements.getCachedAnnouncements('my').single.sId, 'mine');
      },
    );

    test('resolved personal cache key is safe to read', () async {
      await cache.put(ApiConstants.cacheMyAnnouncements, [_item('mine')]);
      await cache.put(ApiConstants.cacheApprovedAnnouncements, [
        _item('public'),
      ]);
      expect(
        announcements
            .getCachedAnnouncements(ApiConstants.cacheMyAnnouncements)
            .single
            .sId,
        'mine',
      );
    });

    for (final scope in ['my', 'approved', 'pending', 'in_progress', '']) {
      test(
        '$scope pagination keeps earlier pages and deduplicates repeated ids',
        () async {
          final type = scope == 'my' ? 'my' : '';
          final status = scope == 'my' ? null : scope;
          api.respond = (_) async => _body([_item('first'), _item('overlap')]);
          await announcements.getAnnouncements(
            1,
            10,
            type: type,
            status: status,
          );
          api.respond = (_) async => _body([_item('overlap'), _item('second')]);
          await announcements.fetchMoreAnnouncements(
            2,
            10,
            type: type,
            status: status,
          );
          expect(
            announcements.getCachedAnnouncements(scope).map((a) => a.sId),
            ['first', 'overlap', 'second'],
          );
          api.respond = (_) async => _body([_item('refreshed')]);
          await announcements.getAnnouncements(
            1,
            10,
            type: type,
            status: status,
          );
          expect(
            announcements.getCachedAnnouncements(scope).map((a) => a.sId),
            ['refreshed'],
          );
        },
      );
    }

    test(
      'offline pagination throws and leaves cached first page intact',
      () async {
        await cache.put(ApiConstants.cacheMyAnnouncements, [_item('mine')]);
        api.offline = true;
        await expectLater(
          announcements.fetchMoreAnnouncements(2, 10, type: 'my'),
          throwsA(isA<NoInternetException>()),
        );
        expect(announcements.getCachedAnnouncements('my').single.sId, 'mine');
      },
    );

    test(
      'search preserves list cache and applies correct scope and query',
      () async {
        await cache.put(ApiConstants.cacheMyAnnouncements, [_item('original')]);
        api.respond = (_) async => _body([_item('search-match')]);
        final result = await announcements.getAnnouncements(
          1,
          10,
          type: 'my',
          search: 'search-match',
        );
        expect(result.single.sId, 'search-match');
        expect(
          announcementCalls().single.queryParameters?['searchTerm'],
          'search-match',
        );
        expect(
          announcements.getCachedAnnouncements('my').single.sId,
          'original',
        );
      },
    );

    test('offline search filters only the selected cache', () async {
      await cache.put(ApiConstants.cacheMyAnnouncements, [
        _item('mine-match'),
        _item('other'),
      ]);
      await cache.put(ApiConstants.cacheApprovedAnnouncements, [
        _item('public-match'),
      ]);
      api.offline = true;
      final result = await announcements.getAnnouncements(
        1,
        10,
        type: 'my',
        search: 'match',
      );
      expect(result.map((a) => a.sId), ['mine-match']);
    });

    test('pagination retains search and review status', () async {
      await announcements.fetchMoreAnnouncements(
        2,
        10,
        status: 'pending',
        search: 'match',
      );
      final call = announcementCalls().single;
      expect(call.queryParameters?['searchTerm'], 'match');
      expect(call.queryParameters?['status'], 'pending');
      expect(Uri.parse(call.path).queryParameters['page'], '2');
    });
  });

  group('Announcement controller and home feed', () {
    for (final role in ['admin', 'superAdmin']) {
      test(
        '$role home keeps its approved view separate from default and review feeds',
        () async {
          await signIn(role);
          await cache.put(ApiConstants.cacheAnnouncementFeed, [
            _item('default-feed'),
          ]);
          await cache.put(ApiConstants.cachePendingAnnouncements, [
            _item('review'),
          ]);
          final home = HomeService(
            repository: announcements,
            pollRepository: PollRepository(
              apiService: api,
              cacheService: cache,
            ),
            bannerRepository: BannerRepository(
              apiService: api,
              cacheService: cache,
            ),
          );
          expect(home.getCachedHomeData().announcements, isEmpty);
          await home.fetchAllHomeData();
          expect(
            announcementCalls().single.queryParameters?['status'],
            'approved',
          );
          expect(home.getCachedHomeData().announcements.single.sId, 'a1');
          expect(
            announcements.getCachedAnnouncements('').single.sId,
            'default-feed',
          );
          expect(
            announcements.getCachedAnnouncements('pending').single.sId,
            'review',
          );
        },
      );
    }
    for (final role in ['user', 'admin', 'superAdmin']) {
      test(
        '$role loads the correct tab scope and switches to my requests',
        () async {
          await signIn(role);
          final controller = announcementController();
          await _settle();
          expect(
            announcementCalls().single.queryParameters?['status'],
            role == 'user' ? null : 'pending',
          );
          controller.onTabChanged(1);
          await _settle();
          expect(
            Uri.parse(announcementCalls().last.path).path,
            '/api/v1/announcement/my-requests',
          );
          expect(
            announcementCalls().last.queryParameters?.containsKey('status'),
            false,
          );
        },
      );
    }

    test(
      'switching offline to uncached my tab clears previous public items',
      () async {
        await signIn('user');
        final controller = announcementController();
        await _settle();
        expect(controller.announcements, isNotEmpty);
        connectivity.isConnected.value = false;
        controller.onTabChanged(1);
        await _settle();
        expect(controller.announcements, isEmpty);
      },
    );

    test(
      'late public response cannot populate the current personal tab',
      () async {
        await signIn('user');
        final publicResponse = Completer<dynamic>();
        api.respond = (call) async {
          if (call.path.contains('/my-requests')) return _body([_item('mine')]);
          return await publicResponse.future;
        };
        final controller = announcementController();
        await _settle();
        controller.onTabChanged(1);
        await _settle();
        expect(controller.announcements.single.sId, 'mine');
        publicResponse.complete(_body([_item('public')]));
        await _settle();
        expect(controller.announcements.single.sId, 'mine');
      },
    );

    test(
      'remote personal search returns results without overwriting feed cache',
      () async {
        await signIn('user');
        final controller = announcementController();
        await _settle();
        controller.onTabChanged(1);
        await _settle();
        api.respond = (_) async => _body([_item('remote-match')]);
        await controller.search.search('remote-match');
        expect(controller.search.results.single.sId, 'remote-match');
        expect(announcements.getCachedAnnouncements('my').single.sId, 'a1');
      },
    );

    test(
      'normal home uses default feed and cannot reuse pending review cache',
      () async {
        await cache.put(ApiConstants.cachePendingAnnouncements, [
          _item('review'),
        ]);
        final home = HomeService(
          repository: announcements,
          pollRepository: PollRepository(apiService: api, cacheService: cache),
          bannerRepository: BannerRepository(
            apiService: api,
            cacheService: cache,
          ),
        );
        expect(home.getCachedHomeData().announcements, isEmpty);
        await home.fetchAllHomeData();
        expect(
          announcementCalls().single.queryParameters?.containsKey('status'),
          false,
        );
        expect(home.getCachedHomeData().announcements.single.sId, 'a1');
        expect(
          announcements.getCachedAnnouncements('pending').single.sId,
          'review',
        );
      },
    );
  });
}
