import 'package:masic_generation/core/helpers/app_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/features/privacy/domain/services/privacy_services.dart';
import 'package:get/get.dart';

class PrivacyController extends GetxController {
  final PrivacyServices _service;
  final ConnectivityService _connectivityService;

  static PrivacyController get to => Get.find();

  PrivacyController({
    required PrivacyServices service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get updateLoadingState => _updateLoadingState.value;

  // ─── Data ──────────────────────────────────────────────────────────────────
  final RxMap<String, String> _descriptions = <String, String>{}.obs;
  final RxString _activeKey = 'privacy'.obs;

  String get description => _descriptions[_activeKey.value] ?? '';

  void setActiveKey(String key) => _activeKey.value = key;

  // ─── TextField controller ──────────────────────────────────────────────────
  final desController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  @override
  void onClose() {
    desController.dispose();
    super.onClose();
  }

  // ─── Load ──────────────────────────────────────────────────────────────────
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
        await _service.fetchPrivacy();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) AppLog.error('Privacy', 'Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) AppLog.error('Privacy', 'Unexpected error: $e');
    }
  }

  void _loadFromCache() {
    for (final key in ['privacy', 'about', 'terms']) {
      final cached = _service.getCached(key);
      if (cached != null) _descriptions[key] = cached;
    }

    assert(() {
      if (kDebugMode) {
        for (final key in ['privacy', 'about', 'terms']) {
          AppLog.info('Privacy', 'Loaded from cache → $key: ${_descriptions[key]?.length ?? 0} chars');
        }
      }
      return true;
    }());
  }

  @override
  Future<void> refresh() async => _loadData();

  // ─── Update ────────────────────────────────────────────────────────────────
  Future<void> updatePrivacy(String key) async {
    try {
      _updateLoadingState.value = LoadingState.loading;
      await _service.updatePrivacy(key, desController.text.trim());
      _updateLoadingState.value = LoadingState.loaded;
      desController.clear();
      await _loadData();
    } on AppException catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) AppLog.error('Privacy', 'Update error: $e');
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      if (kDebugMode) AppLog.error('Privacy', 'Update error: $e');
    }
  }
}