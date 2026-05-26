enum StreamingSourceType { subscription, rent, buy, free, unknown }

class StreamingSource {
  const StreamingSource({
    required this.sourceId,
    required this.name,
    required this.type,
    required this.region,
    required this.webUrl,
    required this.format,
    required this.logoAssetPath,
  });

  final int sourceId;
  final String name;
  final StreamingSourceType type;
  final String region;
  final String webUrl;
  final String format;
  final String logoAssetPath;
}
