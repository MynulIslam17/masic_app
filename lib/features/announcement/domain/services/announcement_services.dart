import 'dart:io';

import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/announcement/data/models/announcement_model.dart';
import 'package:flutter_task/features/announcement/data/models/create_request_model.dart';
import 'package:flutter_task/features/announcement/data/repositories/announcement_repository.dart';

class AnnouncementServices {
  final AnnouncementRepository _repository;

  AnnouncementServices({required AnnouncementRepository repository})
    : _repository = repository;

  Future<void> fetchAnnouncements(int currentPage, int limit, {String? search}) async {
    try {
      await Future.wait([_repository.getAnnouncements(currentPage, limit, search: search)]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<AnnouncementModel>> fetchMoreAnnouncements(
    int offset,
    int limit,
  ) async {
    return await _repository.fetchMoreAnnouncements(offset, limit);
  }



  List<AnnouncementModel> getCachedAnnouncements() {
    return _repository.getCachedAnnouncements();
  }


  Future<void> updateStatus(String announcementId, String status) async {
    return await _repository.updateStatus(announcementId, status);
  }


  Future<void> createAnnouncement(File? image, CreateRequestModel model) async {
    return await _repository.createAnnouncement(image, model);
  }


  bool hasCache() {
    return _repository.hasCache();
  }
}
