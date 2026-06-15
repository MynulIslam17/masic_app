import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/features/privacy/data/repositories/privacy_repository.dart';

class PrivacyServices {
  final PrivacyRepository _repository;

  PrivacyServices({required PrivacyRepository repository})
      : _repository = repository;

  // ─── Fetch all three in parallel ───────────────────────────────────────────
  Future<void> fetchPrivacy() async {
    try {
      await Future.wait([
        _repository.fetchOne('privacy'),
        _repository.fetchOne('about'),
        _repository.fetchOne('terms'),
      ]);
    } on AppException {
      if (!_repository.hasCache()) rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  // ─── Cache ─────────────────────────────────────────────────────────────────
  String? getCached(String key) => _repository.getCached(key);

  bool hasCache() => _repository.hasCache();

  // ─── Update ────────────────────────────────────────────────────────────────
  Future<void> updatePrivacy(String key, String description) async {
    try {
      await _repository.update(key, description);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}