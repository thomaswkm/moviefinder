import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._dataSource);

  final MovieDataSource _dataSource;

  @override
  Future<List<Movie>> getHomeMovies() async {
    final movies = await _dataSource.getHomeMovies();
    return movies.map((movie) => movie.toEntity()).toList(growable: false);
  }
}
