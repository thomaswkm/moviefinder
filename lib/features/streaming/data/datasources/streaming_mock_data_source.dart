import '../../domain/entities/streaming_source.dart';
import '../models/streaming_source_model.dart';
import 'streaming_data_source.dart';

class StreamingMockDataSource implements StreamingDataSource {
  const StreamingMockDataSource();

  static const _netflixLogo = 'assets/images/streaming/netflix-logo.png';
  static const _hboMaxLogo = 'assets/images/streaming/hbo-max-logo.png';
  static const _primeVideoLogo = 'assets/images/streaming/prime-video-logo.png';
  static const _appleTvLogo = 'assets/images/streaming/apple-tv-logo.png';

  static const _disneyPlusLogo = 'assets/images/streaming/disney-plus-logo.png';
  static const _paramountPlusLogo =
      'assets/images/streaming/paramount-plus-logo.png';
  static const _huluLogo = 'assets/images/streaming/hulu-logo.png';
  static const _peacockLogo = 'assets/images/streaming/peacock-logo.png';
  static const _discoveryPlusLogo =
      'assets/images/streaming/discovery-plus-logo.png';
  static const _starzLogo = 'assets/images/streaming/starz-logo.png';

  @override
  Future<List<StreamingSourceModel>> getStreamingSources(
    int tmdbId, {
    required String mediaType,
  }) async {
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
        StreamingSourceModel(
          sourceId: 537,
          name: 'Disney+',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.disneyplus.com',
          format: '4K',
          logoAssetPath: _disneyPlusLogo,
        ),
        StreamingSourceModel(
          sourceId: 538,
          name: 'Paramount+',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.paramountplus.com',
          format: 'HD',
          logoAssetPath: _paramountPlusLogo,
        ),
        StreamingSourceModel(
          sourceId: 539,
          name: 'Hulu',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.hulu.com',
          format: 'HD',
          logoAssetPath: _huluLogo,
        ),
        StreamingSourceModel(
          sourceId: 540,
          name: 'Peacock',
          type: StreamingSourceType.free,
          region: 'US',
          webUrl: 'https://www.peacocktv.com',
          format: 'HD',
          logoAssetPath: _peacockLogo,
        ),
        StreamingSourceModel(
          sourceId: 541,
          name: 'Discovery+',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.discoveryplus.com',
          format: 'HD',
          logoAssetPath: _discoveryPlusLogo,
        ),
        StreamingSourceModel(
          sourceId: 542,
          name: 'Starz',
          type: StreamingSourceType.subscription,
          region: 'US',
          webUrl: 'https://www.starz.com',
          format: 'HD',
          logoAssetPath: _starzLogo,
        ),
      ],
    };
  }
}
