import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/domain/services/profile_service.dart';
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

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  LoadingState get updateLoadingState => _updateLoadingState.value;

  // ─── User Data ─────────────────────────────────────────────────────────────
  final _selectedImage = Rxn<File>();

  File? get selectedImage => _selectedImage.value;

  final _userData = Rxn<UserModel>();

  UserModel? get userData => _userData.value;

  DateTime? _selectedDate;

  // ─── Users List ────────────────────────────────────────────────────────────
  final RxList<UserModel> _usersData = <UserModel>[].obs;

  List<UserModel> get usersData => _usersData;

  // ─── Filters ───────────────────────────────────────────────────────────────
  final RxString _genderFilter = ''.obs;
  final RxString _employmentFilter = ''.obs;
  final RxString _educationFilter = ''.obs;
  final RxInt _ageFilter = 0.obs;

  final searchController = TextEditingController();

  String get genderFilter => _genderFilter.value;

  String get employmentFilter => _employmentFilter.value;

  String get educationFilter => _educationFilter.value;

  int get ageFilter => _ageFilter.value;


  // ─── Selection ─────────────────────────────────────────────────────────────
  final RxList<String> _selectedUserIds = <String>[].obs;
   List<String> get selectedUserIds => _selectedUserIds;

  void toggleUserSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
      debugPrint('Deselected Users: $userId');
    } else {
      _selectedUserIds.add(userId);
      debugPrint('Selected Users: $userId');
    }

    debugPrint('Selected Users: $_selectedUserIds');
  }

  bool isUserSelected(String userId) => _selectedUserIds.contains(userId);

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

  // ─── Text Controllers ──────────────────────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final genderController = TextEditingController();
  final employmentController = TextEditingController();
  final educationController = TextEditingController();
  final universityController = TextEditingController();

  // ─── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    loadData();
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
      loadMoreUsers();
    }
  }

  // ─── Image & Date ──────────────────────────────────────────────────────────
  void selectImage(XFile image) {
    _selectedImage.value = File(image.path);
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    dateOfBirthController.text = TimeFormatHelper.formatDateTime(
      date.toString(),
    );
  }

  // ─── Load Data (initial) ───────────────────────────────────────────────────
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
        await _service.fetchUserProfile(
          page: _currentPage,
          limit: _limit,
          gender: genderFilter,
          employmentStatus: employmentFilter,
          educationLevel: educationFilter,
          searchTerm: searchController.text,
          age: ageFilter,
        );
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

  // ─── Load More (pagination) ────────────────────────────────────────────────
  Future<void> loadMoreUsers() async {
    if (_isLoadingMore.value || !hasMoreUsers) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newUsers = await _service.fetchUsersMore(
        page: _currentPage,
        limit: _limit,
        gender: genderFilter,
        employmentStatus: employmentFilter,
        educationLevel: educationFilter,
        age: ageFilter,
      );

      if (newUsers.isNotEmpty) {
        _usersData.addAll(newUsers);
        if (newUsers.length < _limit) {
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
  // ─── Cache ─────────────────────────────────────────────────────────────────
  void _loadFromCache() {
    _populateControllers(_service.getCachedUserData());
    _userData.value = _service.getCachedUserData();
    _usersData.value = _service.getCachedUsers();

    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   Users: ${_usersData.length}');
      }
      return true;
    }());
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  Future<void> updateUserProfile() async {
    final user = _userData.value;
    if (user == null) {
      ToastMessageHelper.show('User data not loaded yet. Please try again.');
      return;
    }

    try {
      _updateLoadingState.value = LoadingState.loading;
      final dateOfBirth = _selectedDate != null
          ? _selectedDate!.toUtc().toIso8601String()
          : user.dateOfBirth;

      final updatedUser = await _service.updateUserProfile(
        UserModel(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          spousePhone: phoneController.text.trim(),
          dateOfBirth: dateOfBirth,
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
          fieldOfWork: user.fieldOfWork,
          spouseName: user.spouseName,
          linkedinLink: user.linkedinLink,
        ),
        image: selectedImage,
      );

      _userData.value = updatedUser;
      _selectedDate = null;
      _populateControllers(updatedUser);
      _updateLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  void _populateControllers(UserModel? data) {
    if (data == null) return;
    nameController.text = data.name ?? '';
    emailController.text = data.email ?? '';
    phoneController.text = data.spousePhone ?? '';
    dateOfBirthController.text = TimeFormatHelper.formatDateTime(
      data.dateOfBirth ?? '',
    );
    genderController.text = data.gender ?? '';
    employmentController.text = data.employmentStatus ?? '';
    educationController.text = data.education ?? '';
    universityController.text = data.universityName ?? '';
  }

  Future<void> retry() => loadData();

  @override
  Future<void> refresh() async {
    _currentPage = 1;
    _usersData.clear();
    _userData.value = null;
    _selectedDate = null;
    await loadData();
  }

  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    employmentController.dispose();
    educationController.dispose();
    universityController.dispose();
    super.onClose();
  }
}
