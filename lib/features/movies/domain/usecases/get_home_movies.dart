import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetHomeMovies {
  const GetHomeMovies(this._repository);

  final MovieRepository _repository;

  Future<List<Movie>> call() {
    return _repository.getHomeMovies();
  }
}
