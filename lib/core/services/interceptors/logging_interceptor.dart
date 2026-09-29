import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only request/response logger. Secrets are masked and long bodies are
/// truncated so a large upload or list response cannot flood the console.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor({this.maxBodyLength = 1000});

  static const String _separator =
      '──────────────────────────────────────────────────';
  static const Set<String> _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
  };

  final int maxBodyLength;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🔵 ──── REQUEST ────────────────────────────────────');
    debugPrint('   METHOD : ${options.method}');
    debugPrint('   URL    : ${options.uri}');
    debugPrint('   HEADERS: ${_maskHeaders(options.headers)}');
    if (options.data != null) {
      debugPrint('   BODY   : ${_truncate(options.data)}');
    }
    debugPrint('$_separator\n');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n🟢 ──── RESPONSE ───────────────────────────────────');
    debugPrint('   STATUS : ${response.statusCode}');
    debugPrint('   URL    : ${response.requestOptions.uri}');
    debugPrint('   BODY   : ${_truncate(response.data)}');
    debugPrint('$_separator\n');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n🔴 ──── ERROR ──────────────────────────────────────');
    debugPrint('   TYPE      : ${err.type.name}');
    debugPrint('   STATUS    : ${err.response?.statusCode}');
    debugPrint('   URL       : ${err.requestOptions.uri}');
    debugPrint('   MESSAGE   : ${err.message}');
    debugPrint('   ERROR BODY: ${_truncate(err.response?.data)}');
    debugPrint('$_separator\n');
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

  String _truncate(dynamic data) {
    if (data is FormData) {
      final fields = data.fields.map((e) => e.key).toList();
      final files = data.files.map((e) => e.key).toList();
      return 'FormData(fields: $fields, files: $files)';
    }
    final text = '$data';
    if (text.length <= maxBodyLength) return text;
    return '${text.substring(0, maxBodyLength)}… (${text.length} chars)';
  }
}
