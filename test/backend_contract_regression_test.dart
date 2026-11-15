import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/announcement/presentation/widgets/announcement_decline_dialog.dart';
import 'package:masic_generation/features/profile/setting/setting_screen.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/announcement/presentation/screens/comon/announcements_details_screen.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/profile/presentation/widgets/user_card.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'helpers/test_fakes.dart';

class _Auth extends GetxController implements AuthController {
  _Auth(this.role);
  final String role;
  @override
  bool isAdmin() => AuthController.isAdminRole(role);
  @override
  bool isSuperAdmin() => AuthController.isSuperAdminRole(role);
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Profile extends GetxController implements ProfileController {
  _Profile(String role) : current = UserModel(sId: 'caller', role: role).obs;
  final Rx<UserModel> current;
  @override
  Future<void> refresh({bool showLoader = false}) async {}
  @override
  UserModel? get userData => current.value;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Announcements extends GetxController implements AnnouncementController {
  final items = <AnnouncementModel>[].obs;
  @override
  Future<void> refresh() async {}
  @override
  List<AnnouncementModel> get announcements => items;
  final loading = LoadingState.initial.obs;
  @override
  LoadingState get updateLoadingState => loading.value;
  @override
  LoadingState get deleteLoadingState => LoadingState.initial;
  @override
  Future<void> loadAnnouncementDetails(String id) async {}
  @override
  AnnouncementModel? findAnnouncement(String id) =>
      items.firstWhereOrNull((e) => e.sId == id);
  @override
  bool isMissing(String id) => false;
  @override
  LoadingState detailState(String id) => LoadingState.loaded;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _OfflineApi extends FakeApiService {
  @override
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async => throw NoInternetException();
}

class _StatusController extends AnnouncementController {
  _StatusController(FakeApiService api)
    : super(
        service: AnnouncementServices(
          repository: AnnouncementRepository(
            apiService: api,
            cacheService: FakeCacheService(),
          ),
        ),
        connectivityService: FakeConnectivityService(),
      );

  @override
  Future<void> refresh() async {}
}

Future<void> _mount(WidgetTester tester, Widget widget) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) => GetMaterialApp(home: Scaffold(body: widget)),
    ),
  );
  await tester.pumpAndSettle();
}

void _register(String role) {
  Get.put<ProfileController>(_Profile(role));
  Get.put<AuthController>(_Auth(role));
  Get.put<TranslationController>(TranslationController());
}

Future<void> _details(
  WidgetTester tester, {
  String status = 'declined',
  String? declineReason = 'Please provide the event date',
}) async {
  final controller = _Announcements();
  controller.items.add(
    AnnouncementModel(
      sId: 'a1',
      title: 'Announcement',
      description: 'Details',
      status: status,
      declineReason: declineReason,
      createdBy: CreatedBy.fromJson({'_id': 'caller'}),
    ),
  );
  Get.put<AnnouncementController>(controller);
  await _mount(tester, const SizedBox());
  Get.to(() => const AnnouncementsDetailsScreen(), arguments: 'a1');
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() {
    Get.reset();
  });

  test('approval sends documented status payload', () async {
    final api = FakeApiService();
    final repo = AnnouncementRepository(
      apiService: api,
      cacheService: FakeCacheService(),
    );
    await repo.updateStatus('a1', 'approved');
    expect(api.recordedCalls.single.method, 'PATCH');
    expect(api.recordedCalls.single.path, '/api/v1/announcement/a1');
    expect(api.recordedCalls.single.data, {'status': 'approved'});
  });
  test('announcement rejection without a reason remains valid', () async {
    final api = FakeApiService();
    final repo = AnnouncementRepository(
      apiService: api,
      cacheService: FakeCacheService(),
    );
    await repo.updateStatus('a1', 'declined');
    expect(api.recordedCalls.single.data, {'status': 'declined'});
  });
  testWidgets('returned decline reason is visible to request owner', (
    tester,
  ) async {
    _register('user');
    await _details(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Please provide the event date'), findsOneWidget);
  });
  testWidgets('admin rejection dialog offers a reason input', (tester) async {
    _register('admin');
    await _details(tester, status: 'pending');
    expect(find.text('Rejected'), findsOneWidget);
    await tester.tap(find.text('Rejected'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
  });
  for (final callerRole in ['admin', 'superAdmin']) {
    testWidgets('$callerRole cannot offer deletion of protected superAdmin', (
      tester,
    ) async {
      _register(callerRole);
      await _mount(
        tester,
        UserCard(
          user: UserModel(
            sId: 'protected',
            name: 'Protected',
            role: 'superAdmin',
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Delete Account'), findsNothing);
    });
  }
  testWidgets('admin can offer deletion of a regular user', (tester) async {
    _register('admin');
    await _mount(
      tester,
      UserCard(
        user: UserModel(sId: 'normal', name: 'Normal', role: 'user'),
      ),
    );
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Delete Account'), findsOneWidget);
  });
  test('explicit in_progress request preserves approved cache', () async {
    final api = FakeApiService();
    final cache = FakeCacheService();
    final repo = AnnouncementRepository(apiService: api, cacheService: cache);
    api.customResponses[ApiConstants.announcements(1, 10)] = {
      'data': [
        {'_id': 'approved', 'status': 'approved'},
      ],
    };
    await repo.getAnnouncements(1, 10, status: 'approved');
    api.customResponses[ApiConstants.announcements(1, 10)] = {
      'data': [
        {'_id': 'progress', 'status': 'in_progress'},
      ],
    };
    await repo.getAnnouncements(1, 10, status: 'in_progress');
    expect(repo.getCachedAnnouncements('in_progress').single.sId, 'progress');
    expect(repo.getCachedAnnouncements('approved').single.sId, 'approved');
  });
  test('in_progress offline fallback does not return approved cache', () async {
    final cache = FakeCacheService();
    await cache.put(ApiConstants.cacheApprovedAnnouncements, [
      {'_id': 'approved', 'status': 'approved'},
    ]);
    final repo = AnnouncementRepository(
      apiService: _OfflineApi(),
      cacheService: cache,
    );
    await expectLater(
      repo.getAnnouncements(1, 10, status: 'in_progress'),
      throwsA(isA<NoInternetException>()),
    );
  });
  test('placedOnly bool encodes as backend-required URL string true', () {
    final request = dio.RequestOptions(
      path: '/api/v1/users',
      queryParameters: {'placedOnly': true},
    );
    expect(request.uri.queryParameters['placedOnly'], 'true');
  });

  test(
    'decline reason passes through service and is trimmed in the payload',
    () async {
      final api = FakeApiService();
      final service = AnnouncementServices(
        repository: AnnouncementRepository(
          apiService: api,
          cacheService: FakeCacheService(),
        ),
      );
      await service.updateStatus(
        'a1',
        'declined',
        declineReason: '  Missing date  ',
      );
      expect(api.recordedCalls.single.data, {
        'status': 'declined',
        'declineReason': 'Missing date',
      });
    },
  );

  for (final reason in ['', '   ', null]) {
    test(
      'blank reason ($reason) does not block announcement decline',
      () async {
        final api = FakeApiService();
        final repo = AnnouncementRepository(
          apiService: api,
          cacheService: FakeCacheService(),
        );
        await repo.updateStatus('a1', 'declined', declineReason: reason);
        expect(api.recordedCalls.single.data, {'status': 'declined'});
      },
    );
  }

  test('approving does not send a stale decline reason', () async {
    final api = FakeApiService();
    final repo = AnnouncementRepository(
      apiService: api,
      cacheService: FakeCacheService(),
    );
    await repo.updateStatus('a1', 'approved', declineReason: 'Old reason');
    expect(api.recordedCalls.single.data, {'status': 'approved'});
  });

  for (final reason in ['', 'Please provide the event date']) {
    testWidgets(
      'decline dialog submits optional reason ($reason) through actual controller',
      (tester) async {
        _register('admin');
        final api = FakeApiService();
        final controller = _StatusController(api);
        addTearDown(controller.onClose);
        await _mount(tester, const SizedBox());
        Get.dialog(
          AnnouncementDeclineDialog(
            announcementId: 'a1',
            controller: controller,
          ),
        );
        await tester.pumpAndSettle();
        if (reason.isNotEmpty) {
          await tester.enterText(find.byType(TextField), reason);
        }
        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(api.recordedCalls.single.method, 'PATCH');
        expect(api.recordedCalls.single.data, {
          'status': 'declined',
          if (reason.isNotEmpty) 'declineReason': reason,
        });
        expect(find.byType(AnnouncementDeclineDialog), findsNothing);
      },
    );
  }

  testWidgets('cancelling decline makes no API call', (tester) async {
    _register('admin');
    final api = FakeApiService();
    final controller = _StatusController(api);
    addTearDown(controller.onClose);
    await _mount(tester, const SizedBox());
    Get.dialog(
      AnnouncementDeclineDialog(announcementId: 'a1', controller: controller),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(api.recordedCalls, isEmpty);
    expect(find.byType(AnnouncementDeclineDialog), findsNothing);
  });

  for (final role in ['superAdmin', 'admin', 'user']) {
    testWidgets('$role personal settings honor account deletion protection', (
      tester,
    ) async {
      _register(role);
      await _mount(tester, const SettingScreen());
      expect(tester.takeException(), isNull);
      expect(
        find.text('Delete Account'),
        role == 'superAdmin' ? findsNothing : findsOneWidget,
      );
    });
  }

  test(
    'default feed preserves both statuses and uses a separate cache',
    () async {
      final api = FakeApiService();
      final cache = FakeCacheService();
      final repo = AnnouncementRepository(apiService: api, cacheService: cache);
      await cache.put(ApiConstants.cacheApprovedAnnouncements, [
        {'_id': 'only-approved', 'status': 'approved'},
      ]);
      await cache.put(ApiConstants.cacheInProgressAnnouncements, [
        {'_id': 'only-ongoing', 'status': 'in_progress'},
      ]);
      api.customResponses[ApiConstants.announcements(1, 10)] = {
        'data': [
          {'_id': 'approved', 'status': 'approved'},
          {'_id': 'ongoing', 'status': 'in_progress'},
        ],
      };
      final result = await repo.getAnnouncements(1, 10);
      expect(
        api.recordedCalls.single.queryParameters?.containsKey('status'),
        false,
      );
      expect(result.map((a) => a.status), ['approved', 'in_progress']);
      expect(repo.getCachedAnnouncements('').map((a) => a.sId), [
        'approved',
        'ongoing',
      ]);
      expect(
        repo.getCachedAnnouncements('approved').single.sId,
        'only-approved',
      );
      expect(
        repo.getCachedAnnouncements('in_progress').single.sId,
        'only-ongoing',
      );
      final offline = AnnouncementRepository(
        apiService: _OfflineApi(),
        cacheService: cache,
      );
      expect((await offline.getAnnouncements(1, 10)).map((a) => a.sId), [
        'approved',
        'ongoing',
      ]);
    },
  );

  for (final reason in [null, '', '   ']) {
    testWidgets(
      'declined announcement with no meaningful reason ($reason) has no empty reason section',
      (tester) async {
        _register('user');
        await _details(tester, declineReason: reason);
        expect(tester.takeException(), isNull);
        expect(find.text('Announcement'), findsOneWidget);
        expect(find.text('Decline reason'), findsNothing);
      },
    );
  }
}
