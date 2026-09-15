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
        return ApiConstants.cacheMyAnnouncements;
      default:
        return ApiConstants.cacheAnnouncements;
    }
  }

  Future<List<AnnouncementModel>> getAnnouncements(int page, int limit,{String? search,String? type}) async {
    final cacheKey = _cacheKey(type ?? '');
    try {
      final response = await _apiService.get(
        ApiConstants.announcements(page, limit),
        queryParameters: {'searchTerm': search,'type': type},
      );

      final announcements = (response.data['data'] as List)
          .map((e) => AnnouncementModel.fromJson(e))
          .toList();



        await _cacheService.put(
          cacheKey,
          announcements.map((e) => e.toJson()).toList(),
        );
      return announcements;
    } on AppException {
      return getCachedAnnouncements(cacheKey);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<AnnouncementModel> getCachedAnnouncements(String type) {
    final cacheKey = _cacheKey(type);
    try {
      final jsonList =
          _cacheService.get<List>(
            cacheKey,
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
      String? type,
  ) async {
    final cacheKey = _cacheKey(type ?? '');
    final response = await getAnnouncements(page, limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedAnnouncements(cacheKey);
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        cacheKey,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }

  Future<void> createAnnouncement(File? image, CreateRequestModel model) async {
    try {
      final uploadImage =
          image != null ? await ImageUploadHelper.prepareBannerImage(image) : null;
      await _apiService.uploadFile(
        ApiConstants.announcementCreate,
        data: {'data' : jsonEncode(model.toJson())},
        fieldName: uploadImage == null ? null : 'image',
        file: uploadImage == null
            ? null
            : MultipartFile.fromFileSync(
                uploadImage.path,
                filename: 'banner.jpg',
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
