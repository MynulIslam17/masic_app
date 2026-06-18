import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/notification/data/models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  NotificationRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<List<NotificationModel>> getNotifications(
    int page,
    int limit,
  ) async {
    try {
      final response = await _apiService.get(
        ApiConstants.notifications(page, limit),
      );

      final notifications = (response.data['data'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      await _cacheService.put(
        ApiConstants.cacheNotifications,
        notifications.map((e) => e.toJson()).toList(),
      );

      return notifications;
    } on AppException {
      return getCachedNotifications();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<NotificationModel> getCachedNotifications() {
    try {
      final jsonList =
          _cacheService.get<List>(
            ApiConstants.cacheNotifications,
            defaultValue: [],
          ) ??
          [];
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<NotificationModel>> fetchMoreNotifications(
    int page,
    int limit,
  ) async {
    final response = await getNotifications(page, limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedNotifications();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        ApiConstants.cacheNotifications,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }

  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheNotifications);
  }
}
