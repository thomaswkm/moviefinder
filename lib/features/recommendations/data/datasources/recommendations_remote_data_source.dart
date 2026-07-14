import '../../../../core/network/api_client.dart';
import '../models/recommendation_result_model.dart';
import 'recommendations_data_source.dart';

class RecommendationsRemoteDataSource implements RecommendationsDataSource {
  const RecommendationsRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<RecommendationResultModel> getRecommendations() async {
    final response = await _apiClient.get('/api/recommendations');
    return RecommendationResultModel.fromJson(response as Map<String, dynamic>);
  }
}
