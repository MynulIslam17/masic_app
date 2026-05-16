import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/tree/data/models/tree_model.dart';
import 'package:flutter_task/features/tree/domain/services/tree_service.dart';
import 'package:get/get.dart' hide Node;
import 'package:graphview/GraphView.dart';

class TreeController extends GetxController with GetSingleTickerProviderStateMixin {
  final TreeService _service;
  final ConnectivityService _connectivityService;

  static TreeController get to => Get.find();

  TreeController({
    required TreeService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  // ─── Layout Constants ──────────────────────────────────────────────────────
  static const double cardH   = 40.0;
  static const double cardGap = 8.0;
  static const double childW  = 155.0;
  static const double centerW = 138.0;
  static const double stub    = 26.0;
  static const double hLine   = 10.0;
  static const double vPad = 8.0;


  static const double spineX  = centerW + hLine;   // 166.0
  static const double childL  = spineX  + stub;    // 192.0
  static const double totalW  = childL  + childW;  // 347.0
  static double get centerL => (totalW - centerW) / 5;


  // ─── Loading State ─────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;


  LoadingState get loadingState => _loadingState.value;
  LoadingState get detailsLoadingState => _detailsLoadingState.value;

  // ─── Data ──────────────────────────────────────────────────────────────────
  final Rx<TreeModel?> _treeData = Rx<TreeModel?>(null);
  final _userDetails = Rxn<UserModel>();

  TreeModel? get treeData => _treeData.value;
  UserModel? get userDetails => _userDetails.value;


  // ─── Graph ─────────────────────────────────────────────────────────────────
  final Graph graph = Graph()..isTree = true;
  late final BuchheimWalkerConfiguration builder;

  final RxMap<String, bool> expandedNodes = <String, bool>{}.obs;
  final RxMap<String, NodeInfo> nodeInfoMap = <String, NodeInfo>{}.obs;
  final RxInt graphVersion = 0.obs;

  late AnimationController animController;

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    ever(_connectivityService.isConnected, (bool isConnected) {
      if (isConnected) loadData();
    });

    loadData();
  }

  @override
  void onClose() {
    animController.dispose();
    super.onClose();
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
}
