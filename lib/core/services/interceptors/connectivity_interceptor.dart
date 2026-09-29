import 'package:dio/dio.dart';

import '../connectivity_service.dart';

/// Fails offline requests immediately instead of letting them sit until the
/// connect timeout expires and surface as a misleading server error.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor(this._connectivityService);

  final ConnectivityService _connectivityService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_connectivityService.isConnected.value) return handler.next(options);

    // The cached value can lag behind the radio, so confirm before rejecting.
    if (await _connectivityService.checkConnectivity()) {
      return handler.next(options);
    }

    // Not forwarded to the other error interceptors: there is nothing to
    // retry while the device is offline.
    handler.reject(
      DioException.connectionError(
        requestOptions: options,
        reason: 'No internet connection',
      ),
    );
  }
}
