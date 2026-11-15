import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request/response logger with readable, complete bodies by default.
/// Authentication headers are masked.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this.maxBodyLength});

  static const String _separator =
      '──────────────────────────────────────────────────';
  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
  };

  final int? maxBodyLength;

  static const String _requestColor = '\x1B[34m';
  static const String _responseColor = '\x1B[32m';
  static const String _errorColor = '\x1B[31m';
  static const String _resetColor = '\x1B[0m';

  void _printBlock(String color, String label, List<String> lines) {
    if (!kDebugMode) return;

    // iOS system logging escapes ANSI codes. The VM logging channel
    // preserves them for IDE debug consoles and prints `[API]` itself.
    final useDeveloperLog =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    for (final line in lines.expand((entry) => entry.split('\n'))) {
      if (useDeveloperLog) {
        developer.log('$color$line$_resetColor', name: 'API');
      } else {
        // A label on every line also lets Android Studio's Grep Console
        // color complete bodies when its Flutter console ignores ANSI codes.
        debugPrint('$color[API] $line$_resetColor');
      }
    }
  }

  static const String _startTimeKey = 'app_log_started_at';

  /// `  (123 ms)` when the request start time is known.
  String _elapsed(RequestOptions options) {
    final started = options.extra[_startTimeKey];
    if (started is! int) return '';
    final ms = DateTime.now().millisecondsSinceEpoch - started;
    return '  ($ms ms)';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    _printBlock(_requestColor, 'REQUEST', [
      '',
      '🔵 REQUEST   ${options.method} ${options.uri}',
      '   HEADERS: ${_maskHeaders(options.headers)}',
      if (options.data != null) '   BODY   : ${_formatBody(options.data)}',
      _separator,
    ]);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final request = response.requestOptions;
    _printBlock(_responseColor, 'RESPONSE', [
      '',
      '🟢 RESPONSE  ${response.statusCode}  ${request.method} ${request.uri}'
          '${_elapsed(request)}',
      '   BODY   : ${_formatBody(response.data)}',
      _separator,
    ]);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    _printBlock(_errorColor, 'ERROR', [
      '',
      '🔴 ERROR     ${err.response?.statusCode ?? err.type.name}  '
          '${request.method} ${request.uri}${_elapsed(request)}',
      if (err.message != null) '   MESSAGE: ${err.message}',
      '   BODY   : ${_formatBody(err.response?.data)}',
      _separator,
    ]);
    handler.next(err);
  }

  /// Keeps enough of a secret to tell "missing", "empty" and "present" apart
  /// while never printing the value itself.
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (!_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, value);
      }
      final text = '$value';
      return MapEntry(key, text.isEmpty ? '<empty>' : '*** (${text.length} chars)');
    });
  }

  String _formatBody(dynamic data) {
    if (data is FormData) {
      data = {
        'fields': [
          for (final field in data.fields)
            {'name': field.key, 'value': field.value},
        ],
        'files': [
          for (final file in data.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'bytes': file.value.length,
              'contentType': file.value.contentType?.toString(),
            },
        ],
      };
    }
    String text;
    try {
      text = const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      text = '$data';
    }
    final limit = maxBodyLength;
    if (limit == null || text.length <= limit) return text;
    return '${text.substring(0, limit)}… (${text.length} chars)';
  }
}
