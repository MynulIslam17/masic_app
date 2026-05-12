import 'dart:io';

import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/announcement/data/models/create_request_model.dart';
import 'package:flutter_task/features/announcement/data/repositories/announcement_repository.dart';

class AnnouncementServices {
  final AnnouncementRepository _repository;

  AnnouncementServices({required AnnouncementRepository repository})
    : _repository = repository;

  Future<void> fetchAnnouncements(int currentPage, int limit, {String? search,String? type}) async {
    try {
      await Future.wait([_repository.getAnnouncements(currentPage, limit, search: search,type: type)]);
    } on AppException {
      if (!_repository.hasCache(type ?? '')) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<AnnouncementModel>> fetchMoreAnnouncements(
    int offset,
    int limit,
      String? type,
  ) async {
    return await _repository.fetchMoreAnnouncements(offset, limit, type);
  }



  List<AnnouncementModel> getCachedAnnouncements(String type) {
    return _repository.getCachedAnnouncements(type);
  }


  Future<void> updateStatus(String announcementId, String status) async {
    return await _repository.updateStatus(announcementId, status);
  }


  Future<void> createAnnouncement(File? image, CreateRequestModel model) async {
    return await _repository.createAnnouncement(image, model);
  }


  bool hasCache(String type) {
    return _repository.hasCache(type);
  }
}
