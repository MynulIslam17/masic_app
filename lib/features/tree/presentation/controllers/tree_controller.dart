import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/domain/services/tree_service.dart';
import 'package:get/get.dart';

class TreeController extends GetxController {
  final TreeService _service;
  final ConnectivityService _connectivityService;

  static TreeController get to => Get.find();

  TreeController({
    required TreeService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;



  // ─── Collapsed Nodes ───────────────────────────────────────────────────────
  final RxSet<String> _collapsedNodes = <String>{}.obs;

  Set<String> get collapsedNodes => _collapsedNodes;

  bool isNodeCollapsed(String id) => _collapsedNodes.contains(id);

  void toggleNode(String id) {
    if (_collapsedNodes.contains(id)) {
      _collapsedNodes.remove(id);
    } else {
      _collapsedNodes.add(id);
    }
  }
  // ─── Loading State ─────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get detailsLoadingState => _detailsLoadingState.value;

  LoadingState get deleteState => _deleteState.value;

  final Rx<TreeModel?> _treeData = Rx<TreeModel?>(null);
  final _userDetails = Rxn<UserModel>();

  TreeModel? get treeData => _treeData.value;

  UserModel? get userDetails => _userDetails.value;

  @override
  void onInit() {
    super.onInit();

    ever(_connectivityService.isConnected, (bool isConnected) {
      if (isConnected) loadData();
    });

    loadData();
  }

  // ─── Load Data ─────────────────────────────────────────────────────────────
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
        await _service.fetchTree();
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
      if (kDebugMode) debugPrint('Unexpected error: $e');
    }
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────
  void _loadFromCache() {
    _treeData.value = _service.getCachedUserData();
    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   TREE DATA: ${_treeData.value?.root?.children?.length}');
      }
      return true;
    }());
  }

  // ─── User Details ─────────────────────────────────────────────────────────────
  Future<void> fetchUserDetails(String userId) async {
    try {
      _detailsLoadingState.value = LoadingState.loading;

      final user = await _service.treeUserDetails(userId);
      _userDetails.value = user;
      _detailsLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchPollDetails error: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _deleteState.value = LoadingState.loading;
      await _service.deleteUser(userId);
      _deleteState.value = LoadingState.loaded;
      await loadData();
      await ProfileController.to.retry();
      Get.back(canPop: true);
    } catch (e) {
      _deleteState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deleteUser error: $e');
    }
  }
}
