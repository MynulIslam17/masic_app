import 'dart:io';
import 'package:dio/dio.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/helpers/image_upload_helper.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/banner/data/models/banner_model.dart';

class BannerRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  BannerRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
        _cacheService = cacheService;

  Future<List<BannerModel>> fetchBanner({bool isAll = false}) async {
    try {
      final response = await _apiService.get(isAll ? ApiConstants.bannerAll : ApiConstants.banner);
      final data = response.data['data'];

      final banners = _parseBanners(data);

      await _cacheService.put(
        ApiConstants.cacheBanner,
        banners.map((b) => b.toJson()).toList(),
      );

      return banners;
    } on AppException {
      return getCachedBanner();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<BannerModel> _parseBanners(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['banners'] is List) {
        return (data['banners'] as List)
            .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      if (data['result'] is List) {
        return (data['result'] as List)
            .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [BannerModel.fromJson(data)];
    }

    return [];
  }


  List<BannerModel> getCachedBanner() {
    try {
      final jsonList =
          _cacheService.get<List>(ApiConstants.cacheBanner, defaultValue: []) ??
              [];
      return jsonList.map((json) => BannerModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> createBanner(File image) async {
    try {
      final uploadImage = await ImageUploadHelper.prepareBannerImage(image);
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          uploadImage.path,
          filename: 'banner.jpg',
        ),
      });

      await _apiService.post(
        ApiConstants.bannerCreate,
        data: formData,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      await _apiService.delete(
        ApiConstants.bannerDelete(bannerId),
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