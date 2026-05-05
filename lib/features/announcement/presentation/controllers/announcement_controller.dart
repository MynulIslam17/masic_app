import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/announcement/domain/services/announcement_services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementController extends GetxController {
  final AnnouncementServices _service;
  final ConnectivityService _connectivityService;

  static AnnouncementController get to => Get.find();

  AnnouncementController({
    required AnnouncementServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;



  final searchController = TextEditingController();

  final _selectedImage = Rxn<File>();

  File? get selectedImage => _selectedImage.value;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;

  LoadingState get updateLoadingState => _updateLoadingState.value;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get createLoadingState => _createLoadingState.value;

  final RxList<AnnouncementModel> _announcements = <AnnouncementModel>[].obs;

  List<AnnouncementModel> get announcements => _announcements;

  // ─── Pagination (HomeController pattern) ──────────────────────────────────
  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;

  bool get isLoadingMore => _isLoadingMore.value;

  final RxBool _hasMore = true.obs;

  bool get hasMoreUsers => _hasMore.value && !_isLoadingMore.value;

  // ─── Scroll Controller ─────────────────────────────────────────────────────
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  @override
  void onInit() {
    super.onInit();
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    loadData();
  }

  void selectImage(XFile image) {
    _selectedImage.value = File(image.path);
  }

  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController == null) return;

    final position = _scrollController!.position;

    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMoreUsers) {
      /// loadMoreUsers();
    }
  }

  Future<void> loadData() async {
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
        await _service.fetchAnnouncements(_currentPage, _limit, search: searchController.text);
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

  Future<void> loadMore() async {
    if (_isLoadingMore.value || !hasMoreUsers) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newAnnouncements = await _service.fetchMoreAnnouncements(
        _currentPage,
        _limit,
      );

      if (newAnnouncements.isNotEmpty) {
        _announcements.addAll(newAnnouncements);
        if (newAnnouncements.length < _limit) {
          _hasMore.value = false;
        }
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Load more error: $e');
    } catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _loadFromCache() {
    _announcements.value = _service.getCachedAnnouncements();

    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   Announcements: ${_announcements.length}');
      }
      return true;
    }());
  }

  Future<void> retry() => loadData();

  @override
  Future<void> refresh() async {
    _currentPage = 1;
    _announcements.clear();
    await loadData();
  }

  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    super.onClose();
  }
}
