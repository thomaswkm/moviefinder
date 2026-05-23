# Especificacion de API para Frontend

Este documento define los contratos que el frontend debe implementar para comunicarse con la API backend descrita en `docs/API_ENDPOINTS.md`.

La intencion es que este artefacto pueda ser usado para automatizar la generacion de modelos, DTOs, datasources, repositorios y casos de uso del cliente.

## Configuracion General

### Base URL

El cliente debe configurar una URL base del backend y anteponer `/api` a los endpoints.

Ejemplo local:

```text
http://localhost:8080
```

Ejemplo de URL final:

```text
http://localhost:8080/api/catalog/search?query=matrix&page=1
```

### Headers

Para requests con body JSON:

```http
Content-Type: application/json
```

Para endpoints autenticados:

```http
Authorization: Bearer <token>
```

Cada respuesta puede incluir:

```http
X-Request-ID: <request-id>
```

El frontend deberia capturar `X-Request-ID` para trazabilidad de errores cuando este disponible.

### Autenticacion

La API usa JWT stateless.

Endpoints publicos:

| Metodo | Endpoint |
| --- | --- |
| `POST` | `/api/auth/register` |
| `POST` | `/api/auth/login` |

Todos los demas endpoints requieren `Authorization: Bearer <token>`.

El backend tambien puede devolver cookie `accessCookie`, pero el frontend movil debe usar el campo `token` recibido en login/registro.

### Formatos Comunes de Error

Error general:

```json
{
  "error": "mensaje del error"
}
```

Error de validacion por campo:

```json
{
  "email": "El formato del correo electronico no es valido",
  "password": "La contrasena es obligatoria"
}
```

Codigos HTTP relevantes:

| Codigo | Manejo esperado en frontend |
| --- | --- |
| `400 Bad Request` | Mostrar error de validacion o mensaje de negocio. |
| `401 Unauthorized` | Limpiar sesion local y redirigir a login. |
| `409 Conflict` | Mostrar conflicto, por ejemplo email duplicado. |
| `429 Too Many Requests` | Mostrar mensaje de limite de peticiones y permitir reintentar despues. |
| `500 Internal Server Error` | Mostrar error generico. |
| `503 Service Unavailable` | Mostrar error temporal de servicios externos TMDB/Watchmode. |

## DTOs Compartidos

### ApiErrorDto

Usado cuando la API responde con error general.

```ts
type ApiErrorDto = {
  error: string;
};
```

### FieldValidationErrorDto

Usado principalmente en registro cuando hay errores por campo.

```ts
type FieldValidationErrorDto = Record<string, string>;
```

### EmptyBody

Algunos endpoints no requieren body.

```ts
type EmptyBody = null;
```

### PlainTextResponse

Algunos endpoints devuelven texto plano y no JSON.

```ts
type PlainTextResponse = string;
```

## Modulo Auth

### RegisterUser

Registra un usuario y devuelve token JWT para iniciar sesion automaticamente.

| Campo | Valor |
| --- | --- |
| Metodo | `POST` |
| Endpoint | `/api/auth/register` |
| Auth | No requerida |
| Content-Type | `application/json` |
| Request body | `RegisterRequestDto` |
| Response `200` | `AuthResponseDto` |

#### RegisterRequestDto

```ts
type RegisterRequestDto = {
  username: string;
  email: string;
  password: string;
};
```

Validaciones esperadas:

| Campo | Regla |
| --- | --- |
| `username` | Obligatorio. |
| `email` | Obligatorio, formato email valido. |
| `password` | Obligatorio. |

Ejemplo request:

```json
{
  "username": "thomas",
  "email": "thomas@example.com",
  "password": "secret123"
}
```

#### AuthResponseDto

```ts
type AuthResponseDto = {
  userId: number;
  email: string;
  username: string;
  token: string;
};
```

Ejemplo response:

```json
{
  "userId": 1,
  "email": "thomas@example.com",
  "username": "thomas",
  "token": "jwt-token"
}
```

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `400` | `FieldValidationErrorDto` o `ApiErrorDto` | Mostrar errores por campo o mensaje general. |
| `409` | `ApiErrorDto` | Indicar email o username duplicado. |
| `429` | `ApiErrorDto` | Mostrar limite de peticiones. |

Persistencia frontend al exito:

| Dato | Uso |
| --- | --- |
| `token` | Guardar de forma segura para requests autenticados. |
| `userId` | Identificador local del usuario autenticado. |
| `email` | Mostrar perfil o estado de sesion. |
| `username` | Mostrar perfil o bienvenida. |

### LoginUser

Inicia sesion con email y password.

| Campo | Valor |
| --- | --- |
| Metodo | `POST` |
| Endpoint | `/api/auth/login` |
| Auth | No requerida |
| Content-Type | `application/json` |
| Request body | `LoginRequestDto` |
| Response `200` | `AuthResponseDto` |

#### LoginRequestDto

```ts
type LoginRequestDto = {
  email: string;
  password: string;
};
```

Ejemplo request:

```json
{
  "email": "thomas@example.com",
  "password": "secret123"
}
```

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `400` | `ApiErrorDto` | Mostrar credenciales invalidas o error de entrada. |
| `401` | `ApiErrorDto` | Mostrar sesion no autorizada. |
| `429` | `ApiErrorDto` | Mostrar limite de peticiones. |

Persistencia frontend al exito:

| Dato | Uso |
| --- | --- |
| `token` | Guardar de forma segura para requests autenticados. |
| `userId` | Identificador local del usuario autenticado. |
| `email` | Mostrar perfil o estado de sesion. |
| `username` | Mostrar perfil o bienvenida. |

### GetCurrentUser

Obtiene el usuario autenticado a partir del token actual.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/auth/me` |
| Auth | Requerida |
| Request body | No requiere |
| Response `200` | `CurrentUserDto` |

#### CurrentUserDto

```ts
type CurrentUserDto = {
  id: number;
  username: string;
  email: string;
};
```

Ejemplo response:

```json
{
  "id": 1,
  "username": "thomas",
  "email": "thomas@example.com"
}
```

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Invalidar token local y redirigir a login. |

## Modulo Catalogo

### SearchMovies

Busca peliculas en TMDB usando texto y paginacion.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/catalog/search` |
| Auth | Requerida |
| Query params | `SearchMoviesQueryDto` |
| Request body | No requiere |
| Response `200` | `MovieSearchResponseDto` |

#### SearchMoviesQueryDto

```ts
type SearchMoviesQueryDto = {
  query: string;
  page?: number;
};
```

Reglas:

| Campo | Regla |
| --- | --- |
| `query` | Requerido. Texto de busqueda. |
| `page` | Opcional. Default backend: `1`. |

Ejemplo request:

```http
GET /api/catalog/search?query=matrix&page=1
```

#### MovieSearchResponseDto

```ts
type MovieSearchResponseDto = {
  page: number;
  results: MovieSearchItemDto[];
  total_pages: number;
  total_results: number;
};
```

#### MovieSearchItemDto

```ts
type MovieSearchItemDto = {
  id: number;
  title: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string;
  genre_ids: number[];
  popularity: number;
};
```

Notas frontend:

| Campo | Uso sugerido |
| --- | --- |
| `id` | Usar como `tmdbId` para detalles, streaming y wishlist. |
| `poster_path` | Construir URL de imagen TMDB en capa de UI/configuracion. |
| `backdrop_path` | Construir URL de imagen TMDB en capa de UI/configuracion. |
| `release_date` | Tratar como string ISO `YYYY-MM-DD`; puede mapearse a fecha si viene presente. |
| `genre_ids` | IDs numericos de genero TMDB; no incluye nombres. |

Estados frontend:

| Condicion | Estado UI |
| --- | --- |
| `results` vacio | Mostrar mensaje sin coincidencias. |
| `page < total_pages` | Permitir cargar mas resultados. |
| `page >= total_pages` | Deshabilitar lazy loading. |

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |
| `429` | `ApiErrorDto` | Mostrar limite de peticiones. |
| `503` | `ApiErrorDto` | Mostrar error temporal de TMDB. |

### GetMovieDetails

Obtiene el detalle de una pelicula desde TMDB.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/catalog/details/{tmdbId}` |
| Auth | Requerida |
| Path params | `MovieDetailsPathDto` |
| Request body | No requiere |
| Response `200` | `MovieDetailsDto` |

#### MovieDetailsPathDto

```ts
type MovieDetailsPathDto = {
  tmdbId: number;
};
```

Ejemplo request:

```http
GET /api/catalog/details/603
```

#### MovieDetailsDto

```ts
type MovieDetailsDto = {
  id: number;
  title: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string;
  runtime: number | null;
  vote_average: number;
  genres: GenreDto[];
};
```

#### GenreDto

```ts
type GenreDto = {
  id: number;
  name: string;
};
```

Notas frontend:

| Campo | Uso sugerido |
| --- | --- |
| `id` | Equivale a `tmdbId`. |
| `runtime` | Mostrar en minutos; contemplar `null`. |
| `vote_average` | Promedio TMDB, no necesariamente valoracion interna del usuario. |
| `genres` | Mostrar nombres de genero. |

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |
| `503` | `ApiErrorDto` | Mostrar error temporal de TMDB. |

## Modulo Streaming

### GetStreamingSources

Obtiene plataformas de streaming disponibles para una pelicula.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/streaming/{tmdbId}` |
| Auth | Requerida |
| Path params | `StreamingSourcesPathDto` |
| Request body | No requiere |
| Response `200` | `StreamingSourceDto[]` |

#### StreamingSourcesPathDto

```ts
type StreamingSourcesPathDto = {
  tmdbId: number;
};
```

Ejemplo request:

```http
GET /api/streaming/603
```

#### StreamingSourceDto

```ts
type StreamingSourceDto = {
  source_id: number;
  name: string;
  type: StreamingSourceTypeDto;
  region: string;
  web_url: string;
  format: string;
};
```

#### StreamingSourceTypeDto

```ts
type StreamingSourceTypeDto = "sub" | "rent" | "buy" | "free" | string;
```

Mapeo sugerido para UI:

| `type` | Etiqueta UI |
| --- | --- |
| `sub` | Incluida en suscripcion. |
| `rent` | Requiere arriendo. |
| `buy` | Requiere compra. |
| `free` | Gratis. |
| Otro valor | Modalidad desconocida. |

Estados frontend:

| Condicion | Estado UI |
| --- | --- |
| Lista vacia `[]` | Mostrar que no hay plataformas disponibles. |
| Lista con elementos | Agrupar o filtrar por modalidad si la UI lo requiere. |

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |
| `503` | `ApiErrorDto` | Mostrar error temporal de Watchmode. |

## Modulo Wishlist

### AddMovieToWishlist

Agrega una pelicula a la wishlist del usuario autenticado.

| Campo | Valor |
| --- | --- |
| Metodo | `POST` |
| Endpoint | `/api/wishlist/{tmdbId}` |
| Auth | Requerida |
| Path params | `WishlistMoviePathDto` |
| Request body | No requiere |
| Response `200` | `PlainTextResponse` |

#### WishlistMoviePathDto

```ts
type WishlistMoviePathDto = {
  tmdbId: number;
};
```

Ejemplo response:

```text
Pelicula agregada a tu lista.
```

Reglas:

| Regla | Comportamiento |
| --- | --- |
| Pelicula ya existe en wishlist | Backend no crea duplicado y responde `200 OK`. |
| Body | No enviar JSON body. |

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |

### RemoveMovieFromWishlist

Elimina una pelicula de la wishlist del usuario autenticado.

| Campo | Valor |
| --- | --- |
| Metodo | `DELETE` |
| Endpoint | `/api/wishlist/{tmdbId}` |
| Auth | Requerida |
| Path params | `WishlistMoviePathDto` |
| Request body | No requiere |
| Response `200` | `PlainTextResponse` |

Ejemplo response:

```text
Pelicula eliminada de tu lista.
```

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |

### GetWishlist

Obtiene la wishlist del usuario autenticado.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/wishlist` |
| Auth | Requerida |
| Request body | No requiere |
| Response `200` | `WishlistItemDto[]` |

#### WishlistItemDto

```ts
type WishlistItemDto = {
  tmdbId: number;
  addedAt: string;
};
```

Ejemplo response:

```json
[
  {
    "tmdbId": 603,
    "addedAt": "2026-05-23T18:30:00"
  }
]
```

Notas frontend:

| Campo | Uso sugerido |
| --- | --- |
| `tmdbId` | Consultar `/api/catalog/details/{tmdbId}` para mostrar titulo, poster y detalle. |
| `addedAt` | Fecha/hora de agregado; backend ordena descendente. |

Flujo recomendado para pantalla de wishlist:

1. Llamar `GET /api/wishlist`.
2. Si la lista viene vacia, mostrar estado vacio.
3. Para cada `tmdbId`, llamar `GET /api/catalog/details/{tmdbId}`.
4. Construir modelo de UI combinando `WishlistItemDto` y `MovieDetailsDto`.

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |

## Modulo Notificaciones

### GetNotifications

Obtiene todas las notificaciones del usuario autenticado.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/notifications` |
| Auth | Requerida |
| Request body | No requiere |
| Response `200` | `NotificationDto[]` |

#### NotificationDto

```ts
type NotificationDto = {
  id: number;
  tmdbId: number;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
};
```

Ejemplo response:

```json
[
  {
    "id": 10,
    "tmdbId": 603,
    "title": "Nueva plataforma disponible",
    "message": "La pelicula 'The Matrix' ahora esta disponible en Netflix.",
    "read": false,
    "createdAt": "2026-05-23T18:30:00"
  }
]
```

Notas frontend:

| Campo | Uso sugerido |
| --- | --- |
| `id` | Usar para marcar como leida. |
| `tmdbId` | Permite navegar al detalle de pelicula. |
| `read` | El DTO backend viene de `isRead`, pero JSON expone `read`. |
| `createdAt` | Mostrar fecha relativa o fecha local formateada. |

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |

### GetUnreadNotifications

Obtiene solo las notificaciones no leidas.

| Campo | Valor |
| --- | --- |
| Metodo | `GET` |
| Endpoint | `/api/notifications/unread` |
| Auth | Requerida |
| Request body | No requiere |
| Response `200` | `NotificationDto[]` |

Uso sugerido:

| Caso | Recomendacion |
| --- | --- |
| Badge de notificaciones | Usar largo del arreglo retornado. |
| Pantalla de notificaciones filtrada | Mostrar lista retornada directamente. |

### MarkNotificationAsRead

Marca una notificacion como leida.

| Campo | Valor |
| --- | --- |
| Metodo | `PATCH` |
| Endpoint | `/api/notifications/{id}/read` |
| Auth | Requerida |
| Path params | `NotificationPathDto` |
| Request body | No requiere |
| Response `200` | `PlainTextResponse` |

#### NotificationPathDto

```ts
type NotificationPathDto = {
  id: number;
};
```

Ejemplo response:

```text
Notificacion marcada como leida
```

Comportamiento frontend sugerido:

1. Ejecutar `PATCH /api/notifications/{id}/read`.
2. Si responde `200`, actualizar localmente `read = true`.
3. Si se usa badge, decrementar contador o volver a llamar `GET /api/notifications/unread`.

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `401` | `ApiErrorDto` | Redirigir a login. |

## Modulo Demo

### SimulatePlatformChange

Endpoint para pruebas manuales y simulacion de cambios de plataforma. No debe formar parte del flujo productivo principal salvo en builds de desarrollo o herramientas internas.

| Campo | Valor |
| --- | --- |
| Metodo | `POST` |
| Endpoint | `/api/demo/simulate-change/{tmdbId}` |
| Auth | Requerida |
| Path params | `SimulatePlatformChangePathDto` |
| Query params | `SimulatePlatformChangeQueryDto` |
| Request body | No requiere |
| Response `200` | `PlainTextResponse` |

#### SimulatePlatformChangePathDto

```ts
type SimulatePlatformChangePathDto = {
  tmdbId: number;
};
```

#### SimulatePlatformChangeQueryDto

```ts
type SimulatePlatformChangeQueryDto = {
  newPlatform: string;
  movieName: string;
};
```

Ejemplo request:

```http
POST /api/demo/simulate-change/603?newPlatform=Netflix&movieName=The%20Matrix
```

Ejemplo response `200`:

```text
Simulacion exitosa. Se enviaron 2 notificaciones.
```

Ejemplo response `400`:

```text
Ningun usuario tiene la pelicula con ID 603 en su Wishlist.
```

Errores esperados:

| Codigo | DTO de error | Accion frontend |
| --- | --- | --- |
| `400` | `PlainTextResponse` o `ApiErrorDto` | Mostrar que no hay usuarios con la pelicula en wishlist. |
| `401` | `ApiErrorDto` | Redirigir a login. |

## Contratos Por Feature Frontend

### Feature Auth

| Caso de uso frontend | Endpoint | Request DTO | Response DTO |
| --- | --- | --- | --- |
| Registrar usuario | `POST /api/auth/register` | `RegisterRequestDto` | `AuthResponseDto` |
| Iniciar sesion | `POST /api/auth/login` | `LoginRequestDto` | `AuthResponseDto` |
| Restaurar/validar sesion | `GET /api/auth/me` | `EmptyBody` | `CurrentUserDto` |

### Feature Movies / Catalog

| Caso de uso frontend | Endpoint | Request DTO | Response DTO |
| --- | --- | --- | --- |
| Buscar peliculas | `GET /api/catalog/search` | `SearchMoviesQueryDto` | `MovieSearchResponseDto` |
| Cargar mas resultados | `GET /api/catalog/search` | `SearchMoviesQueryDto` con `page + 1` | `MovieSearchResponseDto` |
| Ver detalle de pelicula | `GET /api/catalog/details/{tmdbId}` | `MovieDetailsPathDto` | `MovieDetailsDto` |

### Feature Streaming

| Caso de uso frontend | Endpoint | Request DTO | Response DTO |
| --- | --- | --- | --- |
| Ver plataformas disponibles | `GET /api/streaming/{tmdbId}` | `StreamingSourcesPathDto` | `StreamingSourceDto[]` |

### Feature Wishlist

| Caso de uso frontend | Endpoint | Request DTO | Response DTO |
| --- | --- | --- | --- |
| Agregar pelicula a wishlist | `POST /api/wishlist/{tmdbId}` | `WishlistMoviePathDto` | `PlainTextResponse` |
| Eliminar pelicula de wishlist | `DELETE /api/wishlist/{tmdbId}` | `WishlistMoviePathDto` | `PlainTextResponse` |
| Obtener wishlist | `GET /api/wishlist` | `EmptyBody` | `WishlistItemDto[]` |

### Feature Notifications

| Caso de uso frontend | Endpoint | Request DTO | Response DTO |
| --- | --- | --- | --- |
| Obtener notificaciones | `GET /api/notifications` | `EmptyBody` | `NotificationDto[]` |
| Obtener no leidas | `GET /api/notifications/unread` | `EmptyBody` | `NotificationDto[]` |
| Marcar como leida | `PATCH /api/notifications/{id}/read` | `NotificationPathDto` | `PlainTextResponse` |

## Modelos De Dominio Sugeridos

Estos modelos no son respuestas directas obligatorias de la API. Son estructuras sugeridas para que el frontend no dependa de nombres externos como `poster_path` o `tmdbId` en toda la aplicacion.

### AuthenticatedUser

```ts
type AuthenticatedUser = {
  id: number;
  username: string;
  email: string;
  token: string;
};
```

Mapeo:

| Fuente | Dominio |
| --- | --- |
| `AuthResponseDto.userId` | `AuthenticatedUser.id` |
| `AuthResponseDto.username` | `AuthenticatedUser.username` |
| `AuthResponseDto.email` | `AuthenticatedUser.email` |
| `AuthResponseDto.token` | `AuthenticatedUser.token` |

### MovieSummary

```ts
type MovieSummary = {
  tmdbId: number;
  title: string;
  overview: string;
  posterPath: string | null;
  backdropPath: string | null;
  releaseDate: string;
  genreIds: number[];
  popularity: number;
};
```

Mapeo:

| Fuente | Dominio |
| --- | --- |
| `MovieSearchItemDto.id` | `MovieSummary.tmdbId` |
| `MovieSearchItemDto.poster_path` | `MovieSummary.posterPath` |
| `MovieSearchItemDto.backdrop_path` | `MovieSummary.backdropPath` |
| `MovieSearchItemDto.genre_ids` | `MovieSummary.genreIds` |

### MovieDetails

```ts
type MovieDetails = {
  tmdbId: number;
  title: string;
  overview: string;
  posterPath: string | null;
  backdropPath: string | null;
  releaseDate: string;
  runtimeMinutes: number | null;
  voteAverage: number;
  genres: Genre[];
};
```

### StreamingSource

```ts
type StreamingSource = {
  sourceId: number;
  name: string;
  type: StreamingSourceType;
  region: string;
  webUrl: string;
  format: string;
};
```

### WishlistMovie

Modelo compuesto recomendado para UI de wishlist.

```ts
type WishlistMovie = {
  tmdbId: number;
  addedAt: string;
  details?: MovieDetails;
};
```

### Notification

```ts
type Notification = {
  id: number;
  tmdbId: number;
  title: string;
  message: string;
  isRead: boolean;
  createdAt: string;
};
```

Mapeo:

| Fuente | Dominio |
| --- | --- |
| `NotificationDto.read` | `Notification.isRead` |

## Secuencias De Consumo Recomendadas

### Inicio De Aplicacion Con Token Guardado

1. Leer token desde almacenamiento seguro.
2. Si no hay token, mostrar pantalla de login.
3. Si hay token, llamar `GET /api/auth/me`.
4. Si responde `200`, hidratar usuario actual y navegar a la app.
5. Si responde `401`, eliminar token y mostrar login.

### Busqueda Con Paginacion

1. Usuario ingresa `query`.
2. Frontend llama `GET /api/catalog/search?query={query}&page=1`.
3. Renderiza `results`.
4. Si el usuario hace scroll y `page < total_pages`, llamar siguiente pagina.
5. Concatenar resultados evitando duplicados por `id`.

### Detalle De Pelicula Completo

1. Recibir `tmdbId` desde catalogo, busqueda, wishlist o notificacion.
2. Llamar `GET /api/catalog/details/{tmdbId}`.
3. En paralelo o despues, llamar `GET /api/streaming/{tmdbId}`.
4. Renderizar detalle y plataformas.
5. Consultar wishlist local o `GET /api/wishlist` para determinar si esta agregada.

### Wishlist Con Detalles Visuales

1. Llamar `GET /api/wishlist`.
2. Si retorna `[]`, mostrar estado vacio.
3. Por cada item, llamar `GET /api/catalog/details/{tmdbId}`.
4. Combinar `WishlistItemDto` con `MovieDetailsDto`.
5. Ordenar segun `addedAt` si el frontend necesita reforzar el orden.

### Notificaciones

1. Para badge, llamar `GET /api/notifications/unread`.
2. Para pantalla completa, llamar `GET /api/notifications`.
3. Al abrir o confirmar una notificacion, llamar `PATCH /api/notifications/{id}/read`.
4. Navegar al detalle usando `tmdbId` si corresponde.

## Consideraciones Para Generacion Automatica

### Naming

Los DTOs deben preservar los nombres JSON originales de la API:

| JSON API | Ejemplo |
| --- | --- |
| snake_case | `poster_path`, `backdrop_path`, `release_date`, `genre_ids`, `total_pages`, `total_results`, `source_id`, `web_url` |
| camelCase | `userId`, `username`, `email`, `token`, `tmdbId`, `addedAt`, `createdAt` |
| boolean expuesto | `read` |

Los modelos de dominio pueden usar camelCase idiomatico del frontend.

### Tipos Nullable

La documentacion base no declara explicitamente todos los campos nullable. Para robustez del frontend, tratar como potencialmente nullable:

| DTO | Campos recomendados como nullable |
| --- | --- |
| `MovieSearchItemDto` | `poster_path`, `backdrop_path` |
| `MovieDetailsDto` | `poster_path`, `backdrop_path`, `runtime` |

### Responses De Texto Plano

Estos endpoints no deben parsearse como JSON:

| Endpoint | Response |
| --- | --- |
| `POST /api/wishlist/{tmdbId}` | `PlainTextResponse` |
| `DELETE /api/wishlist/{tmdbId}` | `PlainTextResponse` |
| `PATCH /api/notifications/{id}/read` | `PlainTextResponse` |
| `POST /api/demo/simulate-change/{tmdbId}` | `PlainTextResponse` |

### Endpoints Excluidos Del Flujo Principal

| Endpoint | Motivo |
| --- | --- |
| `/h2-console/**` | Herramienta interna/backend, no debe ser consumida por frontend movil. |
| `/api/demo/simulate-change/{tmdbId}` | Solo pruebas manuales o entorno desarrollo. |

## Inventario Final De Endpoints Consumidos

| Feature | Metodo | Endpoint | Auth | Request | Response |
| --- | --- | --- | --- | --- | --- |
| Auth | `POST` | `/api/auth/register` | No | `RegisterRequestDto` | `AuthResponseDto` |
| Auth | `POST` | `/api/auth/login` | No | `LoginRequestDto` | `AuthResponseDto` |
| Auth | `GET` | `/api/auth/me` | Si | `EmptyBody` | `CurrentUserDto` |
| Catalog | `GET` | `/api/catalog/search` | Si | `SearchMoviesQueryDto` | `MovieSearchResponseDto` |
| Catalog | `GET` | `/api/catalog/details/{tmdbId}` | Si | `MovieDetailsPathDto` | `MovieDetailsDto` |
| Streaming | `GET` | `/api/streaming/{tmdbId}` | Si | `StreamingSourcesPathDto` | `StreamingSourceDto[]` |
| Wishlist | `POST` | `/api/wishlist/{tmdbId}` | Si | `WishlistMoviePathDto` | `PlainTextResponse` |
| Wishlist | `DELETE` | `/api/wishlist/{tmdbId}` | Si | `WishlistMoviePathDto` | `PlainTextResponse` |
| Wishlist | `GET` | `/api/wishlist` | Si | `EmptyBody` | `WishlistItemDto[]` |
| Notifications | `GET` | `/api/notifications` | Si | `EmptyBody` | `NotificationDto[]` |
| Notifications | `GET` | `/api/notifications/unread` | Si | `EmptyBody` | `NotificationDto[]` |
| Notifications | `PATCH` | `/api/notifications/{id}/read` | Si | `NotificationPathDto` | `PlainTextResponse` |
| Demo | `POST` | `/api/demo/simulate-change/{tmdbId}` | Si | `SimulatePlatformChangePathDto` + `SimulatePlatformChangeQueryDto` | `PlainTextResponse` |
