import '../../../streaming/data/models/streaming_source_model.dart';
import '../../domain/entities/provider_recommendation.dart';

class ProviderRecommendationModel extends ProviderRecommendation {
  const ProviderRecommendationModel({
    required super.providerName,
    required super.coveredMovies,
    required super.totalMovies,
    required super.coveragePercentage,
    required super.sourceType,
    super.estimatedCost,
    super.logoAssetPath,
  });

  factory ProviderRecommendationModel.fromJson(Map<String, dynamic> json) {
    final providerName = json['providerName'] as String? ?? 'Plataforma';

    return ProviderRecommendationModel(
      providerName: providerName,
      coveredMovies: (json['coveredMovies'] as num?)?.toInt() ?? 0,
      totalMovies: (json['totalMovies'] as num?)?.toInt() ?? 0,
      coveragePercentage: (json['coveragePercentage'] as num?)?.toDouble() ?? 0,
      sourceType: json['sourceType'] as String? ?? 'unknown',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      logoAssetPath: streamingLogoAssetPath(providerName),
    );
  }

  ProviderRecommendation toEntity() {
    return ProviderRecommendation(
      providerName: providerName,
      coveredMovies: coveredMovies,
      totalMovies: totalMovies,
      coveragePercentage: coveragePercentage,
      sourceType: sourceType,
      estimatedCost: estimatedCost,
      logoAssetPath: logoAssetPath,
    );
  }
}
