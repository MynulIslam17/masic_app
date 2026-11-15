import 'dart:io';

import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/data/models/create_request_model.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';

class AnnouncementServices {
  final AnnouncementRepository _repository;

  AnnouncementServices({required AnnouncementRepository repository})
    : _repository = repository;

  Future<List<AnnouncementModel>> fetchAnnouncements(
    int currentPage,
    int limit, {
    String? search,
    String? type,
    String? status,
  }) async {
    return _repository.getAnnouncements(
      currentPage,
      limit,
      search: search,
      type: type,
      status: status,
    );
  }

  Future<List<AnnouncementModel>> fetchMoreAnnouncements(
    int offset,
    int limit, {
    String? type,
    String? status,
    String? search,
  }) async {
    return await _repository.fetchMoreAnnouncements(
      offset,
      limit,
      type: type,
      status: status,
      search: search,
    );
  }

  List<AnnouncementModel> getCachedAnnouncements(String type) {
    return _repository.getCachedAnnouncements(type);
  }

  Future<void> updateStatus(
    String announcementId,
    String status, {
    String? declineReason,
  }) async {
    return await _repository.updateStatus(
      announcementId,
      status,
      declineReason: declineReason,
    );
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    return await _repository.deleteAnnouncement(announcementId);
  }

  Future<void> createAnnouncement(
    List<File> images,
    CreateRequestModel model,
  ) async {
    return await _repository.createAnnouncement(images, model);
  }

  Future<AnnouncementModel?> fetchAnnouncementById(String id) {
    return _repository.getAnnouncementById(id);
  }

  AnnouncementModel? findCachedAnnouncement(String id) {
    return _repository.findCachedAnnouncement(id);
  }

  bool hasCache(String type) {
    return _repository.hasCache(type);
  }
}
