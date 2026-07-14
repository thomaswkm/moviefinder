import '../../domain/entities/recommendation_result.dart';
import 'provider_recommendation_model.dart';

class RecommendationResultModel extends RecommendationResult {
  const RecommendationResultModel({
    required super.totalMovies,
    required super.recommendations,
  });

  factory RecommendationResultModel.fromJson(Map<String, dynamic> json) {
    final recommendations =
        json['recommendations'] as List<dynamic>? ?? const [];

    return RecommendationResultModel(
      totalMovies: (json['totalMovies'] as num?)?.toInt() ?? 0,
      recommendations: recommendations
          .map(
            (item) => ProviderRecommendationModel.fromJson(
              item as Map<String, dynamic>,
            ).toEntity(),
          )
          .toList(growable: false),
    );
  }

  RecommendationResult toEntity() {
    return RecommendationResult(
      totalMovies: totalMovies,
      recommendations: recommendations,
    );
  }
}
