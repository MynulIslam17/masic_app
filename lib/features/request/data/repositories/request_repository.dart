import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_task/core/constants/api_constants.dart';
import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/core/services/api_service.dart';
import 'package:flutter_task/core/services/cache_service.dart';
import 'package:flutter_task/features/profile/data/models/user_model.dart';
import 'package:flutter_task/features/request/data/models/create_job_model.dart';
import 'package:flutter_task/features/request/data/models/request_model.dart';

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

      final users = (response.data['data'] as List)
          .map((e) => RequestModel.fromJson(e))
          .toList();
      await _cacheService.put(
        ApiConstants.cacheRequests,
        users.map((e) => e.toJson()).toList(),
      );
      return users;
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
