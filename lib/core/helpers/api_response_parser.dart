/// Tolerant readers for the backend's `{success, message, meta, data}` envelope.
///
/// A 200 must never surface as "Failed to load" just because `data` is null,
/// nested (`{data: {data: [...]}}`) or a bare list.
class ApiResponseParser {
  ApiResponseParser._();

  /// The list of JSON objects in [body], or an empty list.
  static List<Map<String, dynamic>> dataList(dynamic body) {
    dynamic raw = body is Map ? body['data'] : body;
    if (raw is Map) {
      raw = raw['data'] ?? raw['result'] ?? raw['items'] ?? raw['docs'];
    }
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
