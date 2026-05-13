import 'package:flutter_task/core/exceptions/app_exceptions.dart';
import 'package:flutter_task/features/poll/data/models/create_poll_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_details_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_model.dart';
import 'package:flutter_task/features/poll/data/models/poll_result_model.dart';
import 'package:flutter_task/features/poll/data/repositories/poll_repository.dart';

class PollServices {
  final PollRepository _repository;

  PollServices({required PollRepository repository}) : _repository = repository;

  Future<void> fetchPolls(int currentPage, int limit, {String? search}) async {
    try {
      await Future.wait([
        _repository.getPolls(currentPage, limit, search: search),
      ]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<PollModel>> fetchMorePolls(int offset, int limit) async {
    return await _repository.fetchMorePolls(offset, limit);
  }

  List<PollModel> getCachedPolls() {
    return _repository.getCachedPolls();
  }

  Future<PollDetailsModel> fetchPollDetails(String pollId) async {
    return await _repository.pollDetails(pollId);
  }

  Future<PollResultModel> fetchPollResult(String pollId) async {
    return await _repository.pollResult(pollId);
  }


  Future<void> pollAnswer({
    required String pollId,
    String? answer,
    String? optionId,
  }) async {
    return await _repository.pollAnswer(
      pollId: pollId,
      answer: answer,
      optionId: optionId,
    );
  }

  Future<void> createPoll (CreatePollBody body)async{
    return await _repository.createPoll(body);
  }

  Future<void> deletePoll (String pollId)async{
    return await _repository.deletePoll(pollId);
  }



  bool hasCache() {
    return _repository.hasCache();
  }
}
