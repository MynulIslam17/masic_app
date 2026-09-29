import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Keeps sockets alive between calls so follow-up requests skip the DNS
/// lookup and TLS handshake, which is where most flaky-network failures on
/// mobile come from.
HttpClientAdapter? createTunedHttpClientAdapter({
  required Duration connectTimeout,
  required Duration idleTimeout,
  int maxConnectionsPerHost = 8,
}) {
  return IOHttpClientAdapter(
    createHttpClient: () => HttpClient()
      ..connectionTimeout = connectTimeout
      ..idleTimeout = idleTimeout
      ..maxConnectionsPerHost = maxConnectionsPerHost,
  );
}
