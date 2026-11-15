import 'package:masic_generation/core/helpers/app_log.dart';
import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Retries requests that failed for a transient reason (dropped socket,
/// timeout, or a gateway/proxy error such as 502) with exponential backoff.
///
/// Set `Options(extra: {RetryInterceptor.retryKey: false})` to opt a single
/// request out, or `true` to force a retry on a method that is not retried by
/// default.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.maxDelay = const Duration(seconds: 5),
  }) : _dio = dio;

  /// Key used in `Options.extra` to force retry on or off per request.
  static const String retryKey = 'retry';
  static const String _attemptKey = '_retryAttempt';

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  final Random _random = Random();

  /// Status codes that mean "the backend was not reachable / not ready",
  /// not "the request was wrong".
  static const Set<int> _retryableStatusCodes = {408, 425, 429, 502, 503, 504};

  /// Methods that are safe to replay because repeating them cannot create
  /// duplicate data.
  static const Set<String> _idempotentMethods = {
    'GET',
    'HEAD',
    'OPTIONS',
    'PUT',
    'DELETE',
  };

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxRetries || !_shouldRetry(err)) {
      return handler.next(err);
    }

    // A FormData body is consumed once it is sent, so it has to be rebuilt.
    if (options.data is FormData) {
      final clone = _cloneFormData(options.data as FormData);
      if (clone == null) return handler.next(err);
      options.data = clone;
    }

    final delay = _delayFor(attempt, err);
    if (kDebugMode) {
      AppLog.warn('API', 
        'RETRY ${attempt + 1}/$maxRetries in ${delay.inMilliseconds}ms '
        '→ ${options.method} ${options.path}',
      );
    }
    await Future<void>.delayed(delay);

    options.extra[_attemptKey] = attempt + 1;

    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (!_isTransient(err)) return false;

    final override = err.requestOptions.extra[retryKey];
    if (override is bool) return override;

    if (_idempotentMethods.contains(err.requestOptions.method.toUpperCase())) {
      return true;
    }

    // POST/PATCH may have already been applied server-side, so only replay
    // them when the connection never got established.
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  bool _isTransient(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return _retryableStatusCodes.contains(err.response?.statusCode);
      case DioExceptionType.unknown:
        final description = '${err.error ?? ''} ${err.message ?? ''}';
        return description.contains('SocketException') ||
            description.contains('Connection closed') ||
            description.contains('Connection reset');
      default:
        return false;
    }
  }

  Duration _delayFor(int attempt, DioException err) {
    final retryAfter = _retryAfter(err);
    if (retryAfter != null) return retryAfter > maxDelay ? maxDelay : retryAfter;

    final backoff = baseDelay.inMilliseconds * pow(2, attempt).toInt();
    final jitter = _random.nextInt(250);
    return Duration(
      milliseconds: min(backoff + jitter, maxDelay.inMilliseconds),
    );
  }

  /// Honours the `Retry-After` header that proxies send with 429/503.
  Duration? _retryAfter(DioException err) {
    final value = err.response?.headers.value('retry-after');
    final seconds = value == null ? null : int.tryParse(value.trim());
    return seconds == null ? null : Duration(seconds: seconds);
  }

  FormData? _cloneFormData(FormData formData) {
    try {
      return formData.clone();
    } catch (_) {
      // Stream-backed files cannot be replayed.
      return null;
    }
  }
}
