import 'provider_recommendation.dart';

class RecommendationResult {
  const RecommendationResult({
    required this.totalMovies,
    required this.recommendations,
  });

  final int totalMovies;
  final List<ProviderRecommendation> recommendations;
}
