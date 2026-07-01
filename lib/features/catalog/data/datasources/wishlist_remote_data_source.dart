import '../../../../core/network/api_client.dart';
import '../models/media_item_model.dart';
import 'wishlist_data_source.dart';

class WishlistRemoteDataSource implements WishlistDataSource {
  const WishlistRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MediaItemModel>> getWishlistMedia() async {
    final response = await _apiClient.get('/api/wishlist/media');
    final list = response as List<dynamic>;
    return list
        .map((item) => MediaItemModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Set<int>> getWishlistIds() async {
    final response = await _apiClient.get('/api/wishlist');
    final list = response as List<dynamic>;
    return list
        .map((item) => ((item as Map<String, dynamic>)['tmdbId'] as num).toInt())
        .toSet();
  }

  @override
  Future<void> addMovie(int tmdbId, String mediaType) async {
    await _apiClient.post(
      '/api/wishlist/$tmdbId',
      queryParameters: {'mediaType': mediaType},
    );
  }

  @override
  Future<void> removeMovie(int tmdbId, String mediaType) async {
    await _apiClient.delete(
      '/api/wishlist/$tmdbId',
      queryParameters: {'mediaType': mediaType},
    );
  }
}
