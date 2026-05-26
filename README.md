# MovieFinder

MovieFinder es una aplicacion Flutter para explorar peliculas y series, consultar detalles de contenido y ver en que plataformas de streaming esta disponible cada titulo.

El proyecto esta organizado con una arquitectura por features y una separacion cercana a Clean Architecture: `presentation`, `domain` y `data`.

## Objetivo Del Proyecto

El sistema busca cubrir estos casos principales:

- Visualizar un catalogo de peliculas y series.
- Buscar o filtrar contenido por categorias.
- Ver el detalle de una pelicula o serie seleccionada.
- Mostrar plataformas de streaming disponibles para cada contenido.
- Permitir autenticacion de usuarios.
- Preparar futuras funcionalidades de valoraciones, resenas, watchlists y recomendaciones de suscripcion.

## Estado Actual

Hasta ahora el frontend tiene implementado:

- Flujo de intro, login y registro con UI mock.
- Restauracion de sesion mock usando `shared_preferences`.
- Home de catalogo con peliculas y series mock.
- Filtros de Home para tendencias, peliculas, series y TV shows.
- Cards destacadas y grilla de contenido.
- Pantalla de detalle de media con poster, titulo, metadata, sinopsis, generos y creditos.
- Seccion de plataformas de streaming dentro del detalle.
- Mock data de streaming con logos locales para Netflix, HBO Max, Prime Video y Apple TV.
- Theme light/dark configurado.
- Tests de widget para navegacion principal, sesion mock, filtros y detalle.

La app todavia no consume una API real. Los datos actuales vienen de datasources mock, pero la estructura esta lista para reemplazarlos por datasources remotos usando un cliente HTTP como Dio.

## Arquitectura

La estructura principal es:

```text
lib/
  core/
    result/
    storage/
    theme/
  features/
    auth/
      data/
      domain/
      presentation/
    catalog/
      data/
      domain/
      presentation/
    streaming/
      data/
      domain/
      presentation/
    intro/
      presentation/
```

Cada feature sigue esta idea:

```text
presentation -> UI, pages, widgets, controllers
domain       -> entidades, repositorios abstractos, casos de uso
data         -> modelos, datasources, repositorios concretos
```

Ejemplo del flujo de catalogo:

```text
HomePage
-> HomeController
-> GetHomeMediaItems
-> MediaRepositoryImpl
-> MediaMockDataSource
```

Ejemplo del flujo de streaming:

```text
MediaDetailPage
-> GetStreamingSources
-> StreamingRepositoryImpl
-> StreamingMockDataSource
-> StreamingPlatformList
```

## Features Implementadas

### Auth

Ubicacion: `lib/features/auth/`

Incluye:

- `LoginPage`
- `RegisterPage`
- `LoginController`
- `RegisterController`
- `AuthRepositoryImpl`
- `AuthMockDataSource`
- `TokenStorage`

El login y registro usan datos mock y guardan un token mock para restaurar sesion.

### Catalog

Ubicacion: `lib/features/catalog/`

Incluye:

- Entidad `MediaItem`.
- Repository contract `MediaRepository`.
- Use case `GetHomeMediaItems`.
- Datasource mock `MediaMockDataSource`.
- Home con cards, filtros y carrusel destacado.
- Pantalla `MediaDetailPage`.

Los posters mock estan en:

```text
assets/images/movies/mock/
```

### Streaming

Ubicacion: `lib/features/streaming/`

Incluye:

- Entidad `StreamingSource`.
- Enum `StreamingSourceType`.
- Repository contract `StreamingRepository`.
- Use case `GetStreamingSources`.
- Datasource mock `StreamingMockDataSource`.
- Widgets `StreamingPlatformList` y `StreamingPlatformCard`.

Los logos estan en:

```text
assets/images/streaming/
```

## API Prevista

Los contratos estan documentados en:

```text
docs/API_ENDPOINTS.md
docs/FRONTEND_API_SPEC.md
```

Endpoint previsto para streaming:

```http
GET /api/streaming/{tmdbId}
```

Respuesta esperada:

```json
[
  {
    "source_id": 203,
    "name": "Netflix",
    "type": "sub",
    "region": "US",
    "web_url": "https://...",
    "format": "HD"
  }
]
```

Mapeo actual de tipos a UI:

```text
sub  -> Incluida
rent -> Arriendo
buy  -> Compra
free -> Gratis
```

## Datasources Mock Actuales

Actualmente la app se inicializa con mocks en `lib/main.dart`:

```dart
AuthMockDataSource()
MediaMockDataSource()
StreamingMockDataSource()
```

Cuando se conecte la API real, la idea es crear datasources remotos como:

```text
AuthRemoteDataSource
MediaRemoteDataSource
StreamingRemoteDataSource
```

y reemplazar los mocks desde la composicion de dependencias en `main.dart`.

## Requisitos Tecnicos

- Flutter
- Dart SDK `^3.12.0`
- `shared_preferences`
- `flutter_lints`
- `flutter_test`

## Comandos Utiles

Instalar dependencias:

```bash
flutter pub get
```

Ejecutar analisis estatico:

```bash
flutter analyze
```

Ejecutar tests:

```bash
flutter test
```

Ejecutar app:

```bash
flutter run
```

## Documentacion Del Proyecto

Documentos principales:

- `docs/REQUERIMIENTOS.md`
- `docs/API_ENDPOINTS.md`
- `docs/FRONTEND_API_SPEC.md`
- `docs/ITERATION_1_IMPLEMENTATION_PLAN.md`
- `docs/STREAMING_FEATURE_PLAN.md`

Mocks de UI:

```text
docs/mocks-ui/
```

Diagramas:

```text
docs/diagrams/
out/docs/diagrams/
```

## Pendiente

- Conectar auth, catalogo y streaming a API real.
- Agregar cliente HTTP, probablemente Dio, con interceptores para JWT.
- Implementar busqueda real de peliculas.
- Implementar valoraciones y resenas.
- Implementar watchlists.
- Implementar recomendaciones de suscripcion basadas en watchlist.
- Agregar manejo completo de errores API y estados de retry.
- Expandir tests unitarios para use cases, repositories y datasources.
