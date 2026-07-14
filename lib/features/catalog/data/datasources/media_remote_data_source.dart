import '../../../../core/network/api_client.dart';
import '../models/media_item_model.dart';
import 'media_data_source.dart';

class MediaRemoteDataSource implements MediaDataSource {
  const MediaRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<MediaItemModel>> getHomeMediaItems() async {
    final response = await _apiClient.get('/api/catalog/home');
    return _modelsFromResponse(response);
  }

  @override
  Future<List<MediaItemModel>> searchMediaItems(String query) async {
    final response = await _apiClient.get(
      '/api/catalog/search/media',
      queryParameters: {'query': query},
    );
    return _modelsFromResponse(response);
  }

  @override
  Future<List<MediaItemModel>> getSuggestions() async {
    return getHomeMediaItems();
  }

  List<MediaItemModel> _modelsFromResponse(dynamic response) {
    final list = response as List<dynamic>;
    return list
        .map((item) => MediaItemModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
