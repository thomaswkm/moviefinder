import '../entities/streaming_source.dart';
import '../repositories/streaming_repository.dart';

class GetStreamingSources {
  const GetStreamingSources(this._repository);

  final StreamingRepository _repository;

  Future<List<StreamingSource>> call(int tmdbId) {
    return _repository.getStreamingSources(tmdbId);
  }
}
