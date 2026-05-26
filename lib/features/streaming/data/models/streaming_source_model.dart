import '../../domain/entities/streaming_source.dart';

class StreamingSourceModel extends StreamingSource {
  const StreamingSourceModel({
    required super.sourceId,
    required super.name,
    required super.type,
    required super.region,
    required super.webUrl,
    required super.format,
    required super.logoAssetPath,
  });

  factory StreamingSourceModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Unknown';

    return StreamingSourceModel(
      sourceId: json['source_id'] as int? ?? 0,
      name: name,
      type: streamingSourceTypeFromApi(json['type'] as String?),
      region: json['region'] as String? ?? '',
      webUrl: json['web_url'] as String? ?? '',
      format: json['format'] as String? ?? '',
      logoAssetPath: streamingLogoAssetPath(name),
    );
  }

  StreamingSource toEntity() {
    return StreamingSource(
      sourceId: sourceId,
      name: name,
      type: type,
      region: region,
      webUrl: webUrl,
      format: format,
      logoAssetPath: logoAssetPath,
    );
  }
}

StreamingSourceType streamingSourceTypeFromApi(String? type) {
  return switch (type) {
    'sub' => StreamingSourceType.subscription,
    'rent' => StreamingSourceType.rent,
    'buy' => StreamingSourceType.buy,
    'free' => StreamingSourceType.free,
    _ => StreamingSourceType.unknown,
  };
}

String streamingLogoAssetPath(String name) {
  final normalizedName = name.toLowerCase();

  if (normalizedName.contains('netflix')) {
    return 'assets/images/streaming/netflix-logo.png';
  }

  if (normalizedName.contains('hbo')) {
    return 'assets/images/streaming/hbo-max-logo.png';
  }

  if (normalizedName.contains('prime') || normalizedName.contains('amazon')) {
    return 'assets/images/streaming/prime-video-logo.png';
  }

  if (normalizedName.contains('apple')) {
    return 'assets/images/streaming/apple-tv-logo.png';
  }

  return 'assets/images/streaming/netflix-logo.png';
}
