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
import 'package:flutter_task/features/poll/data/models/poll_details_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:flutter_task/features/poll/domain/services/poll_services.dart';
import 'package:flutter_task/features/profile/presentation/controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PollController extends GetxController {
  final PollServices _service;
  final ConnectivityService _connectivityService;

  static PollController get to => Get.find();

  PollController({
    required PollServices service,
    required ConnectivityService connectivityService,
  }) : _service = service,
       _connectivityService = connectivityService;

  final searchController = TextEditingController();

  final RxString _selectedOptionId = ''.obs;
  String get selectedOptionId => _selectedOptionId.value;

  void selectOption(String optionId) {
    _selectedOptionId.value = optionId;
  }

  final answerController = TextEditingController();

  // ─── Loading States ────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get detailsLoadingState => _detailsLoadingState.value;


  final RxList<PollModel> _polls = <PollModel>[].obs;
  final _pollDetails = Rxn<PollDetailsModel>();

  List<PollModel> get polls => _polls;
  PollDetailsModel? get pollDetails => _pollDetails.value;

  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;

  bool get isLoadingMore => _isLoadingMore.value;

  final RxBool _hasMore = true.obs;

  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  // ─── Scroll Controller ─────────────────────────────────────────────────────
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  @override
  void onInit() {
    super.onInit();
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
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
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
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
        await _service.fetchPolls(
          1,
          10,
          search: searchController.text,
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

  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newPolls = await _service.fetchMorePolls(
        _currentPage,
        _limit,
      );

      if (newPolls.isNotEmpty) {
        _polls.addAll(newPolls);
        if (newPolls.length < _limit) {
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

  void _loadFromCache() {
    _polls.value = _service.getCachedPolls();

    assert(() {
      if (kDebugMode) {
        print('📦 Loaded from cache:');
        print('   Polls: ${_polls.length}');
      }
      return true;
    }());
  }

  Future<void> retry() async => await _loadData();

  Future<void> fetchPollDetails(
    String pollId,
  ) async {
    try {
      _detailsLoadingState.value = LoadingState.loading;
      final poll = await _service.fetchPollDetails(pollId);
      _detailsLoadingState.value = LoadingState.loaded;
      _pollDetails.value = poll;
    } catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      if (kDebugMode) {
        debugPrint('Create announcement error: $e');
      }
    }
    }

  Future<void> pollAnswer() async {
    try {
      await _service.pollAnswer(
        pollId: _pollDetails.value?.sId ?? '',
        optionId:   _selectedOptionId.value == '' ? null : _selectedOptionId.value,
        answer: answerController.text.trim().isEmpty ? null : answerController.text.trim(),
      );
    }catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      ToastMessageHelper.show(e.errorMessage);
      if (kDebugMode) {
        debugPrint('Create announcement error: $e');
      }
    }
  }
  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    super.onClose();
  }
}
