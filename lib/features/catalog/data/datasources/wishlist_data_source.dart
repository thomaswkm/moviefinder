import '../models/media_item_model.dart';

abstract interface class WishlistDataSource {
  Future<List<MediaItemModel>> getWishlistMedia();

  Future<Set<int>> getWishlistIds();

  Future<void> addMovie(int tmdbId, String mediaType);

  Future<void> removeMovie(int tmdbId, String mediaType);
}
