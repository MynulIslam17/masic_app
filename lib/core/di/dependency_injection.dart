import 'package:flutter_task/core/services/translation_service.dart';
import 'package:flutter_task/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/storage_service.dart';

class DependencyInjection {
  // Private constructor to prevent instantiation
  DependencyInjection._();

  static Future<void> init() async {
    // Core Services (Singletons)
    Get.lazyPut<CacheService>(() => CacheService(), fenix: true);
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<ConnectivityService>(() => ConnectivityService(), fenix: true);

    // StorageService — initialized eagerly because SharedPreferences.getInstance() is async
    final storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService, permanent: true);

    // Translation Service
    final translationService = TranslationService();
    await translationService.init();
    Get.put<TranslationService>(translationService, permanent: true);
    Get.put<TranslationController>(TranslationController(), permanent: true);

  }

  static void clear() {
    Get.deleteAll(force: true);
  }
}

