import 'package:masic_generation/core/exceptions/app_exceptions.dart';
import 'package:masic_generation/features/poll/data/models/poll_details_model.dart';
import 'package:masic_generation/features/poll/data/models/poll_model.dart';
import 'package:masic_generation/features/poll/data/repositories/poll_repository.dart';
import 'package:masic_generation/features/request/data/models/create_job_model.dart';
import 'package:masic_generation/features/request/data/models/request_model.dart';
import 'package:masic_generation/features/request/data/repositories/request_repository.dart';

class RequestServices {
  final RequestRepository _repository;

  RequestServices({required RequestRepository repository})
    : _repository = repository;

  Future<void> fetchRequests({String? search}) async {
    try {
      await Future.wait([_repository.fetchRequests(page: 1, limit: 10, search: search)]);
    } on AppException {
      if (!_repository.hasCache()) {
        rethrow;
      }
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<List<RequestModel>> fetchMoreRequest(int offset, int limit) async {
    return await _repository.fetchMoreRequests(offset, limit);
  }

  Future<RequestModel?> findRequestById(String id) {
    return _repository.findRequestById(id);
  }

  List<RequestModel> getCachedRequests() {
    return _repository.getCachedRequests();
  }


  Future<void> updateStatus(String requestId, String status,String? declineReason) async {
    return await _repository.updateStatus(requestId, status,declineReason);
  }

  Future<void> createRequest(CreateJobModel createRequestModel) async {
    return await _repository.createRequest(createRequestModel);
  }



  bool hasCache() {
    return _repository.hasCache();
  }
}
