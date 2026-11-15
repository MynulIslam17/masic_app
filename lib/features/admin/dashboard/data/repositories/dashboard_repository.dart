import 'package:masic_generation/core/helpers/app_log.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/admin/dashboard/data/models/dashboard_model.dart';

class DashboardRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  DashboardRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<DashboardModel> fetchDashboard() async {
    try {
      final response = await _apiService.get(ApiConstants.dashboard);
      final data = response.data['data'];
      final dashboard = DashboardModel.fromJson(data);

      await _cacheService.put(ApiConstants.cacheDashboard, dashboard.toJson());

      return dashboard;
    } on AppException {
      final cached = getCachedDashboard();
      if (cached != null) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  DashboardModel? getCachedDashboard() {
    try {
      final json = _cacheService.get<Map<String, dynamic>>(
        ApiConstants.cacheDashboard,
        defaultValue: null,
      );

      if (json == null) return null;
      return DashboardModel.fromJson(json);
    } catch (e) {
      AppLog.error('Dashboard', 'Error getting cached user data: $e');
      return null;
    }
  }

  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheDashboard);
  }
}
