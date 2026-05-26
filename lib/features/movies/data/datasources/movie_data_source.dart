import '../models/movie_model.dart';

abstract interface class MovieDataSource {
  Future<List<MovieModel>> getHomeMovies();
}
