import 'package:masic_generation/core/helpers/app_log.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/data/models/create_request_model.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/banner/data/models/banner_model.dart';
import 'package:masic_generation/features/banner/domain/services/banner_services.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BannerController extends GetxController {
  final BannerServices _service;
  final ConnectivityService _connectivityService;

  static BannerController get to => Get.find();

  BannerController({
    required BannerServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  final _selectedImage = Rxn<File>();

  File? get selectedImage => _selectedImage.value;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState>  _deleteLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;

  final RxList<BannerModel> _banners = <BannerModel>[].obs;

  List<BannerModel> get banners => _banners;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<void> selectImage(XFile image) async {
    _selectedImage.value = File(image.path);
    await createBanner();
  }

  Future<void> _loadData() async {
    try {
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value =
            _banners.isEmpty ? LoadingState.loading : LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (_banners.isEmpty) {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      try {
        await _service.fetchBanner(1, 10);
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache || _banners.isEmpty) {
          _loadingState.value = LoadingState.error;
        }
        if (kDebugMode) AppLog.error('Banner', 'Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache() && _banners.isNotEmpty) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) AppLog.error('Banner', 'Unexpected error: ${e.toString()}');
    }
  }

  void _loadFromCache() {
    _banners.value = _service.getCachedBanner();

    assert(() {
      if (kDebugMode) {
        AppLog.info('Banner', 'Loaded from cache → Banner: ${_banners.length}');
      }
      return true;
    }());
  }

  @override
  Future<void> refresh() async => _loadData();

  Future<void> createBanner() async {
    if (_selectedImage.value == null) return;
    ToastMessageHelper.show('Please wait...');

    try {
      await _service.createBanner(selectedImage!);
      _selectedImage.value = null;
      ToastMessageHelper.show('Banner uploaded successfully');
      await _loadData();
    } on AppException catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) {
        AppLog.error('Banner', 'Create banner error: $e');
      }
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    _deleteLoadingState.value = LoadingState.loading;
    try {
      await _service.deleteBanner(bannerId);

      await _loadData();
      _deleteLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
    } on AppException catch (e) {
      _deleteLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) {
        AppLog.error('Banner', 'Delete banner error: $e');
      }
    }
  }
}
