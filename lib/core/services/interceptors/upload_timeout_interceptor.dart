import 'package:dio/dio.dart';

/// Gives multipart requests a longer window than a plain JSON call, so a slow
/// upload on mobile data is not cut short by the default timeouts.
class UploadTimeoutInterceptor extends Interceptor {
  const UploadTimeoutInterceptor(this.timeout);

  final Duration timeout;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is FormData) {
      if ((options.sendTimeout ?? Duration.zero) < timeout) {
        options.sendTimeout = timeout;
      }
      if ((options.receiveTimeout ?? Duration.zero) < timeout) {
        options.receiveTimeout = timeout;
      }
    }
    handler.next(options);
  }
}
