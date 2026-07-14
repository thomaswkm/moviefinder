import '../models/streaming_source_model.dart';

abstract interface class StreamingDataSource {
  Future<List<StreamingSourceModel>> getStreamingSources(
    int tmdbId, {
    required String mediaType,
  });
}
