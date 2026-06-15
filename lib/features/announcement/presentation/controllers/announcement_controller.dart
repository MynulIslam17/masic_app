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
  })  : _service = service,
        _connectivityService = connectivityService;

  final searchController = TextEditingController();

  late final SearchService<AnnouncementModel> search;


  final _selectedImage = Rxn<File>();

  File? get selectedImage => _selectedImage.value;

  // ─── Tab ───────────────────────────────────────────────────────────────────
  final RxInt selectedTab = 0.obs;

  String get _currentType => selectedTab.value == 1 ? 'my' : '';

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
    selectedTab.value = index;
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
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    try {
      final type = _currentType;
      final hasCache = _service.hasCache(type);
      final isOnline = _connectivityService.isConnected.value;

      if (hasCache) {
        _loadFromCache();
        if(_announcements.isEmpty){
          _loadingState.value = LoadingState.error;
          return;
        }
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) return;

      try {
        await _service.fetchAnnouncements(
          1,
          _limit,
          search: searchController.text,
          type: type,
        );
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache(_currentType)) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: $e');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;
    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newAnnouncements = await _service.fetchMoreAnnouncements(
        _currentPage,
        _limit,
        _currentType,
      );

      if (newAnnouncements.isNotEmpty) {
        _announcements.addAll(newAnnouncements);
        if (newAnnouncements.length < _limit) _hasMore.value = false;
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Load more error: $e');
    } catch (e) {
      _currentPage--;
      if (kDebugMode) debugPrint('Unexpected error: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _loadFromCache() {
    _announcements.value = _service.getCachedAnnouncements(_currentType);
  }


  Future<List<AnnouncementModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedAnnouncements(_currentType)
        .where((a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
    if (fromCache.isNotEmpty) return fromCache;

    if (!_connectivityService.isConnected.value) return [];

    await _service.fetchAnnouncements(1, 20, search: query, type: _currentType);
    return _service
        .getCachedAnnouncements(_currentType)
        .where((a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  @override
  Future<void> refresh() async {
    _announcements.clear();
    _currentPage = 1;
   // _hasMore.value = true;
    _isLoadingMore.value = false;
    await _loadData();
  }

  Future<void> createAnnouncement() async {
    if (!formKey.currentState!.validate()) return;
    _createLoadingState.value = LoadingState.loading;
    try {
      final users = ProfileController.to.selectedUserIds;
      await _service.createAnnouncement(
        selectedImage,
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
      _selectedImage.value = null;
      users.clear();
      ToastMessageHelper.show('Created! Pending admin approval.');
    } on AppException catch (e) {
      _createLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Create announcement error: $e');
    }
  }


  Future<void> updateStatus(String announcementId, String status) async {
    _updateLoadingState.value = LoadingState.loading;
    try {
      await _service.updateStatus(announcementId, status);
      _updateLoadingState.value = LoadingState.loaded;
      refresh();
      Get.back(canPop: true);
    } on AppException catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Update status error: $e');
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    _deleteLoadingState.value = LoadingState.loading;
    try {
      await _service.deleteAnnouncement(announcementId);
      _deleteLoadingState.value = LoadingState.loaded;
      refresh();
      Get.back(canPop: true);
    } on AppException catch (e) {
      _deleteLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Delete announcement error: $e');
    }
  }



  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    titleTEController.dispose();
    decTEController.dispose();
    super.onClose();
  }
}