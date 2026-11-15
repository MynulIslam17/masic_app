import 'package:masic_generation/core/helpers/app_log.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/core/services/search_service.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/data/models/create_request_model.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/home/presentation/controllers/home_controller.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
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

  late final SearchService<AnnouncementModel> search;

  final RxList<File> _selectedImages = <File>[].obs;

  List<File> get selectedImages => _selectedImages;

  File? get selectedImage =>
      _selectedImages.isNotEmpty ? _selectedImages.first : null;

  // ─── Tab ───────────────────────────────────────────────────────────────────
  final RxInt selectedTab = 0.obs;

  /// Exposed for tests: the query the current tab sends.
  @visibleForTesting
  String get currentType => _currentType;
  @visibleForTesting
  String? get currentStatus => _currentStatus;

  String get _currentType => selectedTab.value == 1 ? 'my' : '';
  String? get _currentStatus {
    if (selectedTab.value == 1) return null;
    return AuthController.to.isAdmin() ? 'pending' : null;
  }

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get updateLoadingState => _updateLoadingState.value;
  LoadingState get createLoadingState => _createLoadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;

  final titleTEController = TextEditingController();
  final decTEController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxList<AnnouncementModel> _announcements = <AnnouncementModel>[].obs;

  List<AnnouncementModel> get announcements => _announcements;

  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;
  bool _isRefreshing = false;

  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  ScrollController? _scrollController;
  ScrollController? get scrollController => _scrollController;

  @override
  void onInit() {
    super.onInit();
    search = SearchService(fetcher: _fetchSearch);
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    ever(selectedTab, (_) => refresh());
    _loadData();
  }

  void onTabChanged(int index) {
    if (selectedTab.value == index) return;
    search.clear();
    searchController.clear();
    selectedTab.value = index;
  }

  void selectImage(XFile image) {
    if (_selectedImages.length >= 10) {
      ToastMessageHelper.show('Maximum 10 images allowed');
      return;
    }
    _selectedImages.add(File(image.path));
  }

  void addImages(List<XFile> images) {
    final remaining = 10 - _selectedImages.length;
    if (remaining <= 0) {
      ToastMessageHelper.show('Maximum 10 images allowed');
      return;
    }
    final toAdd = images.take(remaining).map((x) => File(x.path)).toList();
    _selectedImages.addAll(toAdd);
    if (images.length > remaining) {
      ToastMessageHelper.show(
        'Only $remaining more image(s) could be added (max 10)',
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
    }
  }

  void clearImages() {
    _selectedImages.clear();
  }

  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController == null || _isRefreshing) return;
    final position = _scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore.value = true;
    _isLoadingMore.value = false;
  }

  String get _currentCacheKey =>
      _currentType.isNotEmpty ? _currentType : (_currentStatus ?? '');

  void _syncHasMoreAfterFirstPage() {
    _hasMore.value = _announcements.length >= _limit;
  }

  Future<void> _loadData() async {
    final cacheKey = _currentCacheKey;
    try {
      final type = _currentType;
      final status = _currentStatus;
      final hasCache = _service.hasCache(cacheKey);
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        _loadingState.value = _announcements.isEmpty
            ? LoadingState.loading
            : LoadingState.loaded;
      } else {
        _announcements.clear();
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (_announcements.isEmpty) {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      try {
        final query = searchController.text.trim();
        final fetched = await _service.fetchAnnouncements(
          1,
          _limit,
          search: query,
          type: type,
          status: status,
        );
        if (cacheKey != _currentCacheKey) return;
        // Search results are not cached, so show them directly; otherwise the
        // freshly cached first page is the source of truth. An empty page is
        // a valid result (empty state), never an error.
        if (query.isNotEmpty) {
          _announcements.value = fetched;
        } else {
          _loadFromCache();
        }
        _currentPage = 1;
        _syncHasMoreAfterFirstPage();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (cacheKey != _currentCacheKey) return;
        if (_announcements.isEmpty) {
          _loadingState.value = e is NoInternetException
              ? LoadingState.offline
              : LoadingState.error;
        } else {
          _loadingState.value = LoadingState.loaded;
        }
        if (kDebugMode) {
          AppLog.error('Announcement', 
            'Announcement fetch error (type=$type status=$status '
            'admin=${AuthController.to.isAdmin()}): $e',
          );
        }
      }
    } catch (e) {
      if (cacheKey != _currentCacheKey) return;
      if (_service.hasCache(_currentCacheKey) && _announcements.isNotEmpty) {
        _loadFromCache();
        _currentPage = 1;
        _syncHasMoreAfterFirstPage();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) AppLog.error('Announcement', 'Unexpected error: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isRefreshing || _isLoadingMore.value || !hasMore) return;
    final cacheKey = _currentCacheKey;
    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newAnnouncements = await _service.fetchMoreAnnouncements(
        _currentPage,
        _limit,
        type: _currentType,
        status: _currentStatus,
        search: searchController.text,
      );
      if (cacheKey != _currentCacheKey) return;

      if (newAnnouncements.isNotEmpty) {
        _loadFromCache();
        if (newAnnouncements.length < _limit) _hasMore.value = false;
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      if (cacheKey != _currentCacheKey) return;
      _currentPage--;
      if (kDebugMode) AppLog.error('Announcement', 'Load more error: $e');
    } catch (e) {
      if (cacheKey != _currentCacheKey) return;
      _currentPage--;
      if (kDebugMode) AppLog.error('Announcement', 'Unexpected error: $e');
    } finally {
      if (cacheKey == _currentCacheKey) _isLoadingMore.value = false;
    }
  }

  void _loadFromCache() {
    _announcements.value = _service.getCachedAnnouncements(_currentCacheKey);
  }

  Future<List<AnnouncementModel>> _fetchSearch(String query) async {
    final cacheKey = _currentCacheKey;
    final fromCache = _service
        .getCachedAnnouncements(_currentCacheKey)
        .where(
          (a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .toList();
    if (fromCache.isNotEmpty) return fromCache;

    if (!_connectivityService.isConnected.value) return [];

    final results = await _service.fetchAnnouncements(
      1,
      20,
      search: query,
      type: _currentType,
      status: _currentStatus,
    );
    if (cacheKey != _currentCacheKey) return [];
    return results
        .where(
          (a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false,
        )
        .toList();
  }

  // ─── Details ───────────────────────────────────────────────────────────────
  /// Items fetched (or updated) for the details screen, keyed by id. The
  /// details screen must not depend on whichever tab list is loaded: a super
  /// admin's list is "pending", so anything opened from Home / notifications
  /// (or just approved) is not in it.
  final RxMap<String, AnnouncementModel> _details =
      <String, AnnouncementModel>{}.obs;
  final RxMap<String, LoadingState> _detailStates =
      <String, LoadingState>{}.obs;

  final RxSet<String> _missing = <String>{}.obs;

  LoadingState detailState(String id) =>
      _detailStates[id] ?? LoadingState.initial;

  /// The backend answered 404 / the item was deleted.
  bool isMissing(String id) => _missing.contains(id);

  /// Best known copy: fresh details, current tab, Home feed, then any cache.
  AnnouncementModel? findAnnouncement(String id) {
    if (id.isEmpty) return null;
    final fetched = _details[id];
    if (fetched != null) return fetched;
    final inList = _announcements.firstWhereOrNull((e) => e.sId == id);
    if (inList != null) return inList;
    if (Get.isRegistered<HomeController>()) {
      final onHome = Get.find<HomeController>().announcements.firstWhereOrNull(
        (e) => e.sId == id,
      );
      if (onHome != null) return onHome;
    }
    return _service.findCachedAnnouncement(id);
  }

  /// Shows a known copy immediately, then refreshes it from `GET /:id`.
  Future<void> loadAnnouncementDetails(String id) async {
    if (id.isEmpty) {
      _detailStates[id] = LoadingState.error;
      return;
    }
    final known = findAnnouncement(id);
    if (known != null) _details[id] = known;
    if (!_connectivityService.isConnected.value) {
      _detailStates[id] =
          known != null ? LoadingState.loaded : LoadingState.offline;
      return;
    }
    if (known == null) _detailStates[id] = LoadingState.loading;
    try {
      final fresh = await _service.fetchAnnouncementById(id);
      if (fresh != null) {
        _missing.remove(id);
        _details[id] = fresh;
      } else if (known == null) {
        // 404 and nothing known: the item really is gone (deleted).
        _missing.add(id);
      }
      _detailStates[id] = LoadingState.loaded;
    } on AppException catch (e) {
      _detailStates[id] = known != null
          ? LoadingState.loaded
          : (e is NoInternetException ? LoadingState.offline : LoadingState.error);
      if (kDebugMode) AppLog.error('Announcement', 'Announcement details error ($id): $e');
    }
  }

  void _patchDetail(String id, {String? status, String? declineReason}) {
    final current = findAnnouncement(id);
    if (current == null) return;
    final json = current.toJson();
    if (status != null) json['status'] = status;
    if (declineReason != null) json['declineReason'] = declineReason;
    _details[id] = AnnouncementModel.fromJson(json);
  }

  @override
  Future<void> refresh() async {
    _resetPagination();
    _isRefreshing = true;
    if (_scrollController?.hasClients ?? false) {
      _scrollController!.jumpTo(0);
    }
    try {
      await _loadData();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> createAnnouncement() async {
    if (!formKey.currentState!.validate()) return;
    _createLoadingState.value = LoadingState.loading;
    try {
      final users = ProfileController.to.selectedUserIds;
      await _service.createAnnouncement(
        _selectedImages,
        CreateRequestModel(
          title: titleTEController.text.trim(),
          description: decTEController.text.trim(),
          targetUsers: users.isEmpty ? null : users,
        ),
      );
      _createLoadingState.value = LoadingState.loaded;
      if (users.isNotEmpty) Get.back(canPop: true);
      Get.back(canPop: true);
      titleTEController.clear();
      decTEController.clear();
      _selectedImages.clear();
      users.clear();
      ToastMessageHelper.show('Created! Pending admin approval.');
    } on AppException catch (e) {
      _createLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) AppLog.error('Announcement', 'Create announcement error: $e');
    }
  }

  Future<void> updateStatus(
    String announcementId,
    String status, {
    String? declineReason,
  }) async {
    if (_updateLoadingState.value == LoadingState.loading) return;
    _updateLoadingState.value = LoadingState.loading;
    try {
      await _service.updateStatus(
        announcementId,
        status,
        declineReason: declineReason,
      );
      _updateLoadingState.value = LoadingState.loaded;
      _patchDetail(announcementId, status: status, declineReason: declineReason);
      refresh();
      Get.back(canPop: true);
    } on AppException catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) AppLog.error('Announcement', 'Update status error: $e');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    _deleteLoadingState.value = LoadingState.loading;
    try {
      await _service.deleteAnnouncement(announcementId);
      _deleteLoadingState.value = LoadingState.loaded;
      _details.remove(announcementId);
      _missing.add(announcementId);
      refresh();
      Get.back(canPop: true);
    } on AppException catch (e) {
      _deleteLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) AppLog.error('Announcement', 'Delete announcement error: $e');
    }
  }

  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    titleTEController.dispose();
    decTEController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
