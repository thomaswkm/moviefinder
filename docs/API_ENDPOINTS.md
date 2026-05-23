# Movie Finder Backend API

Especificación de endpoints para clientes móviles que consumen la API Spring Boot ubicada en `moviefinderbackend/`.

## Base URL

Usa la URL donde esté corriendo el backend y antepone `/api` a los endpoints documentados.

Ejemplo local:

```text
http://localhost:8080
```

## Autenticación

La API usa JWT stateless.

Endpoints públicos:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `/h2-console/**`

Todos los demás endpoints requieren autenticación.

Para móvil, envía el token recibido en login/registro con este header:

```http
Authorization: Bearer <token>
```

El backend también acepta el JWT desde la cookie `accessCookie`, pero para móvil es más directo usar el header `Authorization`.

Headers recomendados:

```http
Content-Type: application/json
Authorization: Bearer <token>
```

Cada respuesta incluye el header `X-Request-ID` generado por el backend.

## Errores Comunes

Formato habitual de error:

```json
{
  "error": "mensaje del error"
}
```

Errores de validación en `register` devuelven un objeto por campo:

```json
{
  "email": "El formato del correo electrónico no es válido",
  "password": "La contraseña es obligatoria"
}
```

Códigos relevantes:

- `400 Bad Request`: validación fallida, email existente, username existente o error de demo.
- `401 Unauthorized`: token ausente, inválido o expirado.
- `409 Conflict`: conflicto de base de datos, por ejemplo email duplicado.
- `429 Too Many Requests`: límite de peticiones superado.
- `500 Internal Server Error`: error no controlado.
- `503 Service Unavailable`: error al comunicarse con TMDB o Watchmode.

Rate limits actuales por IP:

- `/api/auth/**`: 60 requests por minuto.
- Resto: 300 requests por minuto.

## Auth

### Registrar Usuario

```http
POST /api/auth/register
```

Autenticación: no requerida.

Body JSON:

```json
{
  "username": "thomas",
  "email": "thomas@example.com",
  "password": "secret123"
}
```

Validaciones:

- `username`: obligatorio.
- `email`: obligatorio y formato email válido.
- `password`: obligatorio.

Respuesta `200 OK`:

```json
{
  "userId": 1,
  "email": "thomas@example.com",
  "username": "thomas",
  "token": "jwt-token"
}
```

También devuelve header `Set-Cookie` con `accessCookie`, aunque el cliente móvil puede ignorarlo y guardar `token`.

### Iniciar Sesión

```http
POST /api/auth/login
```

Autenticación: no requerida.

Body JSON:

```json
{
  "email": "thomas@example.com",
  "password": "secret123"
}
```

Respuesta `200 OK`:

```json
{
  "userId": 1,
  "email": "thomas@example.com",
  "username": "thomas",
  "token": "jwt-token"
}
```

También devuelve header `Set-Cookie` con `accessCookie`.

### Usuario Actual

```http
GET /api/auth/me
```

Autenticación: requerida.

Respuesta `200 OK`:

```json
{
  "id": 1,
  "username": "thomas",
  "email": "thomas@example.com"
}
```

## Catálogo TMDB

### Buscar Películas

```http
GET /api/catalog/search?query={texto}&page={pagina}
```

Autenticación: requerida.

Query params:

- `query` requerido: texto de búsqueda.
- `page` opcional: página de resultados, default `1`.

Ejemplo:

```http
GET /api/catalog/search?query=matrix&page=1
```

Respuesta `200 OK`:

```json
{
  "page": 1,
  "results": [
    {
      "id": 603,
      "title": "The Matrix",
      "overview": "...",
      "poster_path": "/poster.jpg",
      "backdrop_path": "/backdrop.jpg",
      "release_date": "1999-03-31",
      "genre_ids": [28, 878],
      "popularity": 80.5
    }
  ],
  "total_pages": 10,
  "total_results": 200
}
```

Notas:

- Los campos de imagen son paths de TMDB, no URLs absolutas.
- El backend consulta TMDB con idioma `es-ES`.

### Detalle de Película

```http
GET /api/catalog/details/{tmdbId}
```

Autenticación: requerida.

Path params:

- `tmdbId`: ID de película en TMDB.

Respuesta `200 OK`:

```json
{
  "id": 603,
  "title": "The Matrix",
  "overview": "...",
  "poster_path": "/poster.jpg",
  "backdrop_path": "/backdrop.jpg",
  "release_date": "1999-03-31",
  "runtime": 136,
  "vote_average": 8.2,
  "genres": [
    {
      "id": 28,
      "name": "Acción"
    }
  ]
}
```

## Streaming Watchmode

### Obtener Fuentes de Streaming

```http
GET /api/streaming/{tmdbId}
```

Autenticación: requerida.

Path params:

- `tmdbId`: ID de película en TMDB.

Respuesta `200 OK`:

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

Si Watchmode no devuelve resultados, la respuesta es una lista vacía:

```json
[]
```

Notas:

- El backend convierte internamente `tmdbId` a Watchmode usando el formato `movie-{tmdbId}`.
- Valores esperados de `type` incluyen `sub`, `rent`, `buy` y `free`.

## Wishlist

### Agregar Película a Wishlist

```http
POST /api/wishlist/{tmdbId}
```

Autenticación: requerida.

Path params:

- `tmdbId`: ID de película en TMDB.

Body: no requiere body.

Respuesta `200 OK`:

```text
Película agregada a tu lista.
```

Notas:

- Si la película ya existe para el usuario, no crea duplicado y responde `200 OK` igual.

### Eliminar Película de Wishlist

```http
DELETE /api/wishlist/{tmdbId}
```

Autenticación: requerida.

Path params:

- `tmdbId`: ID de película en TMDB.

Respuesta `200 OK`:

```text
Película eliminada de tu lista.
```

### Obtener Wishlist del Usuario

```http
GET /api/wishlist
```

Autenticación: requerida.

Respuesta `200 OK`:

```json
[
  {
    "tmdbId": 603,
    "addedAt": "2026-05-23T18:30:00"
  }
]
```

Notas:

- La lista se ordena por `addedAt` descendente.
- El endpoint devuelve solo `tmdbId` y `addedAt`; para mostrar título/poster, consulta `/api/catalog/details/{tmdbId}`.

## Notificaciones

### Obtener Todas las Notificaciones

```http
GET /api/notifications
```

Autenticación: requerida.

Respuesta `200 OK`:

```json
[
  {
    "id": 10,
    "tmdbId": 603,
    "title": "¡Nueva plataforma disponible!",
    "message": "La película 'The Matrix' ahora está disponible en Netflix.",
    "read": false,
    "createdAt": "2026-05-23T18:30:00"
  }
]
```

### Obtener Notificaciones No Leídas

```http
GET /api/notifications/unread
```

Autenticación: requerida.

Respuesta `200 OK`:

```json
[
  {
    "id": 10,
    "tmdbId": 603,
    "title": "¡Nueva plataforma disponible!",
    "message": "La película 'The Matrix' ahora está disponible en Netflix.",
    "read": false,
    "createdAt": "2026-05-23T18:30:00"
  }
]
```

Nota sobre JSON:

- El DTO usa un campo Java `boolean isRead`; en JSON se expone como `read` por convención JavaBean/Jackson.

### Marcar Notificación como Leída

```http
PATCH /api/notifications/{id}/read
```

Autenticación: requerida.

Path params:

- `id`: ID de la notificación.

Body: no requiere body.

Respuesta `200 OK`:

```text
Notificación marcada como leída
```

## Demo / Simulación

Estos endpoints existen para pruebas manuales y simulación; no representan el flujo productivo real de notificaciones.

### Simular Cambio de Plataforma

```http
POST /api/demo/simulate-change/{tmdbId}?newPlatform={plataforma}&movieName={nombre}
```

Autenticación: requerida.

Path params:

- `tmdbId`: ID de película en TMDB.

Query params:

- `newPlatform`: nombre de la plataforma nueva.
- `movieName`: nombre de la película.

Ejemplo:

```http
POST /api/demo/simulate-change/603?newPlatform=Netflix&movieName=The%20Matrix
```

Respuesta `200 OK`:

```text
Simulación exitosa. Se enviaron 2 notificaciones.
```

Respuesta `400 Bad Request` si ningún usuario tiene la película en wishlist:

```text
Ningún usuario tiene la película con ID 603 en su Wishlist.
```

## Resumen de Endpoints

| Método | Endpoint | Auth | Descripción |
| --- | --- | --- | --- |
| `POST` | `/api/auth/register` | No | Registrar usuario |
| `POST` | `/api/auth/login` | No | Iniciar sesión |
| `GET` | `/api/auth/me` | Sí | Obtener usuario autenticado |
| `GET` | `/api/catalog/search` | Sí | Buscar películas TMDB |
| `GET` | `/api/catalog/details/{tmdbId}` | Sí | Obtener detalle TMDB |
| `GET` | `/api/streaming/{tmdbId}` | Sí | Obtener disponibilidad streaming |
| `POST` | `/api/wishlist/{tmdbId}` | Sí | Agregar película a wishlist |
| `DELETE` | `/api/wishlist/{tmdbId}` | Sí | Eliminar película de wishlist |
| `GET` | `/api/wishlist` | Sí | Listar wishlist del usuario |
| `GET` | `/api/notifications` | Sí | Listar notificaciones |
| `GET` | `/api/notifications/unread` | Sí | Listar notificaciones no leídas |
| `PATCH` | `/api/notifications/{id}/read` | Sí | Marcar notificación como leída |
| `POST` | `/api/demo/simulate-change/{tmdbId}` | Sí | Simular cambio de plataforma |
