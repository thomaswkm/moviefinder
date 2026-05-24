# Plan de Implementacion - Iteracion 1

Este documento define el plan de implementacion para la primera iteracion del frontend de MovieFinder.

El alcance se basa en los mocks ubicados en `docs/mocks-ui/`, los requisitos funcionales de `docs/REQUERIMIENTOS.md` y los contratos de API definidos en `docs/FRONTEND_API_SPEC.md`.

## Alcance De La Iteracion

La primera iteracion abarca estos casos de uso:

| ID | Caso de uso | Pantalla mock | Estado |
| --- | --- | --- | --- |
| CU-01 | Registrar usuario | `Register.png` | Incluido |
| CU-02 | Iniciar sesion | `Login.png` | Incluido |
| CU-03 | Restaurar sesion | No aplica | Incluido |
| CU-04 | Ver peliculas | `Home.png` | Incluido |
| CU-05 | Buscar peliculas | `Home.png` | Incluido basico |
| CU-06 | Ver detalle de pelicula | `Information.png` | Incluido |
| CU-07 | Ver plataformas de una pelicula | `Information.png` | Incluido dentro del detalle |

Quedan fuera de esta iteracion:

| Caso | Motivo |
| --- | --- |
| Login con Google | No existe endpoint OAuth en la API actual. El boton se muestra deshabilitado. |
| Watchlist/Favorites | Existe mock `Favorites.png`, pero no forma parte del alcance inicial. |
| Recomendaciones de streaming | Existe mock `Information-1.png`, pero corresponde a una iteracion posterior. |
| Ratings y reviews | No forman parte de los mocks priorizados ni del alcance inicial. |
| Director y reparto | El endpoint actual de detalle no entrega esos campos. |

## Decisiones De Producto Para Esta Iteracion

| Decision | Resultado |
| --- | --- |
| Registro requiere `username`, pero el mock no lo muestra | El frontend genera `username` desde el email. |
| No hay endpoint de catalogo/trending general | Home usa una busqueda inicial fija. |
| Se requiere infraestructura API, pero no consumo real aun | Se implementan datasources remotos y mock; la app usa mock por defecto. |
| Boton Google aparece en mocks | Se muestra deshabilitado. |

## Configuracion Tecnica Base

### Modo De Datos

Crear una configuracion central para alternar entre mocks y API real:

```dart
const bool useMockData = true;
```

Comportamiento esperado:

| Valor | Comportamiento |
| --- | --- |
| `true` | Repositorios consumen datasources mock. |
| `false` | Repositorios consumen datasources remotos reales. |

### Query Inicial Fija

Para Home, definir una busqueda inicial fija:

```dart
const String defaultMovieSearchQuery = 'movie';
```

Esta query se usa para poblar la pantalla inicial mientras no exista un endpoint especifico de trending/catalogo.

### Generacion De Username

Regla:

```text
email: thomas@example.com
username generado: thomas
```

Si el email no tiene parte local valida:

```text
username generado: user
```

## Infraestructura Comun

Antes de implementar los casos de uso, crear la infraestructura compartida.

### Archivos Sugeridos

| Capa | Archivo sugerido | Responsabilidad |
| --- | --- | --- |
| Config | `lib/core/config/api_config.dart` | Base URL, query inicial, flag mock/API. |
| Network | `lib/core/network/api_client.dart` | Cliente HTTP comun. |
| Network | `lib/core/network/api_response_parser.dart` | Parseo JSON/texto y errores. |
| Errors | `lib/core/errors/api_exception.dart` | Error HTTP normalizado. |
| Storage | `lib/core/storage/token_storage.dart` | Lectura/escritura/limpieza de JWT. |
| Result | `lib/core/result/result.dart` | Resultado success/failure para casos de uso. |

### Responsabilidades Del ApiClient

El cliente debe quedar preparado para:

| Metodo | Uso |
| --- | --- |
| `get` | Endpoints de consulta. |
| `post` | Login, registro y acciones futuras. |
| `patch` | Marcar notificaciones como leidas en iteraciones futuras. |
| `delete` | Wishlist en iteraciones futuras. |

Headers esperados:

```http
Content-Type: application/json
Authorization: Bearer <token>
```

El header `Authorization` solo se agrega si existe token.

### Manejo De Errores

Normalizar respuestas de error hacia `ApiException`:

| Campo | Descripcion |
| --- | --- |
| `statusCode` | Codigo HTTP. |
| `message` | Mensaje de error general. |
| `requestId` | Valor de `X-Request-ID` si existe. |
| `fieldErrors` | Errores por campo cuando aplique. |

## CU-01 - Registrar Usuario

### Objetivo

Permitir que un usuario cree una cuenta desde la pantalla `Register.png`.

### Actor

Usuario no autenticado.

### Endpoint Preparado

```http
POST /api/auth/register
```

### DTOs

Entrada real hacia API:

```ts
type RegisterRequestDto = {
  username: string;
  email: string;
  password: string;
};
```

Salida:

```ts
type AuthResponseDto = {
  userId: number;
  email: string;
  username: string;
  token: string;
};
```

### Datos Del Formulario

| Campo UI | Obligatorio | Observacion |
| --- | --- | --- |
| `email` | Si | Se usa tambien para generar `username`. |
| `password` | Si | Se envia al backend. |
| `confirmPassword` | Si | Solo validacion local; no se envia al backend. |

### Validaciones Frontend

| Validacion | Mensaje esperado |
| --- | --- |
| Email vacio | Ingresar email. |
| Email invalido | Ingresar email valido. |
| Password vacio | Ingresar password. |
| Confirm password vacio | Confirmar password. |
| Password y confirm password no coinciden | Las contrasenas no coinciden. |

### Flujo Principal

1. Usuario abre pantalla de registro.
2. Usuario ingresa email, password y confirm password.
3. Frontend valida campos.
4. Frontend genera `username` desde email.
5. Se ejecuta caso de uso `RegisterUser`.
6. En modo mock, `AuthMockDataSource` devuelve usuario y token estatico.
7. En modo API real, `AuthRemoteDataSource` llama `POST /api/auth/register`.
8. Frontend guarda token.
9. Frontend navega a Home.

### Flujo Alternativo - Error De Validacion Local

1. Usuario confirma formulario incompleto o invalido.
2. No se llama al datasource.
3. UI muestra errores por campo.

### Flujo Alternativo - Error Backend

1. Backend responde `400`, `409` o `429`.
2. Repositorio convierte respuesta a failure.
3. Controller muestra mensaje general o errores por campo.

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `AuthenticatedUser` |
| Domain | `AuthRepository` |
| Domain | `RegisterUser` |
| Data | `RegisterRequestModel` |
| Data | `AuthResponseModel` |
| Data | `AuthRemoteDataSource` |
| Data | `AuthMockDataSource` |
| Data | `AuthRepositoryImpl` |
| Presentation | `RegisterController` |
| Presentation | `RegisterPage` |

### Criterios De Aceptacion

- El registro no muestra campo username.
- El username se genera desde email.
- Si las contrasenas no coinciden, no se intenta registrar.
- El boton Google se muestra deshabilitado.
- Al registrarse correctamente, se guarda token y se navega a Home.

## CU-02 - Iniciar Sesion

### Objetivo

Permitir que un usuario ingrese a la app usando email y password desde `Login.png`.

### Actor

Usuario no autenticado.

### Endpoint Preparado

```http
POST /api/auth/login
```

### DTOs

Entrada:

```ts
type LoginRequestDto = {
  email: string;
  password: string;
};
```

Salida:

```ts
type AuthResponseDto = {
  userId: number;
  email: string;
  username: string;
  token: string;
};
```

### Datos Del Formulario

| Campo UI | Obligatorio |
| --- | --- |
| `email` | Si |
| `password` | Si |

### Validaciones Frontend

| Validacion | Mensaje esperado |
| --- | --- |
| Email vacio | Ingresar email. |
| Email invalido | Ingresar email valido. |
| Password vacio | Ingresar password. |

### Flujo Principal

1. Usuario abre pantalla de login.
2. Usuario ingresa email y password.
3. Frontend valida campos.
4. Se ejecuta caso de uso `LoginUser`.
5. En modo mock, `AuthMockDataSource` devuelve usuario y token estatico.
6. En modo API real, `AuthRemoteDataSource` llama `POST /api/auth/login`.
7. Frontend guarda token.
8. Frontend navega a Home.

### Flujo Alternativo - Google

1. Usuario ve boton Google.
2. Boton esta deshabilitado.
3. No se ejecuta ningun endpoint.

### Flujo Alternativo - Error Backend

1. Backend responde `400`, `401` o `429`.
2. Repositorio convierte respuesta a failure.
3. Controller muestra mensaje de credenciales invalidas o error correspondiente.

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `LoginUser` |
| Data | `LoginRequestModel` |
| Presentation | `LoginController` |
| Presentation | `LoginPage` |

### Criterios De Aceptacion

- El usuario puede iniciar sesion con email y password.
- El boton Google se muestra deshabilitado.
- Al iniciar sesion correctamente, se guarda token y se navega a Home.
- Los errores se muestran sin cerrar la pantalla.

## CU-03 - Restaurar Sesion

### Objetivo

Validar si existe una sesion previa al iniciar la app.

### Actor

Usuario autenticado previamente.

### Endpoint Preparado

```http
GET /api/auth/me
```

### DTOs

Salida:

```ts
type CurrentUserDto = {
  id: number;
  username: string;
  email: string;
};
```

### Flujo Principal

1. App inicia.
2. Frontend consulta `TokenStorage`.
3. Si no hay token, navega a Login.
4. Si hay token, ejecuta `GetCurrentUser`.
5. En modo mock, devuelve usuario estatico.
6. En modo API real, llama `GET /api/auth/me`.
7. Si responde correctamente, navega a Home.

### Flujo Alternativo - Token Invalido

1. Backend responde `401`.
2. Frontend limpia token local.
3. Frontend navega a Login.

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `CurrentUser` |
| Domain | `GetCurrentUser` |
| Domain | `LogoutUser` |
| Data | `CurrentUserModel` |
| Presentation | `SplashPage` o `SessionGate` |

### Criterios De Aceptacion

- La app no muestra Home sin sesion valida.
- Si existe token valido, la app entra directo a Home.
- Si el token es invalido, se limpia y se muestra Login.

## CU-04 - Ver Peliculas

### Objetivo

Mostrar una pantalla Home con peliculas, inspirada en `Home.png`.

### Actor

Usuario autenticado.

### Endpoint Preparado

```http
GET /api/catalog/search?query={query}&page={page}
```

### DTOs

Query:

```ts
type SearchMoviesQueryDto = {
  query: string;
  page?: number;
};
```

Salida:

```ts
type MovieSearchResponseDto = {
  page: number;
  results: MovieSearchItemDto[];
  total_pages: number;
  total_results: number;
};
```

Item:

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

### Datos Mock Requeridos

Crear al menos 8 peliculas mock con:

| Campo | Uso UI |
| --- | --- |
| `tmdbId` | Navegacion a detalle. |
| `title` | Titulo de card. |
| `overview` | Preview o detalle posterior. |
| `posterPath` | Placeholder o asset remoto futuro. |
| `backdropPath` | Hero visual. |
| `releaseDate` | Año mostrado. |
| `genreIds` o generos mock | Chips visuales. |
| `popularity` | Ordenamiento mock opcional. |

### Flujo Principal

1. Usuario llega a Home despues de login/register/restauracion de sesion.
2. Controller ejecuta `SearchMovies` con query inicial fija `movie` y `page = 1`.
3. En modo mock, `MoviesMockDataSource` devuelve lista estatica.
4. En modo API real, `MoviesRemoteDataSource` llama `/api/catalog/search`.
5. UI muestra pelicula destacada y seccion `For you`.
6. Usuario puede desplazarse por la lista.
7. Usuario toca una pelicula.
8. App navega a detalle con `tmdbId`.

### Flujo Alternativo - Sin Resultados

1. Datasource devuelve lista vacia.
2. UI muestra estado vacio.

### Flujo Alternativo - Error

1. Datasource falla.
2. Controller expone estado error.
3. UI muestra mensaje y opcion reintentar.

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `MovieSummary` |
| Domain | `MoviesRepository` |
| Domain | `SearchMovies` |
| Data | `MovieSearchResponseModel` |
| Data | `MovieSearchItemModel` |
| Data | `MoviesRemoteDataSource` |
| Data | `MoviesMockDataSource` |
| Data | `MoviesRepositoryImpl` |
| Presentation | `HomeController` |
| Presentation | `HomePage` |
| Presentation | `MovieCard` |
| Presentation | `FeaturedMovieCard` |
| Presentation | `MainBottomNavigation` |

### Criterios De Aceptacion

- Home carga peliculas mock por defecto.
- Se usa una query inicial fija para simular el catalogo.
- La UI respeta el layout general de `Home.png`.
- Al tocar una pelicula, navega al detalle.
- La infraestructura remota queda lista para consumir `/api/catalog/search`.

## CU-05 - Buscar Peliculas

### Objetivo

Permitir una busqueda basica de peliculas desde Home.

### Actor

Usuario autenticado.

### Endpoint Preparado

```http
GET /api/catalog/search?query={query}&page={page}
```

### Flujo Principal

1. Usuario ingresa texto de busqueda.
2. Controller ejecuta `SearchMovies` con `query` ingresado y `page = 1`.
3. En modo mock, se filtra la lista estatica localmente por titulo.
4. En modo API real, se llama `/api/catalog/search`.
5. UI muestra resultados coincidentes.

### Flujo Alternativo - Query Vacia

1. Usuario limpia busqueda.
2. Controller vuelve a query inicial fija `movie`.
3. UI muestra listado inicial.

### Flujo Alternativo - Sin Coincidencias

1. No hay peliculas que coincidan.
2. UI muestra mensaje sin resultados.

### Paginacion

En modo mock:

| Comportamiento | Descripcion |
| --- | --- |
| `page = 1` | Devuelve primera porcion de datos mock. |
| `page > 1` | Puede devolver otra porcion mock o lista vacia. |

En modo API real:

| Condicion | Accion |
| --- | --- |
| `page < total_pages` | Permitir cargar mas. |
| `page >= total_pages` | Detener lazy loading. |

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Presentation | `MovieSearchField` |
| Presentation | Estados de busqueda en `HomeController` |

### Criterios De Aceptacion

- La busqueda filtra datos mock por titulo.
- Si no hay coincidencias, se muestra estado vacio.
- Si la query queda vacia, vuelve el listado inicial.
- La estructura queda preparada para paginacion real.

## CU-06 - Ver Detalle De Pelicula

### Objetivo

Mostrar informacion detallada de una pelicula seleccionada, basada en `Information.png`.

### Actor

Usuario autenticado.

### Endpoint Preparado

```http
GET /api/catalog/details/{tmdbId}
```

### DTOs

Path:

```ts
type MovieDetailsPathDto = {
  tmdbId: number;
};
```

Salida:

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

Genero:

```ts
type GenreDto = {
  id: number;
  name: string;
};
```

### Datos Mock Requeridos

Cada pelicula mock debe tener detalle asociado:

| Campo | Uso UI |
| --- | --- |
| `tmdbId` | Identificador. |
| `title` | Titulo principal. |
| `overview` | Sinopsis. |
| `posterPath` | Imagen vertical. |
| `backdropPath` | Imagen superior. |
| `releaseDate` | Fecha o año. |
| `runtimeMinutes` | Duracion. |
| `voteAverage` | Rating. |
| `genres` | Chips visuales. |

### Flujo Principal

1. Usuario toca una pelicula desde Home.
2. Router abre pantalla detalle con `tmdbId`.
3. Controller ejecuta `GetMovieDetails`.
4. En modo mock, `MoviesMockDataSource` busca detalle por `tmdbId`.
5. En modo API real, `MoviesRemoteDataSource` llama `/api/catalog/details/{tmdbId}`.
6. UI muestra backdrop, titulo, fecha, generos, duracion, rating y sinopsis.
7. Controller ejecuta tambien `GetStreamingSources` para plataformas.
8. UI muestra plataformas disponibles.

### Flujo Alternativo - Pelicula No Encontrada En Mock

1. Mock datasource no encuentra `tmdbId`.
2. Controller expone error.
3. UI muestra mensaje y boton volver.

### Flujo Alternativo - Error API Real

1. Backend responde error o TMDB no disponible.
2. UI muestra error y opcion reintentar.

### Elementos Visuales Del Mock

| Elemento | Estado Iteracion 1 |
| --- | --- |
| Back button | Funcional. |
| Menu de tres puntos | Visual o no implementado. |
| Boton play | Visual, sin funcionalidad. |
| Corazon/favorito | Visual, sin wishlist aun. |
| Plataformas | Funcional con mock/static. |
| See all plataformas | Visual o no implementado. |

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `MovieDetails` |
| Domain | `Genre` |
| Domain | `GetMovieDetails` |
| Data | `MovieDetailsModel` |
| Data | `GenreModel` |
| Presentation | `MovieDetailController` |
| Presentation | `MovieDetailPage` |
| Presentation | `MovieGenreChip` |
| Presentation | `MovieBackdropHeader` |

### Criterios De Aceptacion

- El usuario puede abrir detalle desde Home.
- El detalle muestra informacion mock consistente con la pelicula seleccionada.
- Se muestra sinopsis, generos, duracion y rating.
- Los campos no disponibles en API actual, como director y reparto, no se muestran en esta iteracion.
- La infraestructura remota queda lista para consumir `/api/catalog/details/{tmdbId}`.

## CU-07 - Ver Plataformas De Una Pelicula

### Objetivo

Mostrar plataformas disponibles dentro del detalle de pelicula.

### Actor

Usuario autenticado.

### Endpoint Preparado

```http
GET /api/streaming/{tmdbId}
```

### DTOs

Path:

```ts
type StreamingSourcesPathDto = {
  tmdbId: number;
};
```

Salida:

```ts
type StreamingSourceDto = {
  source_id: number;
  name: string;
  type: 'sub' | 'rent' | 'buy' | 'free' | string;
  region: string;
  web_url: string;
  format: string;
};
```

### Datos Mock Requeridos

Crear plataformas mock por pelicula:

| Plataforma | Tipo sugerido | Label UI |
| --- | --- | --- |
| Netflix | `sub` | Incluida |
| Amazon Prime Video | `sub` | Incluida |
| Apple TV | `rent` | Arriendo |
| Google Play Movies | `buy` | Compra |

### Flujo Principal

1. Pantalla detalle recibe `tmdbId`.
2. Controller ejecuta `GetStreamingSources`.
3. En modo mock, `StreamingMockDataSource` devuelve plataformas estaticas.
4. En modo API real, `StreamingRemoteDataSource` llama `/api/streaming/{tmdbId}`.
5. UI muestra cards/logos/nombres de plataformas.
6. UI muestra o prepara label de modalidad.

### Flujo Alternativo - Sin Plataformas

1. Datasource devuelve `[]`.
2. UI muestra mensaje de plataformas no disponibles.

### Componentes A Crear

| Capa | Componente |
| --- | --- |
| Domain | `StreamingSource` |
| Domain | `StreamingRepository` |
| Domain | `GetStreamingSources` |
| Data | `StreamingSourceModel` |
| Data | `StreamingRemoteDataSource` |
| Data | `StreamingMockDataSource` |
| Data | `StreamingRepositoryImpl` |
| Presentation | `StreamingPlatformList` |
| Presentation | `StreamingPlatformCard` |

### Criterios De Aceptacion

- El detalle muestra plataformas mock.
- Si no hay plataformas, se muestra estado vacio.
- La infraestructura remota queda lista para consumir `/api/streaming/{tmdbId}`.

## Navegacion De La Iteracion

### Rutas Sugeridas

| Ruta | Pantalla | Acceso |
| --- | --- | --- |
| `/` | `SessionGate` o `SplashPage` | Publico |
| `/login` | `LoginPage` | Publico |
| `/register` | `RegisterPage` | Publico |
| `/home` | `HomePage` | Requiere sesion |
| `/movie/:tmdbId` | `MovieDetailPage` | Requiere sesion |

### Flujo De Navegacion

```text
App start
  -> SessionGate
    -> token ausente -> Login
    -> token valido -> Home

Login
  -> exito -> Home
  -> link Sign up -> Register

Register
  -> exito -> Home

Home
  -> tap pelicula -> MovieDetail

MovieDetail
  -> back -> Home
```

## Estados De UI Requeridos

Cada pantalla con carga de datos debe soportar:

| Estado | Descripcion |
| --- | --- |
| `idle` | Estado inicial antes de accion. |
| `loading` | Request o mock delay en curso. |
| `success` | Datos disponibles. |
| `empty` | Request correcto sin datos. |
| `error` | Fallo de validacion, red o backend. |

## Orden De Implementacion Recomendado

1. Crear configuracion base `ApiConfig` y flag `useMockData`.
2. Crear `Result`, `ApiException`, `TokenStorage` y `ApiClient`.
3. Implementar feature Auth completa con mocks.
4. Implementar routing inicial y `SessionGate`.
5. Implementar Home con Movies mock.
6. Implementar busqueda local mock.
7. Implementar detalle de pelicula con Movies mock.
8. Implementar Streaming mock dentro del detalle.
9. Crear datasources remotos para Auth, Movies y Streaming segun contratos.
10. Ajustar UI para respetar mocks visuales.
11. Ejecutar analisis, formato y pruebas basicas.

## Checklist Final De La Iteracion

### Auth

- [ ] Login renderiza segun mock.
- [ ] Register renderiza segun mock.
- [ ] Google button esta deshabilitado.
- [ ] Register genera username desde email.
- [ ] Login guarda token mock.
- [ ] Register guarda token mock.
- [ ] SessionGate restaura sesion mock.

### Movies

- [ ] Home renderiza segun mock.
- [ ] Home carga datos mock con query inicial fija.
- [ ] Busqueda filtra datos mock.
- [ ] Estado vacio aparece cuando no hay resultados.
- [ ] Tap en pelicula navega a detalle.

### Detail

- [ ] Detail renderiza segun mock.
- [ ] Detail carga datos mock por `tmdbId`.
- [ ] Detail muestra sinopsis, generos, duracion y rating.
- [ ] Detail muestra plataformas mock.
- [ ] Back button vuelve a Home.

### Infraestructura

- [ ] `ApiClient` soporta GET/POST/PATCH/DELETE.
- [ ] `AuthRemoteDataSource` queda preparado.
- [ ] `MoviesRemoteDataSource` queda preparado.
- [ ] `StreamingRemoteDataSource` queda preparado.
- [ ] Repositorios alternan mock/API con `useMockData`.
- [ ] Errores se normalizan con `ApiException`.

## Riesgos Y Pendientes

| Riesgo/Pendiente | Impacto | Mitigacion |
| --- | --- | --- |
| No existe endpoint trending/catalogo | Home no puede cargar catalogo real sin query. | Usar query inicial fija en iteracion 1. |
| Register API exige username pero mock no lo incluye | Registro real fallaria si no se envia. | Generar username desde email. |
| Google no tiene backend | Boton no puede funcionar. | Mostrar deshabilitado. |
| Detalle no trae director/reparto | RF-03 no queda completo al 100%. | No mostrar campos o marcarlos para iteracion futura. |
| Imagenes TMDB son paths relativos | UI no puede renderizar URL directa sin base. | Configurar `tmdbImageBaseUrl`. |

## Definicion De Terminado

La iteracion se considera terminada cuando:

- La app inicia en `SessionGate`.
- Un usuario puede registrarse usando datos mock.
- Un usuario puede iniciar sesion usando datos mock.
- La sesion queda almacenada localmente.
- Home muestra peliculas mock.
- Home permite buscar localmente.
- Home permite abrir detalle.
- Detail muestra informacion y plataformas mock.
- La infraestructura remota para API real existe, aunque no sea usada por defecto.
- El cambio de `useMockData` a `false` deja el camino listo para conectar la API real con ajustes minimos.
