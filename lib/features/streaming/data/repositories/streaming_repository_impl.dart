import '../../domain/entities/streaming_source.dart';
import '../../domain/repositories/streaming_repository.dart';
import '../datasources/streaming_data_source.dart';

class StreamingRepositoryImpl implements StreamingRepository {
  const StreamingRepositoryImpl(this._dataSource);

  final StreamingDataSource _dataSource;

  @override
  Future<List<StreamingSource>> getStreamingSources(int tmdbId) async {
    final sources = await _dataSource.getStreamingSources(tmdbId);
    return sources.map((source) => source.toEntity()).toList(growable: false);
  }
}
