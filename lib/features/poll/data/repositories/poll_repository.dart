import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:masic_generation/core/constants/api_constants.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/core/services/api_service.dart';
import 'package:masic_generation/core/services/cache_service.dart';
import 'package:masic_generation/features/announcement/data/models/announcement_model.dart';
import 'package:masic_generation/features/announcement/data/models/create_request_model.dart';
import 'package:masic_generation/features/poll/data/models/create_poll_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_result_model.dart';

class PollRepository {
  final ApiService _apiService;
  final CacheService _cacheService;

  PollRepository({
    required ApiService apiService,
    required CacheService cacheService,
  }) : _apiService = apiService,
       _cacheService = cacheService;

  Future<List<PollModel>> getPolls(
    int page,
    int limit, {
    String? search,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.polls(page, limit),
        queryParameters: {'searchTerm': search},
      );

      final announcements = (response.data['data'] as List)
          .map((e) => PollModel.fromJson(e))
          .toList();

      await _cacheService.put(
        ApiConstants.cachePolls,
        announcements.map((e) => e.toJson()).toList(),
      );

      return announcements;
    } on AppException {
      return getCachedPolls();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  List<PollModel> getCachedPolls() {
    try {
      final jsonList =
          _cacheService.get<List>(ApiConstants.cachePolls, defaultValue: []) ??
          [];
      return jsonList.map((json) => PollModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PollModel>> fetchMorePolls(int page, int limit) async {
    final response = await getPolls(page, limit);
    if (response.isNotEmpty) {
      final currentCached = getCachedPolls();
      final newList = [...currentCached, ...response];
      await _cacheService.put(
        ApiConstants.cachePolls,
        newList.map((e) => e.toJson()).toList(),
      );
    }
    return response;
  }


  Future<PollDetailsModel> pollDetails(String pollId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.pollDetails(pollId),
      );
      return PollDetailsModel.fromJson(response.data['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<PollResultModel> pollResult(String pollId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.pollResults(pollId),
      );
      return PollResultModel.fromJson(response.data['data']);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }




  Future<void> pollAnswer({
    required String pollId,
    String? answer,
    String? optionId,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.pollAns(pollId),
        data: {
          if (optionId != null) 'optionId': optionId,
          if (answer != null) 'answer': answer,
        },
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }


  Future<void> createPoll (CreatePollBody body)async{
      try {
        await _apiService.post(
          ApiConstants.pollCreate,
          data: body.toJson(),
        );
      } on AppException {
        rethrow;
      } catch (e) {
        throw UnknownException(e.toString());
      }
  }

  Future<void> deletePoll (String pollId)async{
    try {
      await _apiService.delete(
        ApiConstants.pollDelete(pollId),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  bool hasCache() {
    return _cacheService.containsKey(ApiConstants.cachePolls);
  }
}
