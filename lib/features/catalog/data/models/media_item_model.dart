import '../../domain/entities/media_item.dart';

class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.originalTitle,
    required super.overview,
    required super.posterUrl,
    required super.releaseYear,
    required super.rating,
    required super.genres,
    super.durationMinutes,
    super.seasonsCount,
    super.episodesCount,
    super.director,
    super.creator,
  });

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    final type = switch (json['type'] as String? ?? 'movie') {
      'series' || 'tv' => MediaType.series,
      _ => MediaType.movie,
    };

    return MediaItemModel(
      id: (json['id'] as num).toInt(),
      type: type,
      title: json['title'] as String? ?? 'Sin titulo',
      originalTitle:
          json['originalTitle'] as String? ?? json['title'] as String? ?? 'Sin titulo',
      overview: json['overview'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      releaseYear: (json['releaseYear'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      genres: (json['genres'] as List<dynamic>? ?? const [])
          .map((genre) => genre.toString())
          .toList(growable: false),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      seasonsCount: (json['seasonsCount'] as num?)?.toInt(),
      episodesCount: (json['episodesCount'] as num?)?.toInt(),
      director: json['director'] as String?,
      creator: json['creator'] as String?,
    );
  }

  MediaItem toEntity() {
    return MediaItem(
      id: id,
      type: type,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterUrl: posterUrl,
      releaseYear: releaseYear,
      rating: rating,
      genres: genres,
      durationMinutes: durationMinutes,
      seasonsCount: seasonsCount,
      episodesCount: episodesCount,
      director: director,
      creator: creator,
    );
  }
}
