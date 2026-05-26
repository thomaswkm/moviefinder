import 'package:flutter/foundation.dart';

import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_home_movies.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._getHomeMovies);

  final GetHomeMovies _getHomeMovies;

  bool _isLoading = false;
  String? _message;
  List<Movie> _movies = const [];

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<Movie> get movies => _movies;

  Future<void> loadMovies() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      _movies = await _getHomeMovies();
    } on Exception {
      _message = 'No se pudieron cargar las peliculas.';
      _movies = const [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
