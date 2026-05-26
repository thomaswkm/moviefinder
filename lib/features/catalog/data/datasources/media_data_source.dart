import '../models/media_item_model.dart';

abstract interface class MediaDataSource {
  Future<List<MediaItemModel>> getHomeMediaItems();
}
