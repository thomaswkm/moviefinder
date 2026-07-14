import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/media_data_source.dart';

class MediaRepositoryImpl implements MediaRepository {
  const MediaRepositoryImpl(this._dataSource);

  final MediaDataSource _dataSource;

  @override
  Future<List<MediaItem>> getHomeMediaItems({String mediaType = 'all'}) async {
    final items = await _dataSource.getHomeMediaItems(mediaType: mediaType);
    return items.map((item) => item.toEntity()).toList(growable: false);
  }
}
