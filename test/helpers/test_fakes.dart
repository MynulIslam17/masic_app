import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/core/services/connectivity_service.dart';

class RecordedApiCall {
  final String method;
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final dio.Options? options;

  RecordedApiCall({
    required this.method,
    required this.path,
    this.data,
    this.queryParameters,
    this.options,
  });

  @override
  String toString() => '$method $path query=$queryParameters data=$data';
}

class FakeCacheService extends Fake implements CacheService {
  final Map<String, dynamic> store = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> put(String key, dynamic value) async {
    store[key] = value;
  }

  @override
  T? get<T>(String key, {T? defaultValue}) {
    if (!store.containsKey(key)) return defaultValue;
    final value = store[key];
    if (value is Map && T == Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k.toString(), v)) as T;
    }
    return value as T?;
  }

  @override
  bool containsKey(String key) => store.containsKey(key);

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final k in keys) {
      store.remove(k);
    }
  }

  @override
  Future<void> clear() async {
    store.clear();
  }

  @override
  Future<void> dispose() async {}
}

class FakeConnectivityService extends Fake implements ConnectivityService {
  @override
  final RxBool isConnected = true.obs;

  @override
  Future<bool> checkConnectivity() async => isConnected.value;
}

class FakeApiService extends Fake implements ApiService {
  final List<RecordedApiCall> recordedCalls = [];
  final Map<String, dynamic> customResponses = {};

  void clearRecordedCalls() {
    recordedCalls.clear();
  }

  bool hasCalled(String method, String pathPrefix) {
    return recordedCalls.any((c) {
      if (c.method != method) return false;
      if (c.path == pathPrefix) return true;
      if (c.path.startsWith('$pathPrefix?') || c.path.startsWith('$pathPrefix/')) {
        // Special case: don't match '/api/v1/users/me' when asking for '/api/v1/users'
        if (pathPrefix == ApiConstants.usersProfile && c.path == ApiConstants.userProfile) {
          return false;
        }
        return true;
      }
      return false;
    });
  }

  List<RecordedApiCall> callsMatching(String method, String path) {
    return recordedCalls.where((c) {
      if (c.method != method) return false;
      if (c.path == path) return true;
      if (path == ApiConstants.usersProfile && c.path == ApiConstants.userProfile) {
        return false;
      }
      return c.path.startsWith(path);
    }).toList();
  }

  dynamic _resolveResponse(String path) {
    if (customResponses.containsKey(path)) {
      return customResponses[path];
    }
    if (path == ApiConstants.userProfile) {
      return {
        'success': true,
        'data': {
          '_id': 'u1',
          'email': 'user@example.com',
          'name': 'Test User',
          'role': 'user',
          'treeJoinStatus': 'placed',
        },
      };
    }
    if (path == ApiConstants.usersProfile || path.startsWith('/api/v1/users')) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'u1',
            'email': 'user1@example.com',
            'name': 'User 1',
            'role': 'user',
          },
        ],
        'meta': {'total': 1, 'page': 1, 'limit': 10, 'totalPage': 1},
      };
    }
    if (path == ApiConstants.tree) {
      return {
        'success': true,
        'data': {
          'treeInfo': {'_id': 'info_1'},
          'root': {
            'nodeId': 'root_1',
            'fullName': 'Root Ancestor',
          },
        },
      };
    }
    if (path == ApiConstants.dashboard) {
      return {
        'success': true,
        'data': {
          'ageRange': [],
          'gender': [],
          'commonNames': [],
        },
      };
    }
    if (path.startsWith('/api/v1/announcement')) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'a1',
            'title': 'Test Announcement',
            'description': 'Description',
            'bannerUrls': [],
          },
        ],
      };
    }
    if (path.startsWith('/api/v1/poll')) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'p1',
            'title': 'Sample Poll Title',
            'tagline': 'Poll Tagline',
          },
        ],
      };
    }
    if (path == ApiConstants.requests) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'r1',
            'status': 'pending',
            'type': 'job',
          },
        ],
      };
    }
    if (path.startsWith('/api/v1/banner')) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'b1',
            'imageUrl': 'https://example.com/banner.jpg',
          },
        ],
      };
    }
    if (path.startsWith('/api/v1/notification')) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'n1',
            'title': 'Notification 1',
            'message': 'Hello',
          },
        ],
      };
    }
    if (path == ApiConstants.privacyPolicy ||
        path == ApiConstants.aboutUs ||
        path == ApiConstants.termsAndCondition) {
      return {
        'success': true,
        'data': {'description': 'Policy text'},
      };
    }
    if (path == ApiConstants.motherTrees) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'm1',
            'name': 'Mother Tree 1',
          },
        ],
      };
    }
    if (path == ApiConstants.login) {
      return {
        'success': true,
        'data': {
          'accessToken': 'jwt_access_token_123',
          'user': {
            '_id': 'u1',
            'email': 'user@example.com',
            'name': 'Test User',
            'role': 'user',
            'isVerified': true,
            'treeJoinStatus': 'placed',
          },
        },
      };
    }
    return {'success': true, 'data': {}};
  }

  @override
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'POST',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'PATCH',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'PUT',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'DELETE',
      path: path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> uploadFilePatch(
    String path, {
    dio.MultipartFile? file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'PATCH',
      path: path,
      data: data,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }

  @override
  Future<dio.Response> uploadMultipleFiles(
    String path, {
    required List<dio.MultipartFile> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    recordedCalls.add(RecordedApiCall(
      method: 'POST',
      path: path,
      data: data,
      options: options,
    ));
    return dio.Response(
      requestOptions: dio.RequestOptions(path: path),
      data: _resolveResponse(path),
      statusCode: 200,
    );
  }
}
