import '../entities/streaming_source.dart';

abstract interface class StreamingRepository {
  Future<List<StreamingSource>> getStreamingSources(int tmdbId);
}
