import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/enums/loading_state.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/extensions/app_extension.dart';
import 'package:flutter_task/core/helpers/toast_message_helper.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/features/poll/data/models/poll_details_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:flutter_task/features/poll/domain/services/poll_services.dart';
import 'package:get/get.dart';

class PollController extends GetxController {
  final PollServices _service;
  final ConnectivityService _connectivityService;

  static PollController get to => Get.find();

  PollController({
    required PollServices service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final searchController = TextEditingController();
  final answerController = TextEditingController();

  // ─── Selected Option ────────────────────────────────────────────────────────
  final RxString _selectedOptionId = ''.obs;

  String get selectedOptionId => _selectedOptionId.value;

  void selectOption(String optionId) {
    if (_pollDetails.value?.answered == true) return;

    _selectedOptionId.value = optionId;
    pollAnswer();
  }

  void initSelectedOption(String optionId) {
    if (_selectedOptionId.value.isEmpty) {
      _selectedOptionId.value = optionId;
    }
  }

  void initWriteInAnswer(String answer) {
    if (answerController.text.isEmpty) {
      answerController.text = answer;
    }
  }

  // ─── Loading States ─────────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _writeInLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;
  LoadingState get detailsLoadingState => _detailsLoadingState.value;
  LoadingState get writeInLoadingState => _writeInLoadingState.value;


  // ─── Data ────────────────────────────────────────────────────────────────────
  final RxList<PollModel> _polls = <PollModel>[].obs;
  final _pollDetails = Rxn<PollDetailsModel>();

  List<PollModel> get polls => _polls;
  PollDetailsModel? get pollDetails => _pollDetails.value;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;

  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  // ─── Scroll Controller ───────────────────────────────────────────────────────
  ScrollController? _scrollController;
  ScrollController? get scrollController => _scrollController;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    searchController.dispose();
    answerController.dispose();
    super.onClose();
  }

  // ─── Scroll ──────────────────────────────────────────────────────────────────
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

  // ─── Poll List ───────────────────────────────────────────────────────────────
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
        await _service.fetchPolls(1, 10, search: searchController.text);
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
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore.value || !hasMore) return;

    try {
      _isLoadingMore.value = true;
      _currentPage++;

      final newPolls = await _service.fetchMorePolls(_currentPage, _limit);

      if (newPolls.isNotEmpty) {
        _polls.addAll(newPolls);
        if (newPolls.length < _limit) _hasMore.value = false;
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
        print('📦 Loaded from cache: ${_polls.length} polls');
      }
      return true;
    }());
  }

  Future<void> retry() async => _loadData();

  // ─── Poll Details ─────────────────────────────────────────────────────────────
  Future<void> fetchPollDetails(String pollId,{bool showLoader = true}) async {
    try {
      if(showLoader){
        _detailsLoadingState.value = LoadingState.loading;
      }

      final poll = await _service.fetchPollDetails(pollId);
      _pollDetails.value = poll;
      _detailsLoadingState.value = LoadingState.loaded;
      _selectedOptionId.value = '';
      answerController.clear();
    } catch (e) {
      _detailsLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchPollDetails error: $e');
    }
  }

  // ─── Submit Answer ────────────────────────────────────────────────────────────
  Future<void> pollAnswer() async {
    try {
      _writeInLoadingState.value = LoadingState.loading;
      await _service.pollAnswer(
        pollId: _pollDetails.value?.id ?? '',
        optionId: _selectedOptionId.value.isEmpty
            ? null
            : _selectedOptionId.value,
        answer: answerController.text.trim().isEmpty
            ? null
            : answerController.text.trim(),
      );

      fetchPollDetails(_pollDetails.value?.id ?? '',showLoader: false);
      _writeInLoadingState.value = LoadingState.loaded;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _writeInLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('pollAnswer error: $e');
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    searchController.dispose();
    answerController.dispose();
    _selectedOptionId.value = '';
    super.dispose();
  }
}