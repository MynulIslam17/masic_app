import 'package:dio/dio.dart';

/// On web the browser owns the connection pool, so Dio keeps its default
/// adapter.
HttpClientAdapter? createTunedHttpClientAdapter({
  required Duration connectTimeout,
  required Duration idleTimeout,
  int maxConnectionsPerHost = 8,
}) =>
    null;
