import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/time_format.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/routes/app_routes.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/profile/domain/services/profile_service.dart';
import 'package:flutter_task/features/tree/presentation/controllers/tree_controller.dart';
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

  final Rx<LoadingState> _updateRoleState = LoadingState.initial.obs;

  final Rx<LoadingState> _motherTreeState = LoadingState.initial.obs;
  final Rx<LoadingState> _blockUserState = LoadingState.initial.obs;

  LoadingState get motherTreeState => _motherTreeState.value;
  LoadingState get blockUserState => _blockUserState.value;


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

  DateTime? _selectedDate;

  // ─── Users List ────────────────────────────────────────────────────────────
  final RxList<UserModel> _usersData = <UserModel>[].obs;

  List<UserModel> get usersData => _usersData;

  // ─── Filters ───────────────────────────────────────────────────────────────
  final RxString _genderFilter = ''.obs;
  final RxString _employmentFilter = ''.obs;
  final RxString _educationFilter = ''.obs;
  final RxString _ageFilter = ''.obs;
  final RxBool _isJobOngoings = false.obs;
  final RxBool _isEducationOngoings = false.obs;
  final RxString _roleFilter = ''.obs;

  final searchController = TextEditingController();

  String get genderFilter => _genderFilter.value;

  String get employmentFilter => _employmentFilter.value;

  String get educationFilter => _educationFilter.value;

  String get ageFilter => _ageFilter.value;

  bool get isJobOngoings => _isJobOngoings.value;

  String get roleFilter => _roleFilter.value;

  bool get isEducationOngoings => _isEducationOngoings.value;

  void setRoleFilter(String value) => _roleFilter.value = value;



  // ─── Selection ─────────────────────────────────────────────────────────────
  final RxList<String> _selectedUserIds = <String>[].obs;

  List<String> get selectedUserIds => _selectedUserIds;

  final RxString _selectedUserId = 'gdh'.obs;

  String get selectedUserId => _selectedUserId.value;

  void selectSingleUser(String id) {
    _selectedUserId.value = id;
    debugPrint('Selected user ID: $id');
  }

  // ─── Edit Tracking ─────────────────────────────────────────────────────────
  int? _editingEducationIndex;
  int? _editingExperienceIndex;

  // ─── Pagination ────────────────────────────────────────────────────────────
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
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    ever(_roleFilter, (_) => refresh());
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

  // ─── File & Image ──────────────────────────────────────────────────────────
  void onFilePicked(PlatformFile value) {
    if (value.path != null) {
      _selectedCV.value = File(value.path!);
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


  bool isUserSelected(String userId) => _selectedUserIds.contains(userId);

  // ─── Date ──────────────────────────────────────────────────────────────────
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    dateOfBirthController.text = TimeFormatHelper.formatDateTime(
      date.toString(),
    );
  }

  void onChangedJob(value) => _isJobOngoings.value = value!;

  void onChangedEducation(value) => _isEducationOngoings.value = value!;

  // ─── Load Data ─────────────────────────────────────────────────────────────
  Future<void> loadData() async {
    try {
      final role = _roleFilter.value;
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
          role: role,
        );
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

  // ─── Load More ─────────────────────────────────────────────────────────────
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
        role: roleFilter,
      );

      if (newUsers.isNotEmpty) {
        _usersData.addAll(newUsers);
        if (newUsers.length < _limit) _hasMore.value = false;
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

  // ─── Cache ─────────────────────────────────────────────────────────────────
  void _loadFromCache() {
    _populateControllers(_service.getCachedUserData());
    _userData.value = _service.getCachedUserData();
    _usersData.value = _service.getCachedUsers(roleFilter);

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
      Get.back(canPop: true);

      _userData.value = updatedUser;

      _selectedDate = null;
      _editingEducationIndex = null;
      _editingExperienceIndex = null;

      clearEducationControllers();
      clearJobControllers();
      _populateControllers(updatedUser);
      _updateLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      debugPrint('❌ Update error: $e');
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
    bioController.text = data.bio ?? '';
    numberController.text = data.contact?.phone ?? '';
    linkedinController.text = data.contact?.linkedin ?? '';
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

  void clearAllFilters() {
    _genderFilter.value = '';
    _employmentFilter.value = '';
    _educationFilter.value = '';
    _ageFilter.value = '';
    retry();
  }


  Future<void> updateRole(String userId,String role) async {
    try {
      _updateRoleState.value = LoadingState.loading;
      await _service.updateRole(userId,role);
      _updateRoleState.value = LoadingState.loaded;
      await retry();
      Get.back(canPop: true);
    } catch (e) {
      _updateRoleState.value = LoadingState.error;
      debugPrint('❌ Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }


  Future<void> motherTreeSelect() async {
    try {
      _motherTreeState.value = LoadingState.loading;
      await _service.motherTreeSelect(_selectedUserId.value);
      _motherTreeState.value = LoadingState.loaded;
      Get.offAllNamed(AppRoutes.bottomNavUserBar);
    } catch (e) {
      _motherTreeState.value = LoadingState.error;
      debugPrint('❌ Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> addMember(String motherId) async {
    try {
      _motherTreeState.value = LoadingState.loading;
      await _service.addMember(_selectedUserId.value,motherId);
      _motherTreeState.value = LoadingState.loaded;
      await TreeController.to.loadData();
      Get.back(canPop: true);
      Get.back(canPop: true);
    } catch (e) {
      _motherTreeState.value = LoadingState.error;
      debugPrint('❌ Update error: $e');
      ToastMessageHelper.show(e.errorMessage);
    }
  }


  Future<void> blockUser(String userId,{required String  type}) async {
    try {
      _blockUserState.value = LoadingState.loading;
      await _service.blockUser(userId,type: type);
      _blockUserState.value = LoadingState.loaded;
      await retry();
      Get.back(canPop: true);
    } catch (e) {
      _blockUserState.value = LoadingState.error;
      debugPrint('❌ Update error: $e');
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
    dateOfBirthController.dispose();
    genderController.dispose();
    employmentController.dispose();
    educationController.dispose();
    universityController.dispose();
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
