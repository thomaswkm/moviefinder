import '../models/media_item_model.dart';

abstract interface class MediaDataSource {
  Future<List<MediaItemModel>> getHomeMediaItems();
  Future<List<MediaItemModel>> getSuggestions();
  Future<List<MediaItemModel>> searchMediaItems(String query);
}
