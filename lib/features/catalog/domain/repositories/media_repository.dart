import '../entities/media_item.dart';

abstract interface class MediaRepository {
  Future<List<MediaItem>> getHomeMediaItems();
}
