import '../../../../core/network/api_client.dart';
import '../models/streaming_source_model.dart';
import 'streaming_data_source.dart';

class StreamingRemoteDataSource implements StreamingDataSource {
  const StreamingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<StreamingSourceModel>> getStreamingSources(int tmdbId) async {
    final response = await _apiClient.get('/api/streaming/$tmdbId');
    final list = response as List<dynamic>;
    return list
        .map((item) => StreamingSourceModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
