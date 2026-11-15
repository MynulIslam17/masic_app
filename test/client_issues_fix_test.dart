// Regression tests for the client-reported frontend issues (FRONTEND_ISSUES.md)
// and the app-side checklist from APP_CLI_BACKEND_VERIFICATION.md.
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/push_notification_service.dart';
import 'package:masic_generation/features/admin/dashboard/data/models/dashboard_model.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import 'package:masic_generation/features/profile/domain/services/profile_service.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/tree/presentation/widgets/family_tree.dart';

import 'helpers/test_fakes.dart';

/// Fake API that can answer GETs with a custom body or throw.
class _Api extends FakeApiService {
  bool offline = false;
  AppException? throwOnGet;
  dynamic Function(RecordedApiCall call)? respond;

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
    if (offline) throw NoInternetException();
    if (throwOnGet != null) throw throwOnGet!;
    if (respond != null) response.data = respond!(recordedCalls.last);
    return response;
  }
}

class _Push extends Fake implements PushNotificationService {}

Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Api api;
  late FakeCacheService cache;
  late FakeConnectivityService connectivity;

  Future<void> signIn(String role, {bool withToken = true}) async {
    if (withToken) await cache.put(AppConstants.accessToken, 'token_$role');
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

  ProfileController profile() => Get.put(
    ProfileController(
      service: ProfileService(
        repository: ProfileRepository(apiService: api, cacheService: cache),
      ),
      connectivityService: connectivity,
    ),
  );

  AnnouncementRepository announcementRepo() =>
      AnnouncementRepository(apiService: api, cacheService: cache);

  AnnouncementController announcementController() => Get.put(
    AnnouncementController(
      service: AnnouncementServices(repository: announcementRepo()),
      connectivityService: connectivity,
    ),
  );

  setUp(() {
    Get.testMode = true;
    api = _Api();
    cache = FakeCacheService();
    connectivity = FakeConnectivityService();
  });
  tearDown(Get.reset);

  // ── Issue 1 ────────────────────────────────────────────────────────────────
  group('Issue 1: tree nodes are not hidden behind the bottom menu bar', () {
    const screenH = 800.0;

    for (final graphH in [300.0, 800.0, 2400.0]) {
      test('graph height $graphH: lowest node clears the nav bar', () {
        final insets = FamilyTreeGraph.verticalInsets(EdgeInsets.zero);
        final canvas = FamilyTreeGraph.canvasHeight(
          graphHeight: graphH,
          screenHeight: screenH,
          topInset: insets.top,
          bottomInset: insets.bottom,
        );
        final top = FamilyTreeGraph.graphTop(
          graphHeight: graphH,
          canvasHeight: canvas,
          topInset: insets.top,
          bottomInset: insets.bottom,
        );
        final graphBottom = top + graphH;

        // When scrolled to the very end, the viewport's bottom edge is the
        // canvas bottom; the nav bar covers the last minBottomBarHeight px.
        expect(
          canvas - graphBottom,
          greaterThanOrEqualTo(FamilyTreeGraph.minBottomBarHeight),
        );
        // And the top row is never under the floating search buttons.
        expect(top, greaterThanOrEqualTo(FamilyTreeGraph.topActionsHeight));
      });
    }

    test('uses the larger scaffold-provided bottom padding when present', () {
      final insets = FamilyTreeGraph.verticalInsets(
        const EdgeInsets.only(top: 47, bottom: 180),
      );
      expect(insets.bottom, 180 + FamilyTreeGraph.bottomBreathingRoom);
      expect(insets.top, 47 + FamilyTreeGraph.topActionsHeight);
    });
  });

  // ── Issue 2 ────────────────────────────────────────────────────────────────
  group('Issue 2: home screen never renders a blank void', () {
    test('all-zero / blank demographic data counts as "no chart data"', () {
      final model = DashboardModel.fromJson({
        'ageRange': [
          {'range': '01-20', 'count': 0, 'percentage': 0},
        ],
        'gender': [
          {'gender': '', 'count': 3},
          {'gender': 'male', 'count': 0},
        ],
        'commonNames': [
          {'name': '', 'percentage': 50},
        ],
        'employmentStatus': [
          {'status': 'employed', 'count': 0},
        ],
        'fieldOfWork': [],
        'educationLevel': [
          {'level': 'school', 'count': 0},
        ],
        'location': [
          {'location': 'Riyadh', 'percentage': 0},
        ],
      });
      expect(model.ageRangeChartData, isEmpty);
      expect(model.genderChartData, isEmpty);
      expect(model.commonNamesChartData, isEmpty);
      expect(model.locationChartData, isEmpty);
      expect(model.hasAnyChartData, isFalse);
    });

    test('real data still renders charts', () {
      final model = DashboardModel.fromJson({
        'ageRange': [
          {'range': '21-40', 'count': 4, 'percentage': 80},
          {'range': '41-60', 'count': 0, 'percentage': 0},
        ],
        'gender': [
          {'gender': 'Female', 'count': 2},
        ],
      });
      expect(model.ageRangeChartData.map((e) => e.label), ['21-40']);
      expect(model.genderChartData.single.value, 2);
      expect(model.hasAnyChartData, isTrue);
    });

    test('home content source shows an empty-state card for admins', () {
      final src = File(
        'lib/features/home/presentation/widgets/home_content.dart',
      ).readAsStringSync();
      expect(src, contains('hasAnyChartData'));
      expect(src, contains('HomeEmptyStateCard'));
    });
  });

  // ── Issue 3 ────────────────────────────────────────────────────────────────
  group('Issue 3: Date of Birth is gone and stays gone', () {
    test('no screen shows or edits a DOB field', () {
      final offenders = <String>[];
      final dir = Directory('lib/features');
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.dart')) continue;
        if (!f.path.contains('/presentation/')) continue;
        final src = f.readAsStringSync();
        if (RegExp(
          r'Date of birth|dateOfBirth|setSelectedDate',
          caseSensitive: false,
        ).hasMatch(src)) {
          offenders.add(f.path);
        }
      }
      expect(offenders, isEmpty, reason: 'DOB reintroduced in: $offenders');
    });

    test('edit-profile payload never sends dateOfBirth', () {
      final payload = UserModel(
        name: 'A',
        dateOfBirth: '2000-01-01T00:00:00.000Z',
      ).toMap();
      expect(payload.containsKey('dateOfBirth'), isFalse);
    });
  });

  // ── Issue 4 ────────────────────────────────────────────────────────────────
  group('Issue 4: unplaced users never appear in the directory', () {
    for (final role in ['user', 'admin', 'superAdmin']) {
      test('$role directory requests placed only', () async {
        await signIn(role);
        final c = profile();
        await _settle();
        expect(c.activeTreeJoinStatus, 'placed');
        final calls = api.recordedCalls.where(
          (call) => call.path == ApiConstants.usersProfile,
        );
        expect(calls, isNotEmpty);
        for (final call in calls) {
          expect(call.queryParameters?['treeJoinStatus'], 'placed');
          expect(call.queryParameters?['placedOnly'], true);
        }
      });
    }

    test('admin assign-to-tree picker asks explicitly for all', () async {
      await signIn('admin');
      final c = profile();
      await _settle();
      c.enterMotherTreePicker(placedOnly: false);
      expect(c.activeTreeJoinStatus, 'all');
      c.stopMotherTreePicker();
      expect(c.activeTreeJoinStatus, 'placed');
    });
  });

  // ── Issue 5 ────────────────────────────────────────────────────────────────
  group('Issue 5: "Requested announce" loads and empty is not an error', () {
    test('admin requested tab calls /announcement?status=pending', () async {
      await signIn('superAdmin');
      final c = announcementController();
      await _settle();
      expect(c.currentStatus, 'pending');
      final call = api.recordedCalls.firstWhere(
        (x) => x.path.startsWith(ApiConstants.announcementBase),
      );
      expect(Uri.parse(call.path).path, '/api/v1/announcement');
      expect(call.path, isNot(contains('my-requests')));
      expect(call.queryParameters?['status'], 'pending');
    });

    test('200 with data: [] and total 0 → loaded empty state', () async {
      await signIn('admin');
      api.respond = (_) => {
        'success': true,
        'meta': {'page': 1, 'limit': 10, 'total': 0, 'totalPage': 0},
        'data': [],
      };
      final c = announcementController();
      await _settle();
      expect(c.loadingState, LoadingState.loaded);
      expect(c.announcements, isEmpty);
    });

    test('prod-shaped response with one pending item is shown', () async {
      await signIn('superAdmin');
      api.respond = (_) => {
        'success': true,
        'meta': {'page': 1, 'limit': 10, 'total': 1, 'totalPage': 1},
        'data': [
          {'_id': 'p1', 'title': 'fghjnftghjfgth', 'status': 'pending'},
        ],
      };
      final c = announcementController();
      await _settle();
      expect(c.loadingState, LoadingState.loaded);
      expect(c.announcements.single.title, 'fghjnftghjfgth');
    });

    test('legacy 404 for "no rows" → empty state, not error', () async {
      await signIn('admin');
      api.throwOnGet = ResourceNotFoundException('No announcements found');
      final c = announcementController();
      await _settle();
      expect(c.loadingState, LoadingState.loaded);
      expect(c.announcements, isEmpty);
    });

    test('null / nested data shapes parse without throwing', () {
      expect(AnnouncementRepository.parseAnnouncementList({'data': null}),
          isEmpty);
      expect(
        AnnouncementRepository.parseAnnouncementList({
          'data': {
            'data': [
              {'_id': 'x'},
            ],
          },
        }).single.sId,
        'x',
      );
    });

    test('real server failure still shows error', () async {
      await signIn('admin');
      api.throwOnGet = ServerException('boom');
      final c = announcementController();
      await _settle();
      expect(c.loadingState, LoadingState.error);
    });

    test('offline with nothing cached → offline state (not error)', () async {
      await signIn('admin');
      connectivity.isConnected.value = false;
      final c = announcementController();
      await _settle();
      expect(c.loadingState, LoadingState.offline);
    });
  });

  // ── Issue 6 ────────────────────────────────────────────────────────────────
  group('Issue 6: "My requests" cache never leaks the public feed', () {
    test('legacy announcements_my key reads the personal cache', () async {
      await cache.put(ApiConstants.cacheAnnouncementFeed, [
        {'_id': 'public'},
      ]);
      await cache.put(ApiConstants.cacheMyAnnouncements, [
        {'_id': 'mine'},
      ]);
      final repo = announcementRepo();
      expect(repo.getCachedAnnouncements('announcements_my').single.sId,
          'mine');
      expect(repo.getCachedAnnouncements('my').single.sId, 'mine');
    });

    test('offline my-requests fallback never returns public items', () async {
      await cache.put(ApiConstants.cacheAnnouncementFeed, [
        {'_id': 'public'},
      ]);
      api.offline = true;
      final repo = announcementRepo();
      await expectLater(
        repo.getAnnouncements(1, 10, type: 'my'),
        throwsA(isA<NoInternetException>()),
      );
    });
  });

  // ── Issue 7 ────────────────────────────────────────────────────────────────
  group('Issue 7: no 401 at app launch before login', () {
    test('no token → ProfileController makes no API calls', () async {
      await signIn('user', withToken: false);
      profile();
      await _settle();
      connectivity.isConnected.value = false;
      connectivity.isConnected.value = true;
      await _settle();
      expect(api.recordedCalls, isEmpty);
    });

    test('with token → profile loads normally', () async {
      await signIn('user');
      profile();
      await _settle();
      expect(
        api.recordedCalls.any((c) => c.path == ApiConstants.userProfile),
        isTrue,
      );
    });
  });

  // ── Backend verification doc ───────────────────────────────────────────────
  group('Sign-up then Select Mother Tree page', () {
    test('create sends no motherTreeMemberId and never dateOfBirth', () async {
      final repo = AuthRepositoryImpl(apiService: api, cacheService: cache);
      await repo.register(
        name: 'A B',
        arabicName: 'أ ب',
        email: 'a@b.com',
        phone: '05',
        password: 'pw123456',
      );
      final call = api.callsMatching('POST', ApiConstants.register).single;
      // The mother tree is chosen after setup profile, via choose-mother.
      expect((call.data as Map).containsKey('motherTreeMemberId'), isFalse);
      expect((call.data as Map).containsKey('dateOfBirth'), isFalse);
      expect((call.data as Map).containsKey('role'), isFalse);
    });

    test('Select Mother Tree page loads branches with member ids', () async {
      await signIn('user', withToken: false);
      final c = profile();
      await c.loadMotherTrees();
      expect(c.motherTreeState, LoadingState.loaded);
      // The page selects `linkedMember`, which is the Member node id.
      expect(c.motherTreesData.first.linkedMember, 'm1');
    });
  });

  test('Select Mother Tree page: filters go to mother-trees, no directory calls',
      () async {
    await signIn('user', withToken: false);
    final c = profile();
    c.setGenderFilter('Female');
    c.setAgeFilter('21-40');
    c.setEmploymentFilter('Employed');
    c.setEducationFilter('University');
    await c.loadMotherTrees();

    final call = api.callsMatching('GET', ApiConstants.motherTrees).single;
    expect(call.queryParameters, {
      'gender': 'female',
      'employmentStatus': 'employed',
      'educationLevel': 'university',
      'age': '21-40',
    });
    // Nothing on this page should touch the member directory or /users/me.
    expect(api.hasCalled('GET', ApiConstants.usersProfile), isFalse);
    expect(api.hasCalled('GET', ApiConstants.userProfile), isFalse);

    c.resetFilters();
    await c.loadMotherTrees();
    expect(
      api.callsMatching('GET', ApiConstants.motherTrees).last.queryParameters,
      isNull,
    );
  });

  test('admin picker loads the user list without GET /users/me', () async {
    await signIn('admin');
    final c = profile();
    await _settle();
    api.recordedCalls.clear();
    await c.startMotherTreePicker(placedOnly: false);
    expect(api.hasCalled('GET', ApiConstants.usersProfile), isTrue);
    expect(api.hasCalled('GET', ApiConstants.userProfile), isFalse);
    c.stopMotherTreePicker();
  });

  test('mother branches parse the live {treeInfo, root, motherTrees} shape',
      () async {
    await signIn('user', withToken: false);
    api.respond = (call) => call.path == ApiConstants.motherTrees
        ? {
            'success': true,
            'data': {
              'treeInfo': {'_id': 't1', 'name': 'Mohammad'},
              'root': {'_id': 'root', 'label': 'Mohammad'},
              'motherTrees': [
                {
                  '_id': 'member_lulouah',
                  'label': 'Lulouah Alsubeaei',
                  'linkedUser': {
                    '_id': 'user_lulouah',
                    'name': 'Lulouah Alsubeaei',
                    'arabicName': 'لولوة السبيعي',
                  },
                },
              ],
            },
          }
        : null;
    final c = profile();
    await c.loadMotherTrees();
    final tree = c.motherTreesData.single;
    // The id sent to choose-mother must be the Member node id, not the linked user id.
    expect(tree.linkedMember, 'member_lulouah');
    expect(tree.name, 'Lulouah Alsubeaei');
  });

  group('Backend contract: decline admin', () {
    test('PATCH /super-admin/role/update/:id with {role: user}', () async {
      final repo = ProfileRepository(apiService: api, cacheService: cache);
      await repo.updateRole('u42', 'user');
      final call =
          api.callsMatching('PATCH', ApiConstants.updateRole('u42')).single;
      expect(call.data, {'role': 'user'});
      expect(call.path, isNot(contains('/requests/update/')));
    });
  });
}
