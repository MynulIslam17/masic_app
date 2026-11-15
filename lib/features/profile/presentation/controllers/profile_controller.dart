import 'package:masic_generation/core/helpers/app_log.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/helpers/dialog_close_helper.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/document_upload_helper.dart';
import 'package:masic_generation/core/helpers/localized_name_helper.dart';
import 'package:masic_generation/core/helpers/time_format.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/routes/app_routes.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/core/services/search_service.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/profile/domain/services/profile_service.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ProfileService _service;
  final ConnectivityService _connectivityService;

  static ProfileController get to => Get.find();




  ProfileController({
    required ProfileService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;


  late final SearchService<UserModel> search;

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  final Rx<LoadingState> _updateRoleState = LoadingState.initial.obs;

  final Rx<LoadingState> _motherTreeState = LoadingState.initial.obs;
  final Rx<LoadingState> _blockUserState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteAccountState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteUserState = LoadingState.initial.obs;

  LoadingState get motherTreeState => _motherTreeState.value;

  /// Submit on the Select Mother Tree page (choose-mother / add-child). Kept
  /// apart from [motherTreeState] so loading the list never spins the button
  /// and submitting never blanks the list.
  final Rx<LoadingState> _motherSubmitState = LoadingState.initial.obs;
  LoadingState get motherSubmitState => _motherSubmitState.value;
  LoadingState get blockUserState => _blockUserState.value;
  LoadingState get deleteAccountState => _deleteAccountState.value;
  LoadingState get deleteUserState => _deleteUserState.value;

  final RxList<UserModel> _motherTreesData = <UserModel>[].obs;
  List<UserModel> get motherTreesData => _motherTreesData;


  LoadingState get updateRoleState => _updateRoleState.value;


  LoadingState get loadingState => _loadingState.value;

  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  LoadingState get updateLoadingState => _updateLoadingState.value;


  // ─── User Data ─────────────────────────────────────────────────────────────
  final _selectedImage = Rxn<File>();
  final _selectedCV = Rxn<File>();

  File? get selectedImage => _selectedImage.value;

  File? get selectedCV => _selectedCV.value;

  final _userData = Rxn<UserModel>();

  UserModel? get userData => _userData.value;


  // ─── Users List ────────────────────────────────────────────────────────────
  final RxList<UserModel> _usersData = <UserModel>[].obs;

  List<UserModel> get usersData => _usersData;

  final RxInt _usersTotal = 0.obs;

  /// Full count from the users API `meta.total`, not the loaded page size.
  int get usersTotal => _usersTotal.value;

  // ─── Filters ───────────────────────────────────────────────────────────────
  final RxString _genderFilter = ''.obs;
  final RxString _employmentFilter = ''.obs;
  final RxString _educationFilter = ''.obs;
  final RxString _ageFilter = ''.obs;
  final RxString _fieldOfWorkFilter = ''.obs;
  final RxString _nameFilter = ''.obs;
  final RxBool _isJobOngoings = false.obs;
  final RxBool _isEducationOngoings = false.obs;
  final RxString _roleFilter = ''.obs;

  final searchController = TextEditingController();

  String get genderFilter => _genderFilter.value;

  String get employmentFilter => _employmentFilter.value;

  String get educationFilter => _educationFilter.value;

  String get ageFilter => _ageFilter.value;

  String get fieldOfWorkFilter => _fieldOfWorkFilter.value;

  String get nameFilter => _nameFilter.value;

  bool get isJobOngoings => _isJobOngoings.value;

  String get roleFilter => _roleFilter.value;

  bool get isEducationOngoings => _isEducationOngoings.value;

  void setRoleFilter(String value, {bool reloadIfSame = true}) {
    if (_roleFilter.value == value) {
      if (reloadIfSame) refresh();
      return;
    }
    _roleFilter.value = value;
  }

  void _clearListFilters() {
    _genderFilter.value = '';
    _employmentFilter.value = '';
    _educationFilter.value = '';
    _ageFilter.value = '';
    _fieldOfWorkFilter.value = '';
    _nameFilter.value = '';
    searchController.clear();
  }

  Future<void> openAllUsers() async {
    _clearListFilters();
    _loadingState.value = LoadingState.loading;
    Get.toNamed(AppRoutes.allUserScreen);
    if (_roleFilter.value.isEmpty) {
      await refresh(showLoader: true);
    } else {
      _roleFilter.value = '';
    }
  }

  Future<void> openAllAdmins() async {
    _clearListFilters();
    _loadingState.value = LoadingState.loading;
    Get.toNamed(AppRoutes.allAdminScreen);
    if (_roleFilter.value == 'admin') {
      await refresh(showLoader: true);
    } else {
      _roleFilter.value = 'admin';
    }
  }



  // ─── Selection ─────────────────────────────────────────────────────────────
  final RxList<String> _selectedUserIds = <String>[].obs;

  List<String> get selectedUserIds => _selectedUserIds;

  final RxString _selectedUserId = ''.obs;

  String get selectedUserId => _selectedUserId.value;

  void selectSingleUser(String id) {
    _selectedUserId.value = id;
  }

  // ─── Edit Tracking ─────────────────────────────────────────────────────────
  int? _editingEducationIndex;
  int? _editingExperienceIndex;

  // ─── Pagination ────────────────────────────────────────────────────────────
  int _currentPage = 1;
  final int _limit = 10;
  static const int _motherTreeLimit = 1000;
  bool _motherTreePickerMode = false;
  bool _motherTreePlacedOnly = false;
  final RxBool _isLoadingMore = false.obs;
  bool _isRefreshing = false;

  bool get isLoadingMore => _isLoadingMore.value;

  final RxBool _hasMore = true.obs;

  bool get hasMoreUsers => _hasMore.value && !_isLoadingMore.value;

  // ─── Scroll Controller ─────────────────────────────────────────────────────
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  // ─── Text Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final employmentController = TextEditingController();
  final educationController = TextEditingController();
  final universityController = TextEditingController();
  final fieldOfWorkController = TextEditingController();
  final spouseNameController = TextEditingController();
  final spousePhoneController = TextEditingController();
  final bioController = TextEditingController();
  final numberController = TextEditingController();
  final linkedinController = TextEditingController();
  final schoolController = TextEditingController();
  final degreeController = TextEditingController();
  final majorController = TextEditingController();
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final jobnameController = TextEditingController();
  final positionController = TextEditingController();
  final fromJobDateController = TextEditingController();
  final toJobDateController = TextEditingController();


  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    search = SearchService(fetcher: _fetchSearch);
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (!isConnected || !isAuthenticated) return;
      if (!_hasAppAccess) {
        // Still on the Select Mother Tree page: retry its list if it failed,
        // and leave the member directory alone.
        if (_motherTreeState.value == LoadingState.error) loadMotherTrees();
        return;
      }
      loadData();
    });
    ever(_roleFilter, (_) => refresh(showLoader: true));
    // Controller is created eagerly at app start; before login there is no
    // token and `GET /users/me` would just 401. AuthController triggers
    // loadData() after a successful login / session restore.
    // Users who still have to pick a mother tree don't need the directory.
    if (isAuthenticated && _hasAppAccess) loadData();
  }

  /// False while the logged-in user still has to pick a mother tree.
  bool get _hasAppAccess =>
      !Get.isRegistered<AuthController>() || AuthController.to.hasAppAccess;

  /// Whether a session token exists. Overridable in tests.
  @visibleForTesting
  bool get isAuthenticated =>
      Get.isRegistered<AuthController>() && AuthController.to.isLoggedIn();

  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController == null || _isRefreshing) return;
    final position = _scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMoreUsers) {
      loadMoreUsers();
    }
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore.value = !_motherTreePickerMode;
    _isLoadingMore.value = false;
  }

  void _syncHasMoreAfterFirstPage() {
    if (_motherTreePickerMode) {
      _hasMore.value = false;
      return;
    }
    final total = _usersTotal.value;
    if (total > 0) {
      _hasMore.value = _usersData.length < total;
      return;
    }
    _hasMore.value = _usersData.length >= _limit;
  }

  /// Tree filter sent to `GET /users`.
  ///
  /// The member directory only ever shows users who are placed in the tree —
  /// for admins too (client requirement: no users outside the tree). The only
  /// escape hatch is the admin "assign to mother tree" picker, which needs to
  /// see unplaced accounts and therefore asks explicitly for `all` (the
  /// backend now defaults to `placed` when no filter is sent).
  @visibleForTesting
  String get activeTreeJoinStatus => _activeTreeJoinStatus;

  String get _activeTreeJoinStatus {
    if (_motherTreePickerMode && !_motherTreePlacedOnly) return 'all';
    return 'placed';
  }

  int get _activeUserLimit =>
      _motherTreePickerMode ? _motherTreeLimit : _limit;

  void enterMotherTreePicker({required bool placedOnly}) {
    _motherTreePickerMode = true;
    _motherTreePlacedOnly = placedOnly;
    _hasMore.value = false;
  }

  Future<void> startMotherTreePicker({required bool placedOnly}) async {
    enterMotherTreePicker(placedOnly: placedOnly);
    await refresh(showLoader: true);
  }

  void stopMotherTreePicker() {
    _motherTreePickerMode = false;
    _motherTreePlacedOnly = false;
  }

  // ─── File & Image ──────────────────────────────────────────────────────────
  void onFilePicked(PlatformFile value) {
    try {
      DocumentUploadHelper.ensurePickSize(value.size);
      if (value.path == null) return;
      _selectedCV.value = File(value.path!);
    } on AppException catch (e) {
      ToastMessageHelper.show(e.message);
    }
  }

  void selectImage(XFile image) {
    _selectedImage.value = File(image.path);
  }

  // ─── Selection ─────────────────────────────────────────────────────────────
  void toggleUserSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
    } else {
      _selectedUserIds.add(userId);
    }
  }


  void setGenderFilter(String value) => _genderFilter.value = value;
  void setAgeFilter(String value) => _ageFilter.value = value;
  void setEmploymentFilter(String value) => _employmentFilter.value = value;
  void setEducationFilter(String value) => _educationFilter.value = value;
  void setFieldOfWorkFilter(String value) => _fieldOfWorkFilter.value = value;
  void setNameFilter(String value) => _nameFilter.value = value;

  String _normalizeGender(String label) {
    final lower = label.trim().toLowerCase();
    if (lower.startsWith('f')) return 'Female';
    if (lower.startsWith('m')) return 'Male';
    return label.trim();
  }

  String _normalizeAge(String label) {
    final cleaned = label.trim().replaceAll(' ', '');
    const ranges = ['01-20', '21-40', '41-60', '61-80', '81-100'];
    if (ranges.contains(cleaned)) return cleaned;

    final parts = cleaned.split(RegExp(r'[-–—]'));
    if (parts.length == 2) {
      final start = parts[0].padLeft(2, '0');
      final end = parts[1];
      final candidate = '$start-$end';
      if (ranges.contains(candidate)) return candidate;
    }
    return cleaned;
  }

  String _normalizeEmployment(String label) {
    final lower = label.trim().toLowerCase();
    if (lower.contains('self')) return 'Self-employed';
    if (lower.contains('unemploy')) return 'Unemployed';
    if (lower.contains('student')) return 'Student';
    if (lower.contains('employ')) return 'Employed';
    return label.trim();
  }

  Future<void> openUsersWithFilters({
    String gender = '',
    String age = '',
    String employment = '',
    String education = '',
    String fieldOfWork = '',
    String name = '',
  }) async {
    _genderFilter.value = gender;
    _ageFilter.value = age;
    _employmentFilter.value = employment;
    _educationFilter.value = education;
    _fieldOfWorkFilter.value = fieldOfWork;
    _nameFilter.value = name;

    _loadingState.value = LoadingState.loading;
    Get.toNamed(AppRoutes.allUserScreen);

    if (_roleFilter.value.isEmpty) {
      await refresh(showLoader: true);
    } else {
      _roleFilter.value = '';
    }
  }

  Future<void> openUsersFilteredByGender(String genderLabel) {
    return openUsersWithFilters(gender: _normalizeGender(genderLabel));
  }

  Future<void> openUsersFilteredByAge(String ageLabel) {
    return openUsersWithFilters(age: _normalizeAge(ageLabel));
  }

  Future<void> openUsersFilteredByEmployment(String employmentLabel) {
    return openUsersWithFilters(
      employment: _normalizeEmployment(employmentLabel),
    );
  }

  Future<void> openUsersFilteredByFieldOfWork(String fieldOfWorkLabel) {
    return openUsersWithFilters(fieldOfWork: fieldOfWorkLabel.trim());
  }

  Future<void> openUsersFilteredByName(String nameLabel) {
    return openUsersWithFilters(name: nameLabel.trim());
  }


  bool isUserSelected(String userId) => _selectedUserIds.contains(userId);

  void onChangedJob(value) => _isJobOngoings.value = value!;

  void onChangedEducation(value) => _isEducationOngoings.value = value!;

  // ─── Load Data ─────────────────────────────────────────────────────────────
  DateTime? _lastLoadAt;
  String? _lastLoadUserId;

  String? get _authUserId => Get.isRegistered<AuthService>()
      ? Get.find<AuthService>().getCachedUser()?.id
      : null;

  /// [loadData], unless it already ran for this user a moment ago. App start
  /// loads once in [onInit]; the splash must not repeat the same requests.
  Future<void> loadDataIfNeeded() async {
    final last = _lastLoadAt;
    if (last != null &&
        _lastLoadUserId == _authUserId &&
        DateTime.now().difference(last) < const Duration(seconds: 15)) {
      return;
    }
    await loadData();
  }

  /// The server is the source of truth for tree placement. If it says a
  /// user this device believed to be placed no longer is (an admin removed
  /// them), send them back to the Select Mother Tree page.
  Future<void> _redirectIfNoLongerPlaced() async {
    if (!Get.isRegistered<AuthController>()) return;
    final auth = AuthController.to;
    if (!auth.isLoggedIn() || auth.isAdmin()) return;
    if (auth.cachedUser?.treeJoinStatus != 'placed') return;
    final serverStatus = (_userData.value?.treeJoinStatus ?? '').toLowerCase();
    if (serverStatus.isEmpty || serverStatus == 'placed') return;

    AppLog.warn('Profile', 'Tree status is now "$serverStatus": back to Select Mother Tree');
    await Get.find<AuthService>().syncTreeJoinStatus(serverStatus);
    if (Get.currentRoute != AppRoutes.motherSelectScreen) {
      Get.offAllNamed(AppRoutes.motherSelectScreen);
    }
  }

  Future<void> loadData({bool showLoader = false}) async {
    _lastLoadAt = DateTime.now();
    _lastLoadUserId = _authUserId;
    try {
      final role = _roleFilter.value;
      final hasCache = _service.hasCache();
      final isOnline = _connectivityService.isConnected.value;

      if (showLoader) {
        _loadingState.value = LoadingState.loading;
      } else if (hasCache) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.loading;
      }

      if (!isOnline) {
        if (hasCache) {
          _loadFromCache();
          _loadingState.value = LoadingState.loaded;
        } else {
          _loadingState.value = LoadingState.offline;
        }
        return;
      }

      try {
        await _service.fetchUserProfile(
          page: 1,
          limit: _activeUserLimit,
          gender: genderFilter,
          employmentStatus: employmentFilter,
          educationLevel: educationFilter,
          searchTerm: searchController.text,
          age: ageFilter,
          role: role,
          fieldOfWork: fieldOfWorkFilter,
          name: nameFilter,
          treeJoinStatus: _activeTreeJoinStatus,
          includeProfile: !_motherTreePickerMode,
        );
        _loadFromCache();
        _currentPage = 1;
        _syncHasMoreAfterFirstPage();
        _loadingState.value = LoadingState.loaded;
        if (!_motherTreePickerMode) await _redirectIfNoLongerPlaced();
      } on AppException catch (e) {
        if (hasCache) {
          _loadFromCache();
          _loadingState.value = LoadingState.loaded;
        } else {
          _loadingState.value = LoadingState.error;
        }
        if (kDebugMode) AppLog.error('Profile', 'Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _currentPage = 1;
        _syncHasMoreAfterFirstPage();
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) AppLog.error('Profile', 'Unexpected error: $e');
    }
  }

  // ─── Load More ─────────────────────────────────────────────────────────────
  Future<void> loadMoreUsers() async {
    if (_isRefreshing || _isLoadingMore.value || !hasMoreUsers) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newUsers = await _service.fetchUsersMore(
        page: _currentPage,
        limit: _activeUserLimit,
        gender: genderFilter,
        employmentStatus: employmentFilter,
        educationLevel: educationFilter,
        age: ageFilter,
        role: roleFilter,
        fieldOfWork: fieldOfWorkFilter,
        name: nameFilter,
        searchTerm: searchController.text,
        treeJoinStatus: _activeTreeJoinStatus,
      );

      _syncUsersTotalFromCache();
      if (_motherTreePickerMode) {
        newUsers.removeWhere((u) {
          final r = (u.role ?? '').trim().toLowerCase();
          return r == 'superadmin' || r == 'super_admin';
        });
      }
      if (newUsers.isNotEmpty) {
        _usersData.addAll(newUsers);
        final total = _usersTotal.value;
        _hasMore.value = total > 0
            ? _usersData.length < total
            : newUsers.length >= _activeUserLimit;
      } else {
        _hasMore.value = false;
      }
    } on AppException catch (e) {
      _currentPage--;
      if (kDebugMode) AppLog.error('Profile', 'Load more error: $e');
    } catch (e) {
      _currentPage--;
      if (kDebugMode) AppLog.error('Profile', 'Unexpected error: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────
  /// Tree placement status used to route the user after login / app start.
  ///
  /// * `placed` on this device is trusted ([loadData] re-checks it right
  ///   after and redirects if the server disagrees).
  /// * [isFresh] means [cachedStatus] just came from the server (login).
  /// * Otherwise the server is asked: an admin may have placed the user
  ///   since the app was last open. Offline, the last known status is used.
  Future<String?> resolveTreeJoinStatus({
    String? cachedStatus,
    bool isFresh = false,
  }) async {
    if (cachedStatus == 'placed') return 'placed';
    if (isFresh && (cachedStatus?.isNotEmpty ?? false)) return cachedStatus;

    try {
      final user = await _service.fetchCurrentUser(userId: _authUserId);
      if (user != null) {
        _userData.value = user;
        _populateControllers(user);
        final status = user.treeJoinStatus;
        if (status != null && status.isNotEmpty) return status;
      }
    } catch (e) {
      AppLog.error('Profile', 'Could not check tree status: $e');
    }

    return cachedStatus;
  }

  void _loadFromCache() {
    _populateControllers(_service.getCachedUserData());
    _userData.value = _service.getCachedUserData();
    final cachedUsers = _service.getCachedUsers(
      roleFilter,
      treeJoinStatus: _activeTreeJoinStatus,
    );
    if (_motherTreePickerMode) {
      cachedUsers.removeWhere((u) {
        final r = (u.role ?? '').trim().toLowerCase();
        return r == 'superadmin' || r == 'super_admin';
      });
    }
    _usersData.value = cachedUsers;
    _syncUsersTotalFromCache();

    assert(() {
      if (kDebugMode) {
        AppLog.info('Profile', 'Loaded from cache → Users: ${_usersData.length}');
      }
      return true;
    }());
  }

  void _syncUsersTotalFromCache() {
    final total = _service.getCachedUsersTotal(
      roleFilter,
      treeJoinStatus: _activeTreeJoinStatus,
    );
    _usersTotal.value = total ?? _usersData.length;
  }

  Future<List<UserModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedUsers(roleFilter, treeJoinStatus: _activeTreeJoinStatus)
        .where((a) => a.matchesLocalizedNameSearch(query))
        .toList();
    if (fromCache.isNotEmpty) return fromCache;

    if (!_connectivityService.isConnected.value) return [];

    await _service.fetchUserProfile(search: query,
      gender: genderFilter,
      employmentStatus: employmentFilter,
      educationLevel: educationFilter,
      age: ageFilter,
      role: roleFilter,
      fieldOfWork: fieldOfWorkFilter,
      name: nameFilter,
      treeJoinStatus: _activeTreeJoinStatus,
    );
    return _service
        .getCachedUsers(roleFilter, treeJoinStatus: _activeTreeJoinStatus)
        .where((a) => a.matchesLocalizedNameSearch(query))
        .toList();
  }

  bool _isOnboardingFlow = false;

  bool get isOnboarding => _isOnboardingFlow || Get.arguments == 'onboarding';

  void beginOnboarding() {
    _isOnboardingFlow = true;
    _selectedUserId.value = '';
    _rememberProfileSetupPending(true);
  }

  void finishOnboarding() {
    _isOnboardingFlow = false;
    _rememberProfileSetupPending(false);
  }

  /// Persisted so that closing the app on Setup Profile resumes there.
  void _rememberProfileSetupPending(bool pending) {
    if (!Get.isRegistered<AuthService>()) return;
    Get.find<AuthService>().setProfileSetupPending(pending);
  }

  Future<void> prepareOnboardingProfile() async {
    try {
      final user = await _service.fetchCurrentUser(
        userId: Get.find<AuthService>().getCachedUser()?.id,
      );
      if (isClosed) return;

      if (user != null) {
        _userData.value = user;
        _populateControllers(user);
        return;
      }

      _seedProfileFromAuthCache();
    } catch (e) {
      if (isClosed) return;
      _seedProfileFromAuthCache();
      if (kDebugMode) AppLog.error('Profile', 'Onboarding profile fetch error: $e');
    }
  }

  void _seedProfileFromAuthCache() {
    final authUser = Get.find<AuthService>().getCachedUser();
    if (authUser == null) return;

    final fallbackUser = UserModel(
      sId: authUser.id,
      name: authUser.name,
      email: authUser.email,
      role: authUser.role,
    );
    _userData.value = fallbackUser;
    _populateControllers(fallbackUser);
  }
  Future<void> updateUserProfile() async {
    final user = _userData.value;
    if (user == null) {
      ToastMessageHelper.show('User data not loaded yet. Please try again.');
      return;
    }

    if (isOnboarding) {
      if (nameController.text.trim().isEmpty) {
        ToastMessageHelper.show('Please enter your full name');
        return;
      }
      if (phoneController.text.trim().isEmpty) {
        ToastMessageHelper.show('Please enter your phone number');
        return;
      }
    }

    try {
      _updateLoadingState.value = LoadingState.loading;

      // ── Education list ────────────────────────────────────────────────────
      final currentEducation = List<EducationHistory>.from(
        user.educationHistory ?? [],
      );

      final hasEducationData =
          schoolController.text.trim().isNotEmpty ||
          degreeController.text.trim().isNotEmpty ||
          majorController.text.trim().isNotEmpty;

      if (hasEducationData) {
        final newEdu = EducationHistory(
          school: schoolController.text.trim(),
          degree: degreeController.text.trim(),
          major: majorController.text.trim(),
          from: fromDateController.text.trim().isNotEmpty
              ? TimeFormatHelper.parseToIso(fromDateController.text.trim())
              : null,
          to: toDateController.text.trim().isNotEmpty
              ? TimeFormatHelper.parseToIso(toDateController.text.trim())
              : null,
          isCurrent: _isEducationOngoings.value,
        );

        // Edit
        if (_editingEducationIndex != null &&
            _editingEducationIndex! < currentEducation.length) {
          currentEducation[_editingEducationIndex!] = newEdu;
        }
        // Add
        else {
          currentEducation.add(newEdu);
        }
      }

      // ── Experience list ───────────────────────────────────────────────────
      final currentExperience = List<UserExperience>.from(
        user.experience ?? [],
      );

      final hasExperienceData =
          jobnameController.text.trim().isNotEmpty ||
          positionController.text.trim().isNotEmpty;

      if (hasExperienceData) {
        final newExp = UserExperience(
          company: jobnameController.text.trim(),
          position: positionController.text.trim(),
          isCurrent: _isJobOngoings.value,
          from: fromJobDateController.text.trim().isNotEmpty
              ? TimeFormatHelper.parseToIso(fromJobDateController.text.trim())
              : null,
          to: toJobDateController.text.trim().isNotEmpty
              ? TimeFormatHelper.parseToIso(toJobDateController.text.trim())
              : null,
        );

        // Edit
        if (_editingExperienceIndex != null &&
            _editingExperienceIndex! < currentExperience.length) {
          currentExperience[_editingExperienceIndex!] = newExp;
        }
        // Add
        else {
          currentExperience.add(newExp);
        }
      }

      // ── API call ──────────────────────────────────────────────────────────
      final updatedUser = await _service.updateUserProfile(
        UserModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          // DOB is deprecated by the client — never sent on edit-profile.
          gender: genderController.text.trim(),
          employmentStatus: employmentController.text.trim(),
          education: educationController.text.trim(),
          universityName: universityController.text.trim(),
          country: user.country,
          countryCode: user.countryCode,
          region: user.region,
          city: user.city,
          district: user.district,
          educationLevel: user.educationLevel,
          fieldOfWork: fieldOfWorkController.text.trim(),
          spouseName: spouseNameController.text.trim(),
          spousePhone: spousePhoneController.text.trim(),
          linkedinLink: user.linkedinLink,
          bio: bioController.text.trim(),
          contact: UserContact(
            phone: numberController.text.trim(),
            linkedin: linkedinController.text.trim(),
          ),
          educationHistory: currentEducation,
          experience: currentExperience,
        ),
        image: _selectedImage.value,
        cv: _selectedCV.value,
      );
      _userData.value = updatedUser;

      _editingEducationIndex = null;
      _editingExperienceIndex = null;

      clearEducationControllers();
      clearJobControllers();
      _populateControllers(updatedUser);
      _updateLoadingState.value = LoadingState.loaded;

      if (isOnboarding) {
        finishOnboarding();
        // Next step is the Select Mother Tree page, unless the server says
        // the user is already `placed`.
        if ((updatedUser.treeJoinStatus ?? '').toLowerCase() == 'placed') {
          await Get.find<AuthService>().syncTreeJoinStatus('placed');
          Get.offAllNamed(AppRoutes.bottomNavUserBar);
          loadData();
        } else {
          // The update response already says "not placed": go straight to
          // the picker without asking the server again.
          Get.offAllNamed(AppRoutes.motherSelectScreen);
        }
      } else {
        Get.back(canPop: true);
      }
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      AppLog.error('Profile', 'Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _populateControllers(UserModel? data) {
    if (data == null || isClosed) return;
    nameController.text = data.name ?? '';
    emailController.text = data.email ?? '';
    phoneController.text = data.phone ?? '';
    genderController.text = data.gender?.toTitleCase ?? '';
    employmentController.text = data.employmentStatus?.toTitleCase ?? '';
    educationController.text = data.education?.toTitleCase ?? '';
    universityController.text = data.universityName ?? '';
    fieldOfWorkController.text = data.fieldOfWork ?? '';
    spouseNameController.text = data.spouseName ?? '';
    spousePhoneController.text = data.spousePhone ?? '';
    bioController.text = data.bio ?? '';
    numberController.text = data.contact?.phone ?? '';
    linkedinController.text = data.contact?.linkedin ?? '';
  }

  Future<void> retry() => refresh();

  @override
  Future<void> refresh({bool showLoader = false}) async {
    _resetPagination();
    _isRefreshing = true;
    if (showLoader) {
      _loadingState.value = LoadingState.loading;
    }
    if (_scrollController?.hasClients ?? false) {
      _scrollController!.jumpTo(0);
    }
    try {
      await loadData(showLoader: showLoader);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clears the filter values without reloading anything.
  void resetFilters() {
    _genderFilter.value = '';
    _employmentFilter.value = '';
    _educationFilter.value = '';
    _ageFilter.value = '';
    _fieldOfWorkFilter.value = '';
    _nameFilter.value = '';
  }

  void clearAllFilters() {
    resetFilters();
    retry();
  }


  Future<void> updateRole(String userId, String role) async {
    if (userId.isEmpty) {
      ToastMessageHelper.show('Invalid user');
      return;
    }

    try {
      _updateRoleState.value = LoadingState.loading;
      await _service.updateRole(userId, role);

      final index = _usersData.indexWhere((u) => u.sId == userId);
      if (index != -1) {
        _usersData[index].role = role;
        if (roleFilter == 'admin' && role != 'admin') {
          _usersData.removeAt(index);
        }
        _usersData.refresh();
      }

      _updateRoleState.value = LoadingState.loaded;
      DialogCloseHelper.closeIfOpen();
      ToastMessageHelper.show(
        role == 'admin' ? 'Admin access granted' : 'Admin access removed',
      );
      await retry();
    } catch (e) {
      _updateRoleState.value = LoadingState.error;
      AppLog.error('Profile', 'Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }


  Future<void> motherTreeSelect() async {
    if (_selectedUserId.value.isEmpty) {
      ToastMessageHelper.show('Please select a mother tree member');
      return;
    }

    try {
      _motherSubmitState.value = LoadingState.loading;
      await _service.motherTreeSelect(_selectedUserId.value);
      await Get.find<AuthService>().syncTreeJoinStatus('placed');
      _motherSubmitState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoutes.bottomNavUserBar);
      // The user is placed now: load the profile and member directory once.
      loadData();
    } catch (e) {
      AppLog.error('Profile', 'Choose mother tree failed: $e');
      // An admin may have placed this user in the meantime, in which case
      // the request can never succeed: check before reporting a failure.
      final status = await resolveTreeJoinStatus();
      if (status == 'placed') {
        await Get.find<AuthService>().syncTreeJoinStatus('placed');
        _motherSubmitState.value = LoadingState.loaded;
        ToastMessageHelper.show('You are already placed in the family tree');
        Get.offAllNamed(AppRoutes.bottomNavUserBar);
        loadData();
        return;
      }
      _motherSubmitState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> addMember(String motherId) async {
    try {
      _motherSubmitState.value = LoadingState.loading;
      await _service.addMember(_selectedUserId.value,motherId);
      _motherSubmitState.value = LoadingState.loaded;
      await TreeController.to.loadData();
      await retry();
      Get.back(canPop: true);
    } catch (e) {
      _motherSubmitState.value = LoadingState.error;
      AppLog.error('Profile', 'Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }


  Future<void> blockUser(String userId,{required String  type}) async {
    try {
      _blockUserState.value = LoadingState.loading;
      await _service.blockUser(userId,type: type);
      _blockUserState.value = LoadingState.loaded;
      DialogCloseHelper.closeIfOpen();
      await retry();
    } catch (e) {
      _blockUserState.value = LoadingState.error;
      AppLog.error('Profile', 'Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> deleteAccount() async {
    _deleteAccountState.value = LoadingState.loading;
    try {
      await _service.deleteAccount();
      _deleteAccountState.value = LoadingState.loaded;
      ToastMessageHelper.show('Account deleted successfully');
      await AuthController.to.logout();
    } catch (e) {
      _deleteAccountState.value = LoadingState.error;
      AppLog.error('Profile', 'Delete account error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> deleteUser(String userId) async {
    _deleteUserState.value = LoadingState.loading;
    try {
      await _service.deleteUser(userId);
      _usersData.removeWhere((u) => u.sId == userId);
      _usersTotal.value = (_usersTotal.value - 1).clamp(0, double.infinity).toInt();
      _deleteUserState.value = LoadingState.loaded;
      DialogCloseHelper.closeIfOpen();
      ToastMessageHelper.show('User deleted successfully');
      await retry();
    } catch (e) {
      _deleteUserState.value = LoadingState.error;
      AppLog.error('Profile', 'Delete user error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  /// Loads the mother tree list.
  ///
  /// [silent] is for pull-to-refresh: the current list stays on screen and
  /// only the pull indicator shows progress. A failed silent refresh keeps
  /// the list that was already loaded.
  Future<void> loadMotherTrees({bool silent = false}) async {
    final keepList = silent && _motherTreeState.value == LoadingState.loaded;
    if (!keepList) _motherTreeState.value = LoadingState.loading;
    try {
      final trees = await _service.fetchMotherTrees(
        gender: genderFilter,
        employmentStatus: employmentFilter,
        educationLevel: educationFilter,
        age: ageFilter,
      );
      _motherTreesData.assignAll(trees);
      _motherTreeState.value = LoadingState.loaded;
    } catch (e) {
      if (!keepList) _motherTreeState.value = LoadingState.error;
      AppLog.error('Profile', 'Error loading mother trees: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }



  // ─── Education Helpers ─────────────────────────────────────────────────────
  void prepareEducationForEdit(EducationHistory education, int index) {
    _editingEducationIndex = index;
    schoolController.text = education.school ?? '';
    degreeController.text = education.degree ?? '';
    majorController.text = education.major ?? '';
    fromDateController.text = TimeFormatHelper.formatDate(
      DateTime.parse(education.from ?? ''),
    );
    toDateController.text = TimeFormatHelper.formatDate(
      DateTime.parse(education.to ?? ''),
    );
    _isEducationOngoings.value = education.isCurrent ?? false;
  }

  void clearEducationControllers() {
    _editingEducationIndex = null;
    schoolController.clear();
    degreeController.clear();
    majorController.clear();
    fromDateController.clear();
    toDateController.clear();
    _isEducationOngoings.value = false;
  }

  // ─── Job Helpers ───────────────────────────────────────────────────────────
  void prepareJobForEdit(UserExperience job, int index) {
    _editingExperienceIndex = index;
    jobnameController.text = job.company ?? '';
    positionController.text = job.position ?? '';
    fromJobDateController.text = TimeFormatHelper.formatDate(
      DateTime.parse(job.from ?? ''),
    );
    toJobDateController.text = TimeFormatHelper.formatDate(
      DateTime.parse(job.to ?? ''),
    );
    _isJobOngoings.value = job.isCurrent ?? false;
  }

  void clearJobControllers() {
    _editingExperienceIndex = null;
    jobnameController.clear();
    positionController.clear();
    fromJobDateController.clear();
    toJobDateController.clear();
    _isJobOngoings.value = false;
  }

  // ─── Dispose ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    employmentController.dispose();
    educationController.dispose();
    universityController.dispose();
    fieldOfWorkController.dispose();
    spouseNameController.dispose();
    spousePhoneController.dispose();
    bioController.dispose();
    numberController.dispose();
    linkedinController.dispose();
    schoolController.dispose();
    degreeController.dispose();
    majorController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    jobnameController.dispose();
    positionController.dispose();
    fromJobDateController.dispose();
    toJobDateController.dispose();
    super.onClose();
  }
}
