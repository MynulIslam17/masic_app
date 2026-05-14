import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/request/data/models/create_job_model.dart';
import 'package:flutter_task/features/request/data/models/request_model.dart';
import 'package:flutter_task/features/request/domain/services/request_services.dart';
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
  final searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final createFormKey = GlobalKey<FormState>();

  // ─── Scroll Controller ───────────────────────────────────────────────────────
  ScrollController? scrollController;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
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

  Future<void> createRequest() async {
    final user = ProfileController.to.userData;
    if (user == null ||
        user.contact == null ||
        user.educationHistory == null ||
        user.experience == null) {
      ToastMessageHelper.show('Please fill all the required fields');
      Get.toNamed(AppRoutes.profileInformationScreen);
      return;
    }
    if (!createFormKey.currentState!.validate()) return;
    try {
      _createState.value = LoadingState.loading;
      await _service.createRequest(
        CreateJobModel(
          user: user.sId,
          type: 'job',
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
      ToastMessageHelper.show('Request sent, Please wait for admin approval');
    } catch (e) {
      _createState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) debugPrint('Create request error: $e');
    }
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
