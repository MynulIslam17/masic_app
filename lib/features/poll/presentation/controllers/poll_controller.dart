import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/core/helpers/toast_message_helper.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/core/services/search_service.dart';
import 'package:masic_generation/features/poll/data/models/create_poll_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_result_model.dart';
import 'package:masic_generation/features/poll/domain/services/poll_services.dart';
import 'package:get/get.dart';

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
  final answerController = TextEditingController();
  final titleTEController = TextEditingController();
  final decTEController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final RxList<TextEditingController> optionControllers =
      <TextEditingController>[].obs;

  // ─── Option Controllers ───────────────────────────────────────────────────
  void addOptionField() {
    optionControllers.add(TextEditingController());
  }

  void removeOptionField(int index) {
    optionControllers[index].dispose();
    optionControllers.removeAt(index);
  }

  List<Option>? get _pollOptions {
    final list = optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .map((t) => Option(text: t))
        .toList();
    return list.isEmpty ? null : list;
  }

  // ─── Selected Option ──────────────────────────────────────────────────────
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

  // ─── Loading States ───────────────────────────────────────────────────────
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _detailsLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _writeInLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _createLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _resultLoadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _deleteLoadingState = LoadingState.initial.obs;

  LoadingState get loadingState => _loadingState.value;

  LoadingState get detailsLoadingState => _detailsLoadingState.value;

  LoadingState get writeInLoadingState => _writeInLoadingState.value;

  LoadingState get createLoadingState => _createLoadingState.value;

  LoadingState get resultLoadingState => _resultLoadingState.value;
  LoadingState get deleteLoadingState => _deleteLoadingState.value;

  // ─── Data ─────────────────────────────────────────────────────────────────
  final RxList<PollModel> _polls = <PollModel>[].obs;
  final _pollDetails = Rxn<PollDetailsModel>();
  final _pollResult = Rxn<PollResultModel>();

  List<PollModel> get polls => _polls;

  PollDetailsModel? get pollDetails => _pollDetails.value;

  PollResultModel? get pollResult => _pollResult.value;

  // ─── Pagination ───────────────────────────────────────────────────────────
  int _currentPage = 1;
  final int _limit = 10;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMore = true.obs;
  bool _isRefreshing = false;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMore => _hasMore.value && !_isLoadingMore.value;

  // ─── Scroll Controller ────────────────────────────────────────────────────
  ScrollController? _scrollController;

  ScrollController? get scrollController => _scrollController;

  late final  SearchService<PollModel> search;

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    search = SearchService(fetcher: _fetchSearch);
    _initScrollController();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  // ─── Scroll ───────────────────────────────────────────────────────────────
  void _initScrollController() {
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController == null || _isRefreshing) return;
    final position = _scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        hasMore) {
      _loadMore();
    }
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore.value = true;
    _isLoadingMore.value = false;
  }

  void _syncHasMoreAfterFirstPage() {
    _hasMore.value = _polls.length >= _limit;
  }

  // ─── Poll List ────────────────────────────────────────────────────────────
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
        await _service.fetchPolls(1, _limit, search: searchController.text);
        _loadFromCache();
        _currentPage = 1;
        _syncHasMoreAfterFirstPage();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch error: $e');
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
      if (kDebugMode) debugPrint('Unexpected error: ${e.toString()}');
    }
  }

  Future<void> _loadMore() async {
    if (_isRefreshing || _isLoadingMore.value || !hasMore) return;

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
  }

  Future<List<PollModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedPolls()
        .where((a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
    if (fromCache.isNotEmpty) return fromCache;
    if (!_connectivityService.isConnected.value) return [];
    await _service.fetchPolls(1, 20, search: query);
    return _service
        .getCachedPolls()
        .where((a) => a.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  // ─── Refresh  ──────────────────────────────────────────────────────
  @override
  Future<void> refresh() async {
    _resetPagination();
    _isRefreshing = true;
    if (_scrollController?.hasClients ?? false) {
      _scrollController!.jumpTo(0);
    }
    try {
      await _loadData();
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── Poll Details ─────────────────────────────────────────────────────────
  Future<void> fetchPollDetails(String pollId, {bool showLoader = true}) async {
    try {
      if (showLoader) {
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

  Future<void> fetchPollResult(String pollId) async {
    try {
      _resultLoadingState.value = LoadingState.loading;
      _pollResult.value = null;
      _selectedOptionId.value = '';
      final poll = await _service.fetchPollResult(pollId);
      _pollResult.value = poll;
      _resultLoadingState.value = LoadingState.loaded;
    } catch (e) {
      _resultLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('fetchPollResult error: $e');
    }
  }

  // ─── Submit Answer ────────────────────────────────────────────────────────
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
      fetchPollDetails(_pollDetails.value?.id ?? '', showLoader: false);
      _writeInLoadingState.value = LoadingState.loaded;
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _writeInLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('pollAnswer error: $e');
    }
  }

  // ─── Create Poll ──────────────────────────────────────────────────────────
  Future<void> createPoll(String answerType) async {
    if (!formKey.currentState!.validate()) return;
    if (answerType == "selector" && optionControllers.length < 2) {
      ToastMessageHelper.show('Please add at least two options');
      return;
    }
    try {
      _createLoadingState.value = LoadingState.loading;
      final body = CreatePollBody(
        title: titleTEController.text.trim(),
        tagline: decTEController.text.trim(),
        answerType: answerType,
        options: _pollOptions,
      );
      await _service.createPoll(body);
      _createLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
      titleTEController.clear();
      decTEController.clear();
      for (final c in optionControllers) {
        c.dispose();
      }
      optionControllers.clear();
      await refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _createLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('createPoll error: $e');
    }
  }


  Future<void> deletePoll (String pollId) async {
    try {
      _deleteLoadingState.value = LoadingState.loading;
      await _service.deletePoll(pollId);
      _deleteLoadingState.value = LoadingState.loaded;
      Get.back(canPop: true);
      Get.back(canPop: true);
      await refresh();
    } catch (e) {
      ToastMessageHelper.show(e.errorMessage);
      _deleteLoadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('deletePoll error: $e');
    }
  }

  // ─── On Close ─────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    searchController.dispose();
    answerController.dispose();
    titleTEController.dispose();
    decTEController.dispose();
    _selectedOptionId.value = '';
    for (final c in optionControllers) {
      c.dispose();
    }
    optionControllers.clear();
    super.onClose();
  }
}
