import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.originalTitle,
    required super.overview,
    required super.posterAssetPath,
    required super.releaseYear,
    required super.durationMinutes,
    required super.rating,
    required super.genres,
    required super.director,
  });

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterAssetPath: posterAssetPath,
      releaseYear: releaseYear,
      durationMinutes: durationMinutes,
      rating: rating,
      genres: genres,
      director: director,
    );
  }
}
