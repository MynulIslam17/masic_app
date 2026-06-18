import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/features/notification/data/models/notification_model.dart';
import 'package:masic_generation/features/notification/data/repositories/notification_repository.dart';

class NotificationServices {
  final NotificationRepository _repository;

  NotificationServices({required NotificationRepository repository})
    : _repository = repository;

  Future<void> fetchNotifications(int currentPage, int limit) async {
    try {
      await Future.wait([
        _repository.getNotifications(currentPage, limit),
      ]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<NotificationModel>> fetchMoreNotifications(
    int page,
    int limit,
  ) async {
    return await _repository.fetchMoreNotifications(page, limit);
  }

  List<NotificationModel> getCachedNotifications() {
    return _repository.getCachedNotifications();
  }

  bool hasCache() {
    return _repository.hasCache();
  }
}
