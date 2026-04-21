import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/core/services/connectivity_service.dart';
import 'package:flutter_task/core/services/storage_service.dart';
import 'package:flutter_task/core/services/translation_service.dart';
import 'package:flutter_task/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_task/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_task/features/auth/domain/services/auth_services.dart';
import 'package:flutter_task/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter_task/features/translation/presentation/controller/translation_controller.dart';
import 'package:get/get.dart';


class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // ─────────────────────────────
    // 1. Connectivity Service
    // ─────────────────────────────
    final connectivityService = ConnectivityService();
    Get.put<ConnectivityService>(connectivityService, permanent: true);
    //connectivityService.listenAndNotify();

    // ─────────────────────────────
    // 3. Cache Service
    // ─────────────────────────────
    Get.put<CacheService>(CacheService(), permanent: true);

    // ─────────────────────────────
    // 4. Storage Service (ASYNC SAFE)
    // ─────────────────────────────
    await Get.putAsync<StorageService>(() async {
      final storage = StorageService();
      await storage.init();
      return storage;
    });

    // ─────────────────────────────
    // 2. API Service
    // ─────────────────────────────
    final apiService = ApiService();
    apiService.init(connectivityService, Get.find<CacheService>());
    Get.put<ApiService>(apiService, permanent: true);



    // Translation Service
    final translationService = TranslationService();
    await translationService.init();
    Get.put<TranslationService>(translationService, permanent: true);
    Get.put<TranslationController>(TranslationController(), permanent: true);

    // ✅ Auth — permanent
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      permanent: true,
    );

    Get.put<AuthService>(
      AuthService(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(authService: Get.find<AuthService>()),
      permanent: true,
    );
  }

  // ─────────────────────────────
  // GLOBAL CLEANUP (logout etc.)
  // ─────────────────────────────
  static void clear() {
    Get.deleteAll(force: true);
  }
}


