import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../cache_service.dart';

/// Attaches the bearer token and tears down the session when the server
/// rejects it.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._cacheService, {Future<void> Function()? onSessionExpired})
      : _onSessionExpired = onSessionExpired;

  /// Key used in `Options.extra` to send a request unauthenticated.
  static const String requiresAuthKey = 'requiresAuth';

  /// Endpoints that establish a session. A stale token must not be sent to
  /// them — some backends reject the header before they ever look at the
  /// credentials, which surfaces as "No token provided or bad format".
  static const Set<String> _sessionEndpoints = {
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.forgot,
    ApiConstants.otpVerify,
    ApiConstants.resetPassword,
  };

  /// Only these keys belong to the session; clearing the whole cache would
  /// also wipe the offline data the app falls back on.
  static const List<String> _sessionKeys = [
    AppConstants.accessToken,
    AppConstants.refreshToken,
    AppConstants.cacheUser,
    AppConstants.cacheUserRole,
    AppConstants.lastSyncedFcmToken,
  ];

  final CacheService _cacheService;
  final Future<void> Function()? _onSessionExpired;

  /// Guards against parallel 401s each triggering their own logout.
  bool _expiryHandled = false;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_requiresAuth(options)) {
      final token = _cacheService.get<String>(AppConstants.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        _expiryHandled = false;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    // Only a request that actually carried a token can have an expired
    // session. Without this, requests fired after logout would keep
    // re-triggering the logout flow.
    final isSessionExpiry = err.response?.statusCode == 401 &&
        options.headers.containsKey('Authorization') &&
        !_isSessionEndpoint(options);

    if (isSessionExpiry && !_expiryHandled) {
      _expiryHandled = true;
      await _cacheService.deleteAll(_sessionKeys);
      await _onSessionExpired?.call();
    }

    handler.next(err);
  }

  bool _requiresAuth(RequestOptions options) =>
      options.extra[requiresAuthKey] != false &&
      !_isSessionEndpoint(options);

  bool _isSessionEndpoint(RequestOptions options) =>
      _sessionEndpoints.any(options.path.contains);
}
