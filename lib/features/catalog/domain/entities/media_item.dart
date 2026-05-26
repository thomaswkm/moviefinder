enum MediaType { movie, series }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterAssetPath,
    required this.releaseYear,
    required this.rating,
    required this.genres,
    this.durationMinutes,
    this.seasonsCount,
    this.episodesCount,
    this.director,
    this.creator,
  });

  final int id;
  final MediaType type;
  final String title;
  final String originalTitle;
  final String overview;
  final String posterAssetPath;
  final int releaseYear;
  final double rating;
  final List<String> genres;
  final int? durationMinutes;
  final int? seasonsCount;
  final int? episodesCount;
  final String? director;
  final String? creator;
}
