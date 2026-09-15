import 'package:flutter/foundation.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/features/search/model/search_model.dart';
import 'package:masic_generation/features/tree/data/models/tree_model.dart';
import 'package:masic_generation/features/tree/domain/services/tree_service.dart';
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



  // ─── Expanded Nodes (first-level under root open; deeper only on tap) ───────
  final RxSet<String> _expandedNodes = <String>{}.obs;
  bool _didExpandRoot = false;

  Set<String> get expandedNodes => _expandedNodes;

  bool isNodeExpanded(String id) => _expandedNodes.contains(id);

  void toggleNode(String id) {
    if (_expandedNodes.contains(id)) {
      _expandedNodes.remove(id);
    } else {
      _expandedNodes.add(id);
    }
  }

  void _ensureRootExpanded() {
    if (_didExpandRoot) return;
    final root = _treeData.value?.root;
    if (root == null) return;

    final rootId = root.sId ?? root.linkedUser?.sId;
    if (rootId == null || rootId.isEmpty) return;

    _expandedNodes.add(rootId);
    _didExpandRoot = true;
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
    _ensureRootExpanded();
    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   TREE DATA: ${_treeData.value?.root?.children?.length}');
      }
      return true;
    }());
  }

  // ─── Search ───────────────────────────────────────────────────────────────────
  Future<List<SearchModel>> searchMembers(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final root = _treeData.value?.root;
    if (root == null) return [];

    final results = <SearchModel>[];
    final seen = <String>{};

    void addMember({
      required String? id,
      required LinkedUser? linkedUser,
      required String? label,
      String? relationType,
    }) {
      final memberId = id ?? linkedUser?.sId;
      if (memberId == null || memberId.isEmpty || !seen.add(memberId)) return;

      final name = linkedUser?.name;
      final arabicName = linkedUser?.arabicName;
      final email = linkedUser?.email ?? '';
      if (!LocalizedNameHelper.matchesMemberSearch(
        query: q,
        name: name,
        arabicName: arabicName,
        email: email,
        relationType: relationType,
      )) {
        return;
      }

      final title = LocalizedNameHelper.display(
        name: name,
        arabicName: arabicName,
        fallback: label,
      );

      results.add(
        SearchModel(
          model: memberId,
          title: title.isNotEmpty ? title : 'Unknown',
          personName: name,
          personArabicName: arabicName,
          subtitle: email.isNotEmpty ? email : null,
          image: linkedUser?.profileImage ?? 're',
        ),
      );
    }

    void walk(Children child) {
      addMember(
        id: child.sId,
        linkedUser: child.linkedUser,
        label: child.label,
        relationType: child.relationType,
      );
      for (final c in child.children ?? const <Children>[]) {
        walk(c);
      }
    }

    addMember(
      id: root.sId,
      linkedUser: root.linkedUser,
      label: root.label,
      relationType: root.relationType,
    );
    for (final child in root.children ?? const <Children>[]) {
      walk(child);
    }

    return results;
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
