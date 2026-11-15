// Regression tests for:
//  * Announcement details showing "Announcement not found" although the API
//    returned it (super admin opening a Home / notification announcement).
//  * Request details "Request not found" when opened from a notification.
//  * 200 responses with null / nested `data` surfacing as "Failed to load".
//  * Logout native progress dialog.
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/constants/app_constants.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/api_response_parser.dart';
import 'package:masic_generation/core/services/push_notification_service.dart';
import 'package:masic_generation/core/widgets/native_loading_dialog.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/notification/data/repositories/notification_repository.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import 'package:masic_generation/features/request/data/repositories/request_repository.dart';
import 'package:masic_generation/features/request/domain/services/request_services.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';

import 'helpers/test_fakes.dart';

class _Api extends FakeApiService {
  dynamic Function(String path, Map<String, dynamic>? query)? respond;
  AppException? Function(String path)? fail;

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
    final error = fail?.call(path);
    if (error != null) throw error;
    if (respond != null) response.data = respond!(path, queryParameters);
    return response;
  }
}

class _Push extends Fake implements PushNotificationService {}

Future<void> _settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Map<String, dynamic> _ann(String id, {String status = 'approved'}) => {
  '_id': id,
  'title': 'Title $id',
  'description': 'Body $id',
  'status': status,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Api api;
  late FakeCacheService cache;
  late FakeConnectivityService connectivity;

  Future<void> signIn(String role) async {
    await cache.put(AppConstants.accessToken, 'token_$role');
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

  AnnouncementController announcements() => Get.put(
    AnnouncementController(
      service: AnnouncementServices(
        repository: AnnouncementRepository(apiService: api, cacheService: cache),
      ),
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

  group('Announcement details (super admin, Home / notification)', () {
    // Exactly the reported case: the pending list is empty (total 0) and the
    // announcement tapped on Home is an approved one.
    void backend() {
      api.respond = (path, query) {
        if (path.startsWith('${ApiConstants.announcementBase}/a1')) {
          return {'success': true, 'data': _ann('a1')};
        }
        return {
          'success': true,
          'meta': {'total': 0},
          'data': <dynamic>[],
        };
      };
    }

    test('loads by id instead of saying "not found"', () async {
      await signIn('superAdmin');
      backend();
      final c = announcements();
      await _settle();
      expect(c.announcements, isEmpty, reason: 'pending list is empty');
      expect(c.findAnnouncement('a1'), isNull);

      await c.loadAnnouncementDetails('a1');

      expect(api.hasCalled('GET', '${ApiConstants.announcementBase}/a1'), isTrue);
      expect(c.findAnnouncement('a1')?.title, 'Title a1');
      expect(c.isMissing('a1'), isFalse);
      expect(c.detailState('a1'), LoadingState.loaded);
    });

    test('shows a cached Home-feed copy immediately', () async {
      await signIn('superAdmin');
      backend();
      await cache.put(ApiConstants.cacheAnnouncementFeed, [_ann('a1')]);
      final c = announcements();
      await _settle();
      // Available before any detail request completes.
      expect(c.findAnnouncement('a1')?.title, 'Title a1');
    });

    test('404 means the announcement was deleted', () async {
      await signIn('superAdmin');
      backend();
      api.fail = (path) => path.endsWith('/gone')
          ? ResourceNotFoundException('API Not Found !!')
          : null;
      final c = announcements();
      await _settle();
      await c.loadAnnouncementDetails('gone');
      expect(c.isMissing('gone'), isTrue);
      expect(c.findAnnouncement('gone'), isNull);
    });

    test('server error with no copy -> retryable error, not "not found"',
        () async {
      await signIn('superAdmin');
      backend();
      api.fail = (path) =>
          path.endsWith('/a1') ? ServerException('boom') : null;
      final c = announcements();
      await _settle();
      await c.loadAnnouncementDetails('a1');
      expect(c.detailState('a1'), LoadingState.error);
      expect(c.isMissing('a1'), isFalse);

      api.fail = null; // retry succeeds
      await c.loadAnnouncementDetails('a1');
      expect(c.findAnnouncement('a1')?.title, 'Title a1');
    });

    test('offline with no copy -> offline state', () async {
      await signIn('superAdmin');
      backend();
      final c = announcements();
      await _settle();
      connectivity.isConnected.value = false;
      await c.loadAnnouncementDetails('a1');
      expect(c.detailState('a1'), LoadingState.offline);
    });
  });

  group('parseAnnouncementDetail', () {
    test('accepts the live shape {data: {...}}', () {
      expect(
        AnnouncementRepository.parseAnnouncementDetail(
          {'success': true, 'data': _ann('x')},
          'x',
        )?.sId,
        'x',
      );
    });
    test('accepts nested and list shapes, never returns a wrong item', () {
      expect(
        AnnouncementRepository.parseAnnouncementDetail({
          'data': {'data': _ann('x')},
        }, 'x')?.sId,
        'x',
      );
      expect(
        AnnouncementRepository.parseAnnouncementDetail({
          'data': [_ann('y'), _ann('x')],
        }, 'x')?.sId,
        'x',
      );
      expect(
        AnnouncementRepository.parseAnnouncementDetail({
          'data': [_ann('y')],
        }, 'x'),
        isNull,
      );
      expect(
        AnnouncementRepository.parseAnnouncementDetail({'data': null}, 'x'),
        isNull,
      );
    });
  });

  group('Request details (no GET /request/:id on the backend)', () {
    RequestController requests() => Get.put(
      RequestController(
        service: RequestServices(
          repository: RequestRepository(apiService: api, cacheService: cache),
        ),
        connectivityService: connectivity,
      ),
    );

    test('a request on a later page is located, not "Request not found"',
        () async {
      api.respond = (path, query) {
        final page = query?['page'] ?? 1;
        final limit = query?['limit'] ?? 10;
        if (page == 1 && limit == 10) {
          return {'data': [{'_id': 'r1', 'status': 'pending'}]};
        }
        if (page == 1) {
          return {
            'data': List.generate(
              limit as int,
              (i) => {'_id': 'p1_$i', 'status': 'pending'},
            ),
          };
        }
        return {
          'data': [{'_id': 'r99', 'status': 'pending', 'jobSpec': 'Engineer'}],
        };
      };
      final c = requests();
      await _settle();
      expect(c.findRequest('r99'), isNull);

      await c.loadRequestDetails('r99');
      expect(c.findRequest('r99')?.jobSpec, 'Engineer');
      expect(c.detailState('r99'), LoadingState.loaded);
    });

    test('an unknown id ends as "no longer available", not loading forever',
        () async {
      api.respond = (path, query) => {'data': <dynamic>[]};
      final c = requests();
      await _settle();
      await c.loadRequestDetails('nope');
      expect(c.findRequest('nope'), isNull);
      expect(c.detailState('nope'), LoadingState.loaded);
    });
  });

  group('200 responses never become "Failed to load"', () {
    test('ApiResponseParser handles null, nested and bare lists', () {
      expect(ApiResponseParser.dataList({'data': null}), isEmpty);
      expect(ApiResponseParser.dataList({'data': <dynamic>[]}), isEmpty);
      expect(
        ApiResponseParser.dataList({
          'data': {
            'data': [{'_id': '1'}],
          },
        }).single['_id'],
        '1',
      );
      expect(
        ApiResponseParser.dataList([{'_id': '2'}]).single['_id'],
        '2',
      );
      expect(ApiResponseParser.dataList('oops'), isEmpty);
    });

    test('notifications: data:null -> empty list, not an exception', () async {
      api.respond = (path, query) => {'success': true, 'data': null};
      final repo = NotificationRepository(apiService: api, cacheService: cache);
      expect(await repo.getNotifications(1, 10), isEmpty);
    });

    test('polls: 404 for "no rows" -> empty list', () async {
      api.fail = (path) => ResourceNotFoundException('none');
      final repo = PollRepository(apiService: api, cacheService: cache);
      expect(await repo.getPolls(1, 10), isEmpty);
    });

    test('requests: nested data is parsed', () async {
      api.respond = (path, query) => {
        'data': {
          'data': [{'_id': 'r1'}],
        },
      };
      final repo = RequestRepository(apiService: api, cacheService: cache);
      expect((await repo.fetchRequests()).single.sId, 'r1');
    });
  });

  group('Logout native progress dialog', () {
    Future<void> pump(WidgetTester tester, TargetPlatform platform) async {
      Get.reset();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(platform: platform),
          home: const Scaffold(body: Text('home')),
        ),
      );
    }

    testWidgets('iOS shows a Cupertino spinner and blocks dismissal',
        (tester) async {
      await pump(tester, TargetPlatform.iOS);
      NativeLoadingDialog.show(message: 'Logging out...');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      expect(find.text('Logging out...'), findsOneWidget);

      // Tapping the barrier does not close it.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Logging out...'), findsOneWidget);

      NativeLoadingDialog.hide();
      await tester.pumpAndSettle();
      expect(find.text('Logging out...'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('Android shows a Material progress dialog', (tester) async {
      await pump(tester, TargetPlatform.android);
      NativeLoadingDialog.show(message: 'Logging out...');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      NativeLoadingDialog.hide();
      await tester.pumpAndSettle();
    });
  });
}
