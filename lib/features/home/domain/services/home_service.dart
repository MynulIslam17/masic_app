import 'package:masic_generation/features/announcement/data/repositories/announcement_repository.dart';
import 'package:masic_generation/features/banner/data/repositories/banner_repository.dart';
import 'package:masic_generation/features/home/data/models/home_model.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class HomeService {
  final AnnouncementRepository _announcementRepository;
  final PollRepository _pollRepository;
  final BannerRepository _bannerRepository;

  HomeService({
    required AnnouncementRepository repository,
    required PollRepository pollRepository,
    required BannerRepository bannerRepository,
  }) : _announcementRepository = repository,
       _pollRepository = pollRepository,
       _bannerRepository = bannerRepository;


  Future<void> fetchAllHomeData() async {
    try {
      await Future.wait([
        _announcementRepository.getAnnouncements(1, 5),
        _pollRepository.getPolls(1, 5),
        _bannerRepository.fetchBanner(),

      ]);
    } on AppException {
      if (!hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _announcementRepository.hasCache('') || _pollRepository.hasCache() || _bannerRepository.hasCache();
  }

  HomeModel getCachedHomeData() {
    return HomeModel(
      announcements: _announcementRepository.getCachedAnnouncements(''),
      polls: _pollRepository.getCachedPolls(),
      banner: _bannerRepository.getCachedBanner(),
    );
  }
}
