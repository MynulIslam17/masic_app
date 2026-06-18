import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';
import 'package:masic_generation/core/services/storage_service.dart';
import 'package:masic_generation/core/services/translation_service.dart';
import 'package:masic_generation/features/admin/dashboard/data/repositories/dashboard_repository.dart';
import 'package:masic_generation/features/admin/dashboard/domain/services/dashboard_service.dart';
import 'package:masic_generation/features/admin/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/announcement/domain/services/announcement_services.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository.dart';
import 'package:masic_generation/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:masic_generation/features/auth/domain/services/auth_services.dart';
import 'package:masic_generation/features/auth/presentation/controller/auth_controller.dart';
import 'package:masic_generation/features/banner/data/repositories/banner_repository.dart';
import 'package:masic_generation/features/banner/domain/services/banner_services.dart';
import 'package:masic_generation/features/banner/presentation/controllers/banner_controller.dart';
import 'package:masic_generation/features/home/domain/services/home_service.dart';
import 'package:masic_generation/features/notification/data/repositories/notification_repository.dart';
import 'package:masic_generation/features/notification/domain/services/notification_services.dart';
import 'package:masic_generation/features/notification/presentation/controllers/notification_controller.dart';
import 'package:masic_generation/features/home/presentation/controllers/home_controller.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import 'package:masic_generation/features/poll/domain/services/poll_services.dart';
import 'package:masic_generation/features/poll/presentation/controllers/poll_controller.dart';
import 'package:masic_generation/features/privacy/data/repositories/privacy_repository.dart';
import 'package:masic_generation/features/privacy/domain/services/privacy_services.dart';
import 'package:masic_generation/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:masic_generation/features/profile/data/repositories/profile_repository.dart';
import 'package:masic_generation/features/profile/domain/services/profile_service.dart';
import 'package:masic_generation/features/profile/presentation/controllers/profile_controller.dart';
import 'package:masic_generation/features/request/data/repositories/request_repository.dart';
import 'package:masic_generation/features/request/domain/services/request_services.dart';
import 'package:masic_generation/features/request/presentation/controllers/request_controller.dart';
import 'package:masic_generation/features/search/controller/search_controller.dart';
import 'package:masic_generation/features/translation/presentation/controller/translation_controller.dart';
import 'package:masic_generation/features/tree/data/repositories/tree_repository.dart';
import 'package:masic_generation/features/tree/domain/services/tree_service.dart';
import 'package:masic_generation/features/tree/presentation/controllers/tree_controller.dart';
import 'package:get/get.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    /// Connectivity Service
    final connectivityService = ConnectivityService();
    await connectivityService.init();
    Get.put<ConnectivityService>(connectivityService, permanent: true);

    /// Cache Service
    final cacheService = CacheService();
    await CacheService().init();
    Get.put<CacheService>(cacheService, permanent: true);

    /// Storage Service
    await Get.putAsync<StorageService>(() async {
      final storage = StorageService();
      await storage.init();
      return storage;
    });

    /// API Service
    final apiService = ApiService();
    apiService.init(connectivityService, Get.find<CacheService>());
    Get.put<ApiService>(apiService, permanent: true);

    /// Translation Service
    final translationService = TranslationService();
    await translationService.init();
    Get.put<TranslationService>(translationService, permanent: true);
    Get.put<TranslationController>(TranslationController(), permanent: true);

    Get.lazyPut<SearchHistoryController>(
          () => SearchHistoryController(
            cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );


    /// Auth
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

    Get.lazyPut<TreeRepository>(
      () => TreeRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TreeService>(
      () => TreeService(repository: Get.find<TreeRepository>()),
      fenix: true,
    );

    Get.lazyPut<TreeController>(
      () => TreeController(
        service: Get.find<TreeService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeService>(
      () => HomeService(
        repository: Get.find<AnnouncementRepository>(),
        pollRepository: Get.find<PollRepository>(),
        bannerRepository: Get.find<BannerRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        service: Get.find<HomeService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProfileService>(
      () => ProfileService(repository: Get.find<ProfileRepository>()),
      fenix: true,
    );

    Get.lazyPut<ProfileController>(
      () => ProfileController(
        service: Get.find<ProfileService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AnnouncementRepository>(
      () => AnnouncementRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AnnouncementServices>(
      () =>
          AnnouncementServices(repository: Get.find<AnnouncementRepository>()),
      fenix: true,
    );

    Get.lazyPut<AnnouncementController>(
      () => AnnouncementController(
        service: Get.find<AnnouncementServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PollRepository>(
      () => PollRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PollServices>(
      () => PollServices(repository: Get.find<PollRepository>()),
      fenix: true,
    );

    Get.lazyPut<PollController>(
      () => PollController(
        service: Get.find<PollServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RequestRepository>(
      () => RequestRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RequestServices>(
      () => RequestServices(repository: Get.find<RequestRepository>()),
      fenix: true,
    );

    Get.lazyPut<RequestController>(
      () => RequestController(
        service: Get.find<RequestServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<NotificationServices>(
      () => NotificationServices(repository: Get.find<NotificationRepository>()),
      fenix: true,
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        service: Get.find<NotificationServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<BannerRepository>(
      () => BannerRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<BannerServices>(
      () => BannerServices(repository: Get.find<BannerRepository>()),
      fenix: true,
    );

    Get.lazyPut<BannerController>(
      () => BannerController(
        service: Get.find<BannerServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DashboardRepository>(
      () => DashboardRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DashboardService>(
      () => DashboardService(repository: Get.find<DashboardRepository>()),
      fenix: true,
    );

    Get.lazyPut<DashboardController>(
      () => DashboardController(
        service: Get.find<DashboardService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<PrivacyRepository>(
      () => PrivacyRepository(
        apiService: Get.find<ApiService>(),
        cacheService: Get.find<CacheService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PrivacyServices>(
      () => PrivacyServices(repository: Get.find<PrivacyRepository>()),
      fenix: true,
    );
    Get.lazyPut<PrivacyController>(
      () => PrivacyController(
        service: Get.find<PrivacyServices>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
  }

  static void clear() {
    Get.deleteAll(force: true);
  }
}
