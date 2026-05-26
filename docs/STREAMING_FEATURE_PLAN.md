# Streaming Platforms Feature Plan

## Objective

Show the streaming services where a selected media item is available inside the media details screen.

This implements RF-07 and prepares the frontend for the documented endpoint:

```http
GET /api/streaming/{tmdbId}
```

For the first implementation, data can be mocked while keeping the feature structured so it can later swap to a Dio-based remote data source.

## Current Context

- Media details already opens from Home through `MediaDetailPage`.
- The endpoint specification defines `StreamingSourceDto[]` with `source_id`, `name`, `type`, `region`, `web_url`, and `format`.
- Streaming logos are available under `assets/images/streaming/`:
  - `netflix-logo.png`
  - `hbo-max-logo.png`
  - `prime-video-logo.png`
  - `apple-tv-logo.png`

## Proposed Architecture

Create a separate `streaming` feature and render its presentation widget inside `MediaDetailPage`.

```text
lib/features/streaming/
  domain/entities/streaming_source.dart
  domain/repositories/streaming_repository.dart
  domain/usecases/get_streaming_sources.dart
  data/datasources/streaming_data_source.dart
  data/datasources/streaming_mock_data_source.dart
  data/models/streaming_source_model.dart
  data/repositories/streaming_repository_impl.dart
  presentation/widgets/streaming_platform_list.dart
  presentation/widgets/streaming_platform_card.dart
```

The intended flow is:

```text
MediaDetailPage
-> StreamingPlatformList
-> GetStreamingSources
-> StreamingRepositoryImpl
-> StreamingMockDataSource now
-> StreamingRemoteDataSource with Dio later
```

## Domain Model

Create `StreamingSource` with fields aligned to the API DTO:

```dart
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
```

Use an enum for known access types:

```dart
enum StreamingSourceType { subscription, rent, buy, free, unknown }
```

UI labels:

```text
subscription -> Incluida
rent -> Arriendo
buy -> Compra
free -> Gratis
unknown -> No especificada
```

## Mock Data

Use static mock data keyed by `tmdbId`/`MediaItem.id` for now.

Suggested default sources:

| Platform | Type | UI Label | Asset |
| --- | --- | --- | --- |
| Netflix | `sub` | Incluida | `assets/images/streaming/netflix-logo.png` |
| HBO Max | `sub` | Incluida | `assets/images/streaming/hbo-max-logo.png` |
| Prime Video | `rent` | Arriendo | `assets/images/streaming/prime-video-logo.png` |
| Apple TV | `buy` | Compra | `assets/images/streaming/apple-tv-logo.png` |

Some media IDs should intentionally return `[]` to test the empty state.

## UI Placement

Add the component to `MediaDetailPage` between metadata and synopsis, matching the mock UI:

```text
Platforms                         See all

[ HBO Max ] [ Netflix ] [ Prime Video ]
```

Widget behavior:

- Horizontal scroll list.
- Square cards using the streaming logos.
- Small badge for access mode: `Incluida`, `Arriendo`, `Compra`, or `Gratis`.
- Empty state text: `No hay plataformas disponibles.`
- `See all` can be visual-only initially unless a full platforms screen is added.

## Asset Configuration

Ensure `pubspec.yaml` includes the streaming assets:

```yaml
flutter:
  assets:
    - assets/images/movies/mock/
    - assets/images/streaming/
```

## Future Dio Integration

When replacing mocks, create `StreamingRemoteDataSource`:

```dart
class StreamingRemoteDataSource implements StreamingDataSource {
  StreamingRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<StreamingSourceModel>> getStreamingSources(int tmdbId) async {
    final response = await _dio.get('/streaming/$tmdbId');
    final data = response.data as List<dynamic>;

    return data
        .map((json) => StreamingSourceModel.fromJson(json as Map<String, dynamic>))
        .toList(growable: false);
  }
}
```

The API response does not include local logo paths, so the model/data layer should map known provider names to bundled assets.

## Tests

Update widget tests to verify:

- Media detail shows `Platforms`.
- At least one mocked platform logo/name is rendered.
- Access labels are rendered, for example `Incluida`.
- Empty state renders when mock source list is empty.
- Back navigation from media detail still works.

## Acceptance Criteria

- Media detail displays streaming platforms using mock data.
- Platform cards use the assets from `assets/images/streaming/`.
- UI indicates whether each source is included, rental, purchase, free, or unknown.
- The feature is structured so `StreamingMockDataSource` can later be replaced by `StreamingRemoteDataSource` using Dio.
- `flutter analyze` and `flutter test` pass.
