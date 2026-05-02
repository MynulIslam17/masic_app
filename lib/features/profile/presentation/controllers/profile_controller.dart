import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
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

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;

  final _selectedImage = Rxn<File>();

  final _userData = Rxn<UserModel>();

  LoadingState get loadingState => _loadingState.value;

  LoadingState get updateLoadingState => _updateLoadingState.value;

  File? get selectedImage => _selectedImage.value;

  UserModel? get userData => _userData.value;

  void selectImage(XFile image) {
    _selectedImage.value = File(image.path);
  }

  final  nameController = TextEditingController();
  final  emailController = TextEditingController();
  final  phoneController = TextEditingController();
  final  dateOfBirthController = TextEditingController();
  final  genderController = TextEditingController();
  final  employmentController = TextEditingController();
  final  educationController = TextEditingController();
  final  universityController = TextEditingController();


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
      if (kDebugMode) debugPrint('Unexpected error: ${e.errorMessage}');
    }
  }

  void _loadFromCache() {
    _userData.value = _service.getCachedUserData();
  }

  Future<void> updateUserProfile() async {
    try {
      if (selectedImage == null) return;
      _updateLoadingState.value = LoadingState.loading;
      final user = _userData.value!;
      final updatedUser = await _service.updateUserProfile(
        UserModel.fromJson(user.toMap()),
        image: selectedImage!,
      );
      _userData.value = updatedUser;
      _updateLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _updateLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
    }
  }

  Future<void> retry() => loadData();

  @override
  Future<void> refresh() async {
    _userData.value = null;
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
