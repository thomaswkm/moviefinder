import '../entities/movie.dart';

abstract interface class MovieRepository {
  Future<List<Movie>> getHomeMovies();
}
