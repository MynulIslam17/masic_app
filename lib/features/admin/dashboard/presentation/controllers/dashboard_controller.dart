import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/admin/dashboard/data/models/dashboard_model.dart';
import 'package:flutter_task/features/admin/dashboard/domain/services/dashboard_service.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final DashboardService _service;
  final ConnectivityService _connectivityService;

  static DashboardController get to => Get.find();

  DashboardController({
    required DashboardService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  final _dashboard = Rxn<DashboardModel>();

  DashboardModel? get dashboard => _dashboard.value;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) return;

      try {
        await _service.fetchDashboard();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) {
          _loadingState.value = LoadingState.error;
        }
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _loadFromCache() {
    _dashboard.value = _service.getCachedDashboard();

    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   Announcements: ${_dashboard.value}');
      }
      return true;
    }());
  }



  @override
  Future<void> refresh() async {
    await _loadData();
  }
}
