class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterAssetPath,
    required this.releaseYear,
    required this.durationMinutes,
    required this.rating,
    required this.genres,
    required this.director,
  });

  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterAssetPath;
  final int releaseYear;
  final int durationMinutes;
  final double rating;
  final List<String> genres;
  final String director;
}
