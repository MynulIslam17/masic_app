import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/core/services/search_service.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/request/data/models/create_job_model.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart';
import 'package:masic_generation/features/request/domain/services/request_services.dart';
import 'package:get/get.dart';

class RequestController extends GetxController {
  final RequestServices _service;
  final ConnectivityService _connectivityService;

  static RequestController get to => Get.find();

  RequestController({
    required RequestServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;



  late final SearchService<RequestModel> search;



  // ─── Loading States ─────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateState = LoadingState.initial.obs;
  final Rx<LoadingState> _createState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get updateState => _updateState.value;

  LoadingState get createState => _createState.value;

  // ─── Data ────────────────────────────────────────────────────────────────────
  final RxList<RequestModel> _requests = <RequestModel>[].obs;

  List<RequestModel> get requests => _requests;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  final declineReasonTEController = TextEditingController();
  final jobSpecTEController = TextEditingController();
  final searchController = SearchController();
  final formKey = GlobalKey<FormState>();
  final createFormKey = GlobalKey<FormState>();

  // ─── Scroll Controller ───────────────────────────────────────────────────────
  ScrollController? scrollController;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    search = SearchService(fetcher: _fetchSearch);
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  @override
  void onClose() {
    scrollController?.removeListener(_onScroll);
    scrollController?.dispose();
    scrollController = null;
    super.onClose();
  }

  // ─── Scroll ──────────────────────────────────────────────────────────────────
  void _initScrollController() {
    scrollController = ScrollController();
    scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController == null) return;
    final position = scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
  }

  // ─── Poll List ───────────────────────────────────────────────────────────────
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
        await _service.fetchRequests();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newPolls = await _service.fetchMoreRequest(_currentPage, _limit);

      if (newPolls.isNotEmpty) {
        _requests.addAll(newPolls);
        if (newPolls.length < _limit) _hasMore.value = false;
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
    _requests.value = _service.getCachedRequests();
    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache: ${_requests.length} Requests');
      }
      return true;
    }());
  }

  Future<List<RequestModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedRequests()
        .where((a) => a.jobSpec?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
    if (fromCache.isNotEmpty) return fromCache;

    if (!_connectivityService.isConnected.value) return [];

    await _service.fetchRequests(search: query);
    return _service
        .getCachedRequests()
        .where((a) => a.jobSpec?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  Future<void> updateStatus({
    required String requestId,
    required String status,
    String? declineReason,
  }) async {
    if (status == 'declined') {
      if (!formKey.currentState!.validate()) return;
    }
    _updateState.value = LoadingState.loading;
    try {
      await _service.updateStatus(requestId, status, declineReason);
      _updateState.value = LoadingState.loaded;
      refresh();
      Get.back(canPop: true);
    } on AppException catch (e) {
      _updateState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Update status error: $e');
    }
  }

  Future<bool> createRequest({required String type}) async {
    final user = ProfileController.to.userData;

    if (user == null) {
      ToastMessageHelper.show('User data not found');
      return false;
    }

    final validationError = _validateUserData(user);
    if (validationError != null) {
      ToastMessageHelper.show(validationError);
      return false;
    }

    try {
      _createState.value = LoadingState.loading;
      await _service.createRequest(
        CreateJobModel(
          user: user.sId,
          type: type,
          bio: user.bio,
          jobSpec: jobSpecTEController.text.trim(),
          contact: UserContact(
            phone: user.contact?.phone,
            email: user.email,
            linkedin: user.contact?.linkedin,
            address: user.contact?.address,
          ),
          education: user.educationHistory
              ?.map(
                (e) => EducationHistory(
              school: e.school,
              degree: e.degree,
              major: e.major,
              from: e.from,
              to: e.to,
              isCurrent: e.isCurrent,
            ),
          )
              .toList(),
          experience: user.experience
              ?.map(
                (e) => UserExperience(
              company: e.company,
              position: e.position,
              from: e.from,
              to: e.to,
              isCurrent: e.isCurrent,
            ),
          )
              .toList(),
          cvUrl: user.cvUrl,
        ),
      );
      _createState.value = LoadingState.loaded;
      Get.back(canPop: true);
      Get.back(canPop: true);
      jobSpecTEController.clear();
      return true;
    } catch (e) {
      _createState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Create request error: $e');
      return false;
    }
  }
  String? _validateUserData(UserModel user) {
    // Contact validation

    // Bio validation
    if (user.bio == null || user.bio!.isEmpty) {
      return 'Please add your bio';
    }

    if (user.contact == null) return 'Please add your contact information';


    // Education validation
    if (user.educationHistory == null || user.educationHistory!.isEmpty) {
      return 'Please add at least one education history';
    }

    // Experience validation
    if (user.experience == null || user.experience!.isEmpty) {
      return 'Please add at least one work experience';
    }

    // CV validation
    if (user.cvUrl == null || user.cvUrl!.isEmpty) {
      return 'Please upload your CV';
    }

    return null; // All valid
  }
  @override
  Future<void> refresh() async => _loadData();

  @override
  void dispose() {
    scrollController?.removeListener(_onScroll);
    scrollController?.dispose();
    scrollController = null;
    super.dispose();
  }
}
