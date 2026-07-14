import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class GetHomeMediaItems {
  const GetHomeMediaItems(this._repository);

  final MediaRepository _repository;

  Future<List<MediaItem>> call({String mediaType = 'all'}) {
    return _repository.getHomeMediaItems(mediaType: mediaType);
  }
}
