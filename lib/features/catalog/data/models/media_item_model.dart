import '../../domain/entities/media_item.dart';

class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.originalTitle,
    required super.overview,
    required super.posterAssetPath,
    required super.releaseYear,
    required super.rating,
    required super.genres,
    super.durationMinutes,
    super.seasonsCount,
    super.episodesCount,
    super.director,
    super.creator,
  });

  MediaItem toEntity() {
    return MediaItem(
      id: id,
      type: type,
      title: title,
      originalTitle: originalTitle,
      overview: overview,
      posterAssetPath: posterAssetPath,
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
