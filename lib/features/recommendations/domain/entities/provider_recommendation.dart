class ProviderRecommendation {
  const ProviderRecommendation({
    required this.providerName,
    required this.coveredMovies,
    required this.totalMovies,
    required this.coveragePercentage,
    required this.sourceType,
    this.estimatedCost,
    this.logoAssetPath = '',
  });

  final String providerName;
  final int coveredMovies;
  final int totalMovies;
  final double coveragePercentage;
  final String sourceType;
  final double? estimatedCost;
  final String logoAssetPath;
}
