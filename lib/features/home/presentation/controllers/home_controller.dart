import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:get/get.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/services/home_service.dart';

class HomeController extends GetxController {
  final HomeService _service;
  final ConnectivityService _connectivityService;


  static HomeController get to => Get.find();

  HomeController({
    required HomeService service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  // State management
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  final RxString _errorMessage = ''.obs;

  String get errorMessage => _errorMessage.value;

  // Data
  final RxList<AnnouncementModel> _announcements = <AnnouncementModel>[].obs;

  final RxList<PollModel> _polls = <PollModel>[].obs;
  
  final RxString _bannerUrl = ''.obs;


  List<AnnouncementModel> get announcements => _announcements;
  List<PollModel> get polls => _polls;
  String get bannerUrl => _bannerUrl.value;


  final RxInt _currentAnnouncementPage = 0.obs;
  final RxInt _currentPollPage = 0.obs;

  int get currentAnnouncementPage => _currentAnnouncementPage.value;
  set currentAnnouncementPage(int value) => _currentAnnouncementPage.value = value;

  int get currentPollPage => _currentPollPage.value;
  set currentPollPage(int value) => _currentPollPage.value = value;



  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<void> _loadData() async {
    _errorMessage.value = '';
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
        await _service.fetchAllHomeData();
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) {
          _errorMessage.value = e.message;
          _loadingState.value = LoadingState.error;
        }
        if (kDebugMode) debugPrint('Fetch error: $e');
      }
    } catch (e) {
      if (_service.hasCache()) {
        _loadFromCache();
        _loadingState.value = LoadingState.loaded;
      } else {
        _errorMessage.value = e.errorMessage;
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  void _loadFromCache() {
    final homeData = _service.getCachedHomeData();
    _announcements.value = homeData.announcements;
    _polls.value = homeData.polls;
    _bannerUrl.value = homeData.banner?.imageUrl ?? '';
    // Debug logging
    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   Announcements home: ${_announcements.length}');
        print('   Polls home: ${_polls.length}');
        print('   Banner home: ${homeData.banner?.imageUrl}');
      }

      return true;
    }());
  }

  @override
  Future<void> refresh() async {
    _announcements.clear();
    _polls.clear();
    _currentAnnouncementPage.value = 0;
    _currentPollPage.value = 0;
    await _loadData();
  }
}
