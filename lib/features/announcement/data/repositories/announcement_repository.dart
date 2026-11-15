import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/image_upload_helper.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/data/models/create_request_model.dart';

class AnnouncementRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  AnnouncementRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  String _cacheKey(String type) {
    switch (type) {
      case 'my':
      case 'announcements_my': // legacy key — must never fall back to the feed
      case ApiConstants.cacheMyAnnouncements:
        return ApiConstants.cacheMyAnnouncements;
      case 'pending':
      case ApiConstants.cachePendingAnnouncements:
        return ApiConstants.cachePendingAnnouncements;
      case 'declined':
      case ApiConstants.cacheDeclinedAnnouncements:
        return ApiConstants.cacheDeclinedAnnouncements;
      case 'approved':
      case ApiConstants.cacheApprovedAnnouncements:
        return ApiConstants.cacheApprovedAnnouncements;
      case 'in_progress':
      case ApiConstants.cacheInProgressAnnouncements:
        return ApiConstants.cacheInProgressAnnouncements;
      default:
        return ApiConstants.cacheAnnouncementFeed;
    }
  }

  Future<List<AnnouncementModel>> getAnnouncements(
    int page,
    int limit, {
    String? search,
    String? type,
    String? status,
  }) async {
    final isMyRequests = type == 'my';
    final effectiveStatus = status?.trim().isNotEmpty == true
        ? status!.trim()
        : null;
    final cacheKey = _cacheKey(isMyRequests ? 'my' : (effectiveStatus ?? ''));
    final isSearch = search?.trim().isNotEmpty == true;
    try {
      final endpoint = isMyRequests
          ? ApiConstants.myAnnouncements(page, limit)
          : ApiConstants.announcements(page, limit);
      final response = await _apiService.get(
        endpoint,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'searchTerm': search,
          if (type != null && type.isNotEmpty && type != 'my') 'type': type,
          if (effectiveStatus != null) 'status': effectiveStatus,
        },
      );

      final announcements = parseAnnouncementList(response.data);
      // Search results are transient and must not replace a full feed page.
      if (!isSearch) {
        final cached = page > 1
            ? getCachedAnnouncements(cacheKey)
            : const <AnnouncementModel>[];
        final merged = <AnnouncementModel>[];
        final seen = <String>{};
        for (final item in [...cached, ...announcements]) {
          final id = item.sId;
          if (id == null || seen.add(id)) merged.add(item);
        }
        await _cacheService.put(
          cacheKey,
          merged.map((e) => e.toJson()).toList(),
        );
      }
      return announcements;
    } on ResourceNotFoundException {
      // Older backends answered "no rows" with 404. An empty list is not an
      // error — surface it as an empty page so the UI shows its empty state.
      if (page == 1 && !isSearch) {
        await _cacheService.put(cacheKey, const <dynamic>[]);
      }
      return const <AnnouncementModel>[];
    } on AppException {
      // Cached pages are not a new page: replaying them duplicates list items.
      if (page > 1 || !hasCache(cacheKey)) rethrow;
      final cached = getCachedAnnouncements(cacheKey);
      if (!isSearch) return cached;
      final query = search!.trim().toLowerCase();
      return cached
          .where((item) => item.title?.toLowerCase().contains(query) ?? false)
          .toList();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Accepts `{data: [...]}`, `{data: {data: [...]}}`, `{data: null}` or a
  /// bare list. Anything else yields an empty list instead of a TypeError that
  /// would be reported as "Failed to load".
  static List<AnnouncementModel> parseAnnouncementList(dynamic body) {
    dynamic raw = body is Map ? body['data'] : body;
    if (raw is Map) raw = raw['data'] ?? raw['result'] ?? raw['items'];
    if (raw is! List) return const <AnnouncementModel>[];
    return raw
        .whereType<Map>()
        .map((e) => AnnouncementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Single announcement by id (`GET /announcement/:id`). Returns null when the
  /// backend says it does not exist (404) or the body carries no item.
  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.announcementStatus(id),
      );
      return parseAnnouncementDetail(response.data, id);
    } on ResourceNotFoundException {
      return null;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Accepts `{data: {...}}`, `{data: {data: {...}}}`, `{data: [...]}` or a
  /// bare object. A list is searched for [id] so a wrong item is never shown.
  static AnnouncementModel? parseAnnouncementDetail(dynamic body, String id) {
    dynamic raw = body is Map && body.containsKey('data') ? body['data'] : body;
    if (raw is Map && raw['_id'] == null && raw['data'] != null) {
      raw = raw['data'];
    }
    if (raw is List) {
      raw = raw.whereType<Map>().firstWhere(
        (e) => e['_id']?.toString() == id,
        orElse: () => const {},
      );
    }
    if (raw is! Map || raw['_id'] == null) return null;
    return AnnouncementModel.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Every list the app has cached (feed, pending, approved, mine, ...), so a
  /// details screen opened from Home or a notification can render instantly.
  AnnouncementModel? findCachedAnnouncement(String id) {
    for (final key in const [
      ApiConstants.cacheAnnouncementFeed,
      ApiConstants.cachePendingAnnouncements,
      ApiConstants.cacheApprovedAnnouncements,
      ApiConstants.cacheMyAnnouncements,
      ApiConstants.cacheDeclinedAnnouncements,
      ApiConstants.cacheInProgressAnnouncements,
    ]) {
      for (final item in getCachedAnnouncements(key)) {
        if (item.sId == id) return item;
      }
    }
    return null;
  }

  List<AnnouncementModel> getCachedAnnouncements(String type) {
    final cacheKey = _cacheKey(type);
    try {
      final jsonList =
          _cacheService.get<List>(cacheKey, defaultValue: []) ?? [];
      return jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AnnouncementModel>> fetchMoreAnnouncements(
    int page,
    int limit, {
    String? type,
    String? status,
    String? search,
  }) async {
    return getAnnouncements(
      page,
      limit,
      type: type,
      status: status,
      search: search,
    );
  }

  Future<void> createAnnouncement(
    List<File> images,
    CreateRequestModel model,
  ) async {
    try {
      final List<MultipartFile> files = [];
      for (int i = 0; i < images.length; i++) {
        final prepared = await ImageUploadHelper.prepareBannerImage(images[i]);
        files.add(
          MultipartFile.fromFileSync(prepared.path, filename: 'banner_$i.jpg'),
        );
      }
      await _apiService.uploadMultipleFiles(
        ApiConstants.announcementCreate,
        data: {'data': jsonEncode(model.toJson())},
        fieldName: 'images',
        files: files,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> updateStatus(
    String announcementId,
    String status, {
    String? declineReason,
  }) async {
    final reason = declineReason?.trim();
    try {
      await _apiService.patch(
        ApiConstants.announcementStatus(announcementId),
        data: {
          'status': status,
          if (status == 'declined' && reason != null && reason.isNotEmpty)
            'declineReason': reason,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _apiService.delete(ApiConstants.announcementStatus(announcementId));
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache(String type) {
    final cacheKey = _cacheKey(type);
    return _cacheService.containsKey(cacheKey);
  }
}
