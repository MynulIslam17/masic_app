import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/features/banner/data/models/banner_model.dart';

class BannerRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  BannerRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<BannerModel> fetchBanner() async {
    try {
      final response = await _apiService.get(ApiConstants.banner);
      final data = response.data['data'];
      final banner = BannerModel.fromJson(data);

      await _cacheService.put(ApiConstants.cacheBanner, banner.toJson());

      return banner;
    } on AppException {
      final cached = getCachedBanner();
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  BannerModel? getCachedBanner() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        ApiConstants.cacheBanner,
        defaultValue: null,
      );

      if (json == null) return null;
      return BannerModel.fromJson(json);
    } catch (e) {
      debugPrint('❌ Error getting cached banner data: $e');
      return null;
    }
  }

  Future<void> createBanner(File? image) async {
    try {
      await _apiService.uploadFile(
        ApiConstants.bannerCreate,
        file: image == null
            ? null
            : MultipartFile.fromFileSync(
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

  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheBanner);
  }
}
