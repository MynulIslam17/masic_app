import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/features/notification/data/models/notification_model.dart';
import 'package:masic_generation/features/notification/domain/services/notification_services.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationServices _service;
  final ConnectivityService _connectivityService;

  static NotificationController get to => Get.find();

  NotificationController({
    required NotificationServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final RxList<NotificationModel> _notifications = <NotificationModel>[].obs;

  LoadingState get loadingState => _loadingState.value;
  List<NotificationModel> get notifications => _notifications;

  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;

  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  ScrollController? _scrollController;
  ScrollController? get scrollController => _scrollController;

  int get unreadCount =>
      _notifications.where((notification) => notification.isRead != true).length;

  @override
  void onInit() {
    super.onInit();
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
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
        hasMore) {
      _loadMore();
    }
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
        await _service.fetchNotifications(1, _limit);
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch notification error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected notification error: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;
    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newNotifications = await _service.fetchMoreNotifications(
        _currentPage,
        _limit,
      );

      if (newNotifications.isNotEmpty) {
        _notifications.addAll(newNotifications);
        if (newNotifications.length < _limit) _hasMore.value = false;
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Load more notification error: $e');
    } catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Unexpected load more error: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _loadFromCache() {
    _notifications.value = _service.getCachedNotifications();
  }

  @override
  Future<void> refresh() async => _loadData();

  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    super.onClose();
  }
}
