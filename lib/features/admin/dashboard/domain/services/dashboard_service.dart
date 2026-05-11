import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/admin/dashboard/data/models/dashboard_model.dart';
import 'package:flutter_task/features/admin/dashboard/data/repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository;

  DashboardService({required DashboardRepository repository})
    : _repository = repository;

  Future<void> fetchDashboard() async {
    try {
      await Future.wait([_repository.fetchDashboard()]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _repository.hasCache();
  }

  DashboardModel? getCachedDashboard() {
    return _repository.getCachedDashboard();
  }
}
