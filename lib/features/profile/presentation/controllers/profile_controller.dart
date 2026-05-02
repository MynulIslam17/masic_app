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
  })  : _service = service,
        _connectivityService = connectivityService;

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  final _selectedImage = Rxn<File>();
  final _userData = Rxn<UserModel>();
  DateTime? _selectedDate;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get updateLoadingState => _updateLoadingState.value;
  File? get selectedImage => _selectedImage.value;
  UserModel? get userData => _userData.value;

  void selectImage(XFile image) {
    _selectedImage.value = File(image.path);
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    dateOfBirthController.text = TimeFormatHelper.formatDateTime(date.toString());
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final genderController = TextEditingController();
  final employmentController = TextEditingController();
  final educationController = TextEditingController();
  final universityController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) loadData();
    });
    loadData();
  }

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
        await _service.fetchUserProfile();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _loadFromCache() {
    _populateControllers(_service.getCachedUserData());
    _userData.value = _service.getCachedUserData();
  }

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

  void _populateControllers(UserModel? data) {
    if (data == null) return;
    nameController.text = data.name ?? '';
    emailController.text = data.email ?? '';
    phoneController.text = data.spousePhone ?? '';
    dateOfBirthController.text = TimeFormatHelper.formatDateTime(data.dateOfBirth ?? '');
    genderController.text = data.gender ?? '';
    employmentController.text = data.employmentStatus ?? '';
    educationController.text = data.education ?? '';
    universityController.text = data.universityName ?? '';
  }

  Future<void> retry() => loadData();

  @override
  Future<void> refresh() async {
    _userData.value = null;
    _selectedDate = null;
    await loadData();
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    genderController.dispose();
    employmentController.dispose();
    educationController.dispose();
    universityController.dispose();
  }
}