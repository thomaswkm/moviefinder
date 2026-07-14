import '../models/recommendation_result_model.dart';

abstract interface class RecommendationsDataSource {
  Future<RecommendationResultModel> getRecommendations();
}
