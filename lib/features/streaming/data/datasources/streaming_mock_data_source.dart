import '../../domain/entities/streaming_source.dart';
import '../models/streaming_source_model.dart';
import 'streaming_data_source.dart';

class StreamingMockDataSource implements StreamingDataSource {
  const StreamingMockDataSource();

  static const _netflixLogo = 'assets/images/streaming/netflix-logo.png';
  static const _hboMaxLogo = 'assets/images/streaming/hbo-max-logo.png';
  static const _primeVideoLogo = 'assets/images/streaming/prime-video-logo.png';
  static const _appleTvLogo = 'assets/images/streaming/apple-tv-logo.png';

  @override
  Future<List<StreamingSourceModel>> getStreamingSources(int tmdbId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));

    return switch (tmdbId) {
      3 || 10 || 11 => const [],
      4 || 12 => const [
        StreamingSourceModel(
          sourceId: 203,
          name: 'Netflix',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.netflix.com',
          format: 'HD',
          logoAssetPath: _netflixLogo,
        ),
        StreamingSourceModel(
          sourceId: 371,
          name: 'Prime Video',
          type: StreamingSourceType.rent,
          region: 'US',
          webUrl: 'https://www.primevideo.com',
          format: '4K',
          logoAssetPath: _primeVideoLogo,
        ),
        StreamingSourceModel(
          sourceId: 441,
          name: 'Apple TV',
          type: StreamingSourceType.buy,
          region: 'US',
          webUrl: 'https://tv.apple.com',
          format: '4K',
          logoAssetPath: _appleTvLogo,
        ),
      ],
      _ => const [
        StreamingSourceModel(
          sourceId: 387,
          name: 'HBO Max',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.max.com',
          format: 'HD',
          logoAssetPath: _hboMaxLogo,
        ),
        StreamingSourceModel(
          sourceId: 203,
          name: 'Netflix',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.netflix.com',
          format: 'HD',
          logoAssetPath: _netflixLogo,
        ),
        StreamingSourceModel(
          sourceId: 371,
          name: 'Prime Video',
          type: StreamingSourceType.rent,
          region: 'US',
          webUrl: 'https://www.primevideo.com',
          format: 'HD',
          logoAssetPath: _primeVideoLogo,
        ),
        StreamingSourceModel(
          sourceId: 441,
          name: 'Apple TV',
          type: StreamingSourceType.buy,
          region: 'US',
          webUrl: 'https://tv.apple.com',
          format: '4K',
          logoAssetPath: _appleTvLogo,
        ),
      ],
    };
  }
}
