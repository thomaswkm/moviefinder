import 'package:flutter/foundation.dart';

import '../../data/datasources/recommendations_data_source.dart';
import '../../domain/entities/provider_recommendation.dart';
import '../../domain/entities/recommendation_result.dart';

class RecommendationsController extends ChangeNotifier {
  RecommendationsController(this._dataSource);

  final RecommendationsDataSource _dataSource;

  bool _isLoading = false;
  String? _message;
  RecommendationResult _result = const RecommendationResult(
    totalMovies: 0,
    recommendations: [],
  );

  bool get isLoading => _isLoading;
  String? get message => _message;
  int get totalMovies => _result.totalMovies;
  List<ProviderRecommendation> get recommendations => _result.recommendations;

  Future<void> load() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      _result = (await _dataSource.getRecommendations()).toEntity();
    } on Exception {
      _message = 'No se pudieron cargar tus recomendaciones.';
      _result = const RecommendationResult(totalMovies: 0, recommendations: []);
    }

    _isLoading = false;
    notifyListeners();
  }
}
