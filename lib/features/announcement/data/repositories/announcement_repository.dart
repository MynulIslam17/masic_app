import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/announcement/data/models/create_request_model.dart';

class AnnouncementRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  AnnouncementRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<List<AnnouncementModel>> getAnnouncements(int page, int limit,{String? search}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.announcements(page, limit),
        queryParameters: {'searchTerm': search},
      );

      final announcements = (response.data['data'] as List)
          .map((e) => AnnouncementModel.fromJson(e))
          .toList();

      await _cacheService.put(
        ApiConstants.cacheAnnouncements,
        announcements.map((e) => e.toJson()).toList(),
      );

      return announcements;
    } on AppException {
      return getCachedAnnouncements();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<AnnouncementModel> getCachedAnnouncements() {
    try {
      final jsonList =
          _cacheService.get<List>(
            ApiConstants.cacheAnnouncements,
            defaultValue: [],
          ) ??
          [];
      return jsonList.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<AnnouncementModel>> fetchMoreAnnouncements(
    int page,
    int limit,
  ) async {
    final response = await getAnnouncements(page, limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedAnnouncements();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        ApiConstants.cacheAnnouncements,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }

  Future<void> createAnnouncement(File? image, CreateRequestModel model) async {
    try {
      await _apiService.uploadFile(
        ApiConstants.announcementCreate,
        data: {'data' : jsonEncode(model.toJson())},
        fieldName: image == null ? null : 'image',
        file: image == null ? null : MultipartFile.fromFileSync(
          image.path,
          filename: image.path.split('/').last,
        ),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> updateStatus(String announcementId, String status) async {
    try {
      await _apiService.patch(ApiConstants.announcementStatus(announcementId),
        data: {'status': status},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheAnnouncements);
  }
}
