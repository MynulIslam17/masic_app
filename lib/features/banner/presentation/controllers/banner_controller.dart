import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/announcement/data/models/create_request_model.dart';
import 'package:flutter_task/features/announcement/domain/services/announcement_services.dart';
import 'package:flutter_task/features/banner/domain/services/banner_services.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BannerController extends GetxController {
  final BannerServices _service;
  final ConnectivityService _connectivityService;

  static BannerController get to => Get.find();

  BannerController({
    required BannerServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  // final searchController = TextEditingController();
  //
  // final _selectedImage = Rxn<File>();
  //
  // File? get selectedImage => _selectedImage.value;
  //
  // // ─── Loading States ────────────────────────────────────────────────────────
  // final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  // final Rx<LoadingState> _updateLoadingState = LoadingState.initial.obs;
  // final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;
  //
  // LoadingState get updateLoadingState => _updateLoadingState.value;
  //
  // LoadingState get loadingState => _loadingState.value;
  //
  // LoadingState get createLoadingState => _createLoadingState.value;
  //
  // final titleTEController = TextEditingController();
  // final decTEController = TextEditingController();
  // final formKey = GlobalKey<FormState>();
  //
  // final RxList<AnnouncementModel> _announcements = <AnnouncementModel>[].obs;
  //
  // List<AnnouncementModel> get announcements => _announcements;
  //
  // int _currentPage = 1;
  // final int _limit = 10;
  // final RxBool _isLoadingMore = false.obs;
  //
  // bool get isLoadingMore => _isLoadingMore.value;
  //
  // final RxBool _hasMore = true.obs;
  //
  // bool get hasMore => _hasMore.value && !_isLoadingMore.value;
  //
  // // ─── Scroll Controller ─────────────────────────────────────────────────────
  // ScrollController? _scrollController;
  //
  // ScrollController? get scrollController => _scrollController;
  //
  // @override
  // void onInit() {
  //   super.onInit();
  //   _initScrollController();
  //   ever(_connectivityService.isConnected, (isConnected) {
  //     if (isConnected) _loadData();
  //   });
  //   _loadData();
  // }
  //
  // void selectImage(XFile image) {
  //   _selectedImage.value = File(image.path);
  // }
  //
  // void _initScrollController() {
  //   _scrollController = ScrollController();
  //   _scrollController!.addListener(_onScroll);
  // }
  //
  // void _onScroll() {
  //   if (_scrollController == null) return;
  //
  //   final position = _scrollController!.position;
  //
  //   if (position.pixels >= position.maxScrollExtent - 200 &&
  //       !_isLoadingMore.value &&
  //       hasMore) {
  //     _loadMore();
  //   }
  // }
  //
  // Future<void> _loadData() async {
  //   try {
  //     final hasCache = _service.hasCache();
  //     final isOnline = _connectivityService.isConnected.value;
  //
  //     if (hasCache) {
  //       _loadFromCache();
  //       _loadingState.value = LoadingState.loaded;
  //     } else {
  //       _loadingState.value = LoadingState.loading;
  //     }
  //
  //     if (!isOnline) return;
  //
  //     try {
  //       await _service.fetchAnnouncements(
  //         1,
  //         10,
  //         search: searchController.text,
  //       );
  //       _loadFromCache();
  //       _loadingState.value = LoadingState.loaded;
  //     } on AppException catch (e) {
  //       if (!hasCache) {
  //         _loadingState.value = LoadingState.error;
  //       }
  //       if (kDebugMode) debugPrint('Fetch error: $e');
  //     }
  //   } catch (e) {
  //     if (_service.hasCache()) {
  //       _loadFromCache();
  //       _loadingState.value = LoadingState.loaded;
  //     } else {
  //       _loadingState.value = LoadingState.error;
  //     }
  //     if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
  //   }
  // }
  //
  // Future<void> _loadMore() async {
  //   if (_isLoadingMore.value || !hasMore) return;
  //
  //   try {
  //     _isLoadingMore.value = true;
  //     _currentPage++;
  //
  //     final newAnnouncements = await _service.fetchMoreAnnouncements(
  //       _currentPage,
  //       _limit,
  //     );
  //
  //     if (newAnnouncements.isNotEmpty) {
  //       _announcements.addAll(newAnnouncements);
  //       if (newAnnouncements.length < _limit) {
  //         _hasMore.value = false;
  //       }
  //     } else {
  //       _hasMore.value = false;
  //     }
  //   } on AppException catch (e) {
  //     _currentPage--;
  //     if (kDebugMode) debugPrint('Load more error: $e');
  //   } catch (e) {
  //     _currentPage--;
  //     if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
  //   } finally {
  //     _isLoadingMore.value = false;
  //   }
  // }
  //
  // void _loadFromCache() {
  //   _announcements.value = _service.getCachedAnnouncements();
  //
  //   assert(() {
  //     if (kDebugMode) {
  //       print('📦 Loaded from cache:');
  //       print('   Announcements: ${_announcements.length}');
  //     }
  //     return true;
  //   }());
  // }
  //
  // @override
  // Future<void> refresh() async {
  //   _announcements.clear();
  //   _currentPage = 1;
  //   _hasMore.value = true;
  //   _isLoadingMore.value = false;
  //   await _loadData();
  // }
  //
  //
  // Future<void> createAnnouncement() async {
  //   if (!formKey.currentState!.validate()) return;
  //
  //   _createLoadingState.value = LoadingState.loading;
  //
  //   try {
  //     final users = ProfileController.to.selectedUserIds;
  //
  //     await _service.createAnnouncement(
  //       selectedImage,
  //       CreateRequestModel(
  //         title: titleTEController.text.trim(),
  //         description: decTEController.text.trim(),
  //         targetUsers: users.isEmpty ? null : users,
  //       ),
  //     );
  //
  //     _createLoadingState.value = LoadingState.loaded;
  //     if(users.isNotEmpty) Get.back(canPop: true);
  //     Get.back(canPop: true);
  //     titleTEController.clear();
  //     decTEController.clear();
  //     _selectedImage.value = null;
  //     users.clear();
  //     ToastMessageHelper.show('Created! Pending admin approval.');
  //   } on AppException catch (e) {
  //     _createLoadingState.value = LoadingState.error;
  //     ToastMessageHelper.show(e.errorMessage);
  //
  //     if (kDebugMode) {
  //       debugPrint('Create announcement error: $e');
  //     }
  //   }
  // }
  // @override
  // void onClose() {
  //   _scrollController?.removeListener(_onScroll);
  //   _scrollController?.dispose();
  //   _scrollController = null;
  //   titleTEController.dispose();
  //   decTEController.dispose();
  //   super.onClose();
  // }
}
