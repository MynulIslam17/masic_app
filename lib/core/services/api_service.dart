import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';

import '../constants/api_constants.dart';
import '../exceptions/app_exceptions.dart';
import 'http/http_client_adapter_stub.dart'
    if (dart.library.io) 'http/http_client_adapter_io.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/upload_timeout_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  /// Short enough that a dead route fails fast and the retry interceptor can
  /// pick a fresh connection instead of hanging on the old one.
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(minutes: 2);

  Dio? _dioInstance;

  Dio get dio {
    final dio = _dioInstance;
    if (dio == null) {
      throw StateError('ApiService not initialized. Call init() first.');
    }
    return dio;
  }

  /// Sends the request without an `Authorization` header.
  static Options get withoutAuth =>
      Options(extra: {AuthInterceptor.requiresAuthKey: false});

  /// Forces retry behaviour for a single request, overriding the per-method
  /// default (non-idempotent calls are not replayed unless asked).
  static Options retry({bool enabled = true, Options? from}) {
    final options = from ?? Options();
    return options.copyWith(
      extra: {...?options.extra, RetryInterceptor.retryKey: enabled},
    );
  }

  /// [onSessionExpired] runs once when the server rejects the stored token, so
  /// the app can send the user back to login instead of silently looping on
  /// 401s.
  void init(
    ConnectivityService connectivityService,
    CacheService cacheService, {
    Future<void> Function()? onSessionExpired,
  }) {
    // Re-running init() would otherwise stack duplicate interceptors.
    _dioInstance?.close(force: true);

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: Map<String, dynamic>.from(ApiConstants.headers),
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _receiveTimeout,
      ),
    );

    final adapter = createTunedHttpClientAdapter(
      connectTimeout: _connectTimeout,
      idleTimeout: const Duration(seconds: 30),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;

    dio.interceptors.addAll([
      ConnectivityInterceptor(connectivityService),
      AuthInterceptor(cacheService, onSessionExpired: onSessionExpired),
      const UploadTimeoutInterceptor(_uploadTimeout),
      if (kDebugMode) const LoggingInterceptor(),
      RetryInterceptor(dio: dio),
    ]);

    _dioInstance = dio;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends a POST request to the specified [path].
  ///
  /// Not replayed automatically unless the connection was never established;
  /// pass [ApiService.retry] for endpoints that are safe to repeat.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends a PUT request to the specified [path], replacing the resource.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends a PATCH request to the specified [path], updating part of the
  /// resource.
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Sends a DELETE request to the specified [path].
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _send(
      () => dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  /// Uploads a single file to [path].
  ///
  /// ```dart
  /// final file = await MultipartFile.fromFile('/path/to/file.jpg');
  /// final response = await _apiService.uploadFile(
  ///   '/api/upload',
  ///   file: file,
  ///   fieldName: 'avatar',
  /// );
  /// ```
  Future<Response> uploadFile(
    String path, {
    MultipartFile? file,
    String? fieldName,
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return _send(
      () => dio.post(
        path,
        data: _formData(data, single: (fieldName, file)),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
    );
  }

  Future<Response> uploadFilePatch(
    String path, {
    MultipartFile? file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return _send(
      () => dio.patch(
        path,
        data: _formData(data, single: (fieldName, file)),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
    );
  }

  /// Uploads several files under the same [fieldName].
  Future<Response> uploadMultipleFiles(
    String path, {
    required List<MultipartFile> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return _send(
      () => dio.post(
        path,
        data: _formData(data, multiple: (fieldName, files)),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
    );
  }

  Future<Response> uploadMultipleFilesPatch(
    String path, {
    required List<MultipartFile> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return _send(
      () => dio.patch(
        path,
        data: _formData(data, multiple: (fieldName, files)),
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
    );
  }

  /// Uploads a file while reporting progress through [onSendProgress].
  Future<Response> uploadFileWithProgress(
    String path, {
    required MultipartFile file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) {
    return uploadFile(
      path,
      file: file,
      fieldName: fieldName,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  Future<Response> _send(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  FormData _formData(
    Map<String, dynamic>? data, {
    (String?, MultipartFile?)? single,
    (String, List<MultipartFile>)? multiple,
  }) {
    final map = <String, dynamic>{...?data};

    if (single != null) {
      final (field, file) = single;
      if (field != null && file != null) map[field] = file;
    }
    if (multiple != null) {
      final (field, files) = multiple;
      if (files.isNotEmpty) map[field] = files;
    }

    return FormData.fromMap(map);
  }

  /// Converts a [DioException] into a typed [AppException] so the UI layer can
  /// react to the cause instead of parsing strings.
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      // ─── Network ────────────────────────────────
      case DioExceptionType.connectionTimeout:
        return TimeoutException(
          'Connection timeout. Check your internet',
          error.message,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutException(
          'Request took too long to send. Try again',
          error.message,
        );

      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(
          'Server took too long to respond. Try again',
          error.message,
        );

      case DioExceptionType.connectionError:
        return NoInternetException(error.message);

      case DioExceptionType.badCertificate:
        return SSLException(error.message);

      case DioExceptionType.cancel:
        return RequestCancelledException(error.message);

      // ─── HTTP Response ───────────────────────────
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _parseErrorMessage(error.response?.data);

        return switch (statusCode) {
          // 4xx
          400 => BadRequestException(message, error.message),
          401 => UnauthorizedException(message, error.message),
          403 => ForbiddenException(message, error.message),
          404 => ResourceNotFoundException(message, error.message),
          405 => MethodNotAllowedException(error.message),
          406 => NotAcceptableException(error.message),
          408 => RequestTimeoutException(error.message),
          409 => ConflictException(message, error.message),
          410 => GoneException(error.message),
          413 => PayloadTooLargeException(
            'Upload is too large. Try a smaller banner image.',
            error.message,
          ),
          415 => UnprocessableException(
            'Unsupported media type',
            error.message,
          ),
          422 => ValidationException([message], error.message),
          429 => TooManyRequestsException(error.message),
          // 5xx
          500 => InternalServerException(error.message),
          501 => NotImplementedException(error.message),
          502 => ServerDownException(502, error.message),
          503 => ServiceUnavailableException(error.message),
          504 => GatewayTimeoutException(error.message),
          505 => HttpVersionException(error.message),
          507 => InsufficientStorageException(error.message),
          511 => NetworkAuthException(error.message),
          // fallback
          _ => ServerException(message, statusCode, error.message),
        };

      // ─── Unknown ─────────────────────────────────
      case DioExceptionType.unknown:
        final description = '${error.error ?? ''} ${error.message ?? ''}';
        if (description.contains('SocketException') ||
            description.contains('Connection closed') ||
            description.contains('Connection reset')) {
          return NoInternetException(error.message);
        }
        if (description.contains('HandshakeException') ||
            description.contains('CertificateException')) {
          return SSLException(error.message);
        }
        if (description.contains('HttpException')) {
          return ServerException('HTTP error occurred', null, error.message);
        }
        return UnknownException(error.message);
    }
  }

  /// Pulls a human-readable message out of whatever the server returned.
  ///
  /// A proxy answering for a dead backend replies with HTML rather than JSON,
  /// so anything non-map falls back to the generic message.
  String _parseErrorMessage(dynamic data) {
    if (data is! Map) return 'Server error';

    for (final key in const ['message', 'error', 'msg', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }

    final errors = data['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is String && first.trim().isNotEmpty) return first;
      if (first is Map) {
        final message = first['message'] ?? first['msg'];
        if (message is String && message.trim().isNotEmpty) return message;
      }
    }

    return 'Server error';
  }

  void dispose() {
    _dioInstance?.close(force: true);
    _dioInstance = null;
  }
}
