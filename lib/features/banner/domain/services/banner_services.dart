import 'dart:io';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/features/banner/data/models/banner_model.dart';
import 'package:masic_generation/features/banner/data/repositories/banner_repository.dart';

class BannerServices {
  final BannerRepository _repository;

  BannerServices({required BannerRepository repository})
    : _repository = repository;

  Future<void> fetchBanner(int currentPage, int limit, {String? search}) async {
    try {
      await Future.wait([_repository.fetchBanner(isAll: true)]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  List<BannerModel> getCachedBanner() {
    return _repository.getCachedBanner();
  }





  Future<void> createBanner(File image) async {
    return await _repository.createBanner(image);
  }

  Future<void> deleteBanner(String bannerId) async {
    return await _repository.deleteBanner(bannerId);
  }



  bool hasCache() {
    return _repository.hasCache();
  }
}
