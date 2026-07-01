import '../models/media_item_model.dart';
import 'media_mock_data_source.dart';
import 'wishlist_data_source.dart';

class WishlistMockDataSource implements WishlistDataSource {
  WishlistMockDataSource();

  final Set<int> _ids = <int>{};

  @override
  Future<List<MediaItemModel>> getWishlistMedia() async {
    final items = await const MediaMockDataSource().getHomeMediaItems();
    return items.where((item) => _ids.contains(item.id)).toList(growable: false);
  }

  @override
  Future<Set<int>> getWishlistIds() async {
    return {..._ids};
  }

  @override
  Future<void> addMovie(int tmdbId, String mediaType) async {
    _ids.add(tmdbId);
  }

  @override
  Future<void> removeMovie(int tmdbId, String mediaType) async {
    _ids.remove(tmdbId);
  }
}
