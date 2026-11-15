import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/helpers/api_response_parser.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/profile/data/models/user_model.dart';
import 'package:masic_generation/features/request/data/models/create_job_model.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart';

class RequestRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  RequestRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<List<RequestModel>> fetchRequests({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.requests,
        queryParameters: {'page': page, 'limit': limit, 'searchTerm': search},
      );

      final users = ApiResponseParser.dataList(response.data)
          .map(RequestModel.fromJson)
          .toList();
      await _cacheService.put(
        ApiConstants.cacheRequests,
        users.map((e) => e.toJson()).toList(),
      );
      return users;
    } on ResourceNotFoundException {
      if (page == 1) {
        await _cacheService.put(ApiConstants.cacheRequests, const <dynamic>[]);
      }
      return const [];
    } on AppException {
      final cached = getCachedRequests();
      if (cached.isNotEmpty) return cached;
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<RequestModel>> fetchMoreRequests(int page, int limit) async {
    final response = await fetchRequests(page: page, limit: limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedRequests();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        ApiConstants.cacheRequests,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }

  /// The backend has no `GET /request/:id`, so a request opened from a
  /// notification is located by scanning pages. Does not touch the list cache.
  Future<RequestModel?> findRequestById(
    String id, {
    int pageSize = 50,
    int maxPages = 10,
  }) async {
    try {
      for (var page = 1; page <= maxPages; page++) {
        final response = await _apiService.get(
          ApiConstants.requests,
          queryParameters: {'page': page, 'limit': pageSize},
        );
        final body = response.data;
        final raw = body is Map ? body['data'] : body;
        if (raw is! List || raw.isEmpty) return null;
        for (final item in raw.whereType<Map>()) {
          if (item['_id']?.toString() == id) {
            return RequestModel.fromJson(Map<String, dynamic>.from(item));
          }
        }
        if (raw.length < pageSize) return null;
      }
      return null;
    } on ResourceNotFoundException {
      return null;
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<RequestModel> getCachedRequests() {
    try {
      final jsonList =
          _cacheService.get<List>(
            ApiConstants.cacheRequests,
            defaultValue: [],
          ) ??
          [];
      return jsonList.map((json) => RequestModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }


  Future<void> updateStatus(String requestId, String status,String? declineReason) async {
    try {
      await _apiService.patch(ApiConstants.requestStatus(requestId),
        data: {'status': status, 'declineReason' : declineReason},
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  Future<void> createRequest(CreateJobModel createRequestModel) async {
    try {
      final formData = {
        "data": jsonEncode(createRequestModel.toJson()),
      };

      await _apiService.post(
        ApiConstants.requestCreate,
        data: formData,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cacheRequests);
  }
}
