package backend.moviefinder.catalog.service;

import backend.moviefinder.catalog.dto.HomeMediaItemDto;
import backend.moviefinder.catalog.dto.TmdbMovieDetailsDto;
import backend.moviefinder.catalog.dto.TmdbMovieDto;
import backend.moviefinder.catalog.dto.TmdbSearchResponseDto;
import backend.moviefinder.catalog.dto.TmdbTvDto;
import backend.moviefinder.catalog.dto.TmdbTvDetailsDto;
import backend.moviefinder.catalog.dto.TmdbTvResponseDto;
import backend.moviefinder.core.exceptions.ExternalApiException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Collectors;

@Service
public class CatalogService {

    private static final String TMDB_IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500";

    private static final Map<Integer, String> MOVIE_GENRES = Map.ofEntries(
            Map.entry(28, "Accion"),
            Map.entry(12, "Aventura"),
            Map.entry(16, "Animacion"),
            Map.entry(35, "Comedia"),
            Map.entry(80, "Crimen"),
            Map.entry(99, "Documental"),
            Map.entry(18, "Drama"),
            Map.entry(10751, "Familia"),
            Map.entry(14, "Fantasia"),
            Map.entry(36, "Historia"),
            Map.entry(27, "Terror"),
            Map.entry(10402, "Musica"),
            Map.entry(9648, "Misterio"),
            Map.entry(10749, "Romance"),
            Map.entry(878, "Ciencia ficcion"),
            Map.entry(10770, "Pelicula de TV"),
            Map.entry(53, "Suspenso"),
            Map.entry(10752, "Belico"),
            Map.entry(37, "Western")
    );

    private static final Map<Integer, String> TV_GENRES = Map.ofEntries(
            Map.entry(10759, "Accion y aventura"),
            Map.entry(16, "Animacion"),
            Map.entry(35, "Comedia"),
            Map.entry(80, "Crimen"),
            Map.entry(99, "Documental"),
            Map.entry(18, "Drama"),
            Map.entry(10751, "Familia"),
            Map.entry(10762, "Kids"),
            Map.entry(9648, "Misterio"),
            Map.entry(10763, "Noticias"),
            Map.entry(10764, "Reality"),
            Map.entry(10765, "Sci-Fi y fantasia"),
            Map.entry(10766, "Soap"),
            Map.entry(10767, "Talk"),
            Map.entry(10768, "Guerra y politica"),
            Map.entry(37, "Western")
    );

    private final RestTemplate restTemplate;
    private final ExecutorService executor = Executors.newFixedThreadPool(5);

    @Value("${tmdb.api.url}")
    private String tmdbApiUrl;

    @Value("${tmdb.api.key}")
    private String tmdbApiKey;

    public CatalogService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public TmdbSearchResponseDto searchMovies(String query, int page) {
        try {
            String url = UriComponentsBuilder.fromUriString(tmdbApiUrl + "/search/movie")
                    .queryParam("api_key", tmdbApiKey)
                    .queryParam("query", query)
                    .queryParam("language", "es-ES")
                    .queryParam("page", page)
                    .toUriString();

            return restTemplate.getForObject(url, TmdbSearchResponseDto.class);

        } catch (RestClientException e) {
            throw new ExternalApiException("Error al conectar con TMDB: " + e.getMessage(), HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    public List<HomeMediaItemDto> getHomeMedia(String timeWindow, int page) {
        return getHomeMedia(timeWindow, page, "all");
    }

    public List<HomeMediaItemDto> getHomeMedia(String timeWindow, int page, String mediaType) {
        String normalizedType = mediaType == null ? "all" : mediaType.trim().toLowerCase();
        boolean includeMovies = !"series".equals(normalizedType) && !"tv".equals(normalizedType);
        boolean includeTv = !"movie".equals(normalizedType) && !"movies".equals(normalizedType);
        TmdbSearchResponseDto movies = includeMovies ? getTrendingMovies(timeWindow, page) : null;
        TmdbTvResponseDto tv = includeTv ? getTrendingTv(timeWindow, page) : null;

        List<HomeMediaItemDto> items = new ArrayList<>();

        if (movies != null && movies.getResults() != null) {
            List<HomeMediaItemDto> movieItems = movies.getResults().stream()
                    .map(m -> toHomeMovie(m, null))
                    .filter(Objects::nonNull)
                    .toList();
            items.addAll(movieItems);
        }

        if (tv != null && tv.getResults() != null) {
            tv.getResults().stream()
                    .map(this::toHomeTv)
                    .filter(Objects::nonNull)
                    .forEach(items::add);
        }

        items.sort((a, b) -> Double.compare(
                b.getRating() == null ? 0 : b.getRating(),
                a.getRating() == null ? 0 : a.getRating()
        ));
        return items;
    }

    public List<HomeMediaItemDto> searchHomeMedia(String query, int page) {
        TmdbSearchResponseDto response = searchMovies(query, page);
        if (response == null || response.getResults() == null) {
            return List.of();
        }

        List<HomeMediaItemDto> items = response.getResults().stream()
                .map(m -> toHomeMovie(m, null))
                .filter(Objects::nonNull)
                .toList();

        Map<Long, Integer> runtimes = fetchRuntimes(items);
        items.forEach(item -> {
            if (item.getDurationMinutes() == null && runtimes.containsKey(item.getId())) {
                item.setDurationMinutes(runtimes.get(item.getId()));
            }
        });

        return items;
    }

    public HomeMediaItemDto getMovieAsHomeMedia(Long tmdbId) {
        TmdbMovieDetailsDto details = getMovieDetails(tmdbId);
        if (details == null) {
            return null;
        }

        List<String> genres = details.getGenres() == null
                ? List.of()
                : details.getGenres().stream().map(genre -> genre.getName()).toList();

        return new HomeMediaItemDto(
                details.getId(),
                "movie",
                fallback(details.getTitle(), "Sin titulo"),
                fallback(details.getTitle(), "Sin titulo"),
                fallback(details.getOverview(), ""),
                posterUrl(details.getPosterPath()),
                yearFromDate(details.getReleaseDate()),
                details.getVoteAverage(),
                genres,
                details.getRuntime(),
                null,
                null,
                null,
                null
        );
    }

    public HomeMediaItemDto getTvAsHomeMedia(Long tmdbId) {
        TmdbTvDetailsDto details = getTvDetails(tmdbId);
        if (details == null) {
            return null;
        }

        List<String> genres = details.getGenres() == null
                ? List.of()
                : details.getGenres().stream().map(genre -> genre.getName()).toList();

        return new HomeMediaItemDto(
                details.getId(),
                "series",
                fallback(details.getName(), "Sin titulo"),
                fallback(details.getOriginalName(), fallback(details.getName(), "Sin titulo")),
                fallback(details.getOverview(), ""),
                posterUrl(details.getPosterPath()),
                yearFromDate(details.getFirstAirDate()),
                details.getVoteAverage(),
                genres,
                null,
                details.getNumberOfSeasons(),
                details.getNumberOfEpisodes(),
                null,
                null
        );
    }

    public HomeMediaItemDto getMediaAsHomeMedia(Long tmdbId, String mediaType) {
        if ("series".equals(mediaType) || "tv".equals(mediaType)) {
            return getTvAsHomeMedia(tmdbId);
        }
        return getMovieAsHomeMedia(tmdbId);
    }

    // Nuevo metodo para obtener los detalles de una sola película
    public TmdbMovieDetailsDto getMovieDetails(Long tmdbId) {
        try {
            // La URL ahora apunta a /movie/{id} en lugar de /search/movie
            String url = UriComponentsBuilder.fromUriString(tmdbApiUrl + "/movie/" + tmdbId)
                    .queryParam("api_key", tmdbApiKey)
                    .queryParam("language", "es-ES") // En español
                    .toUriString();

            return restTemplate.getForObject(url, TmdbMovieDetailsDto.class);

        } catch (RestClientException e) {
            throw new ExternalApiException("Error al obtener detalles de TMDB: " + e.getMessage(), HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    public TmdbTvDetailsDto getTvDetails(Long tmdbId) {
        try {
            String url = UriComponentsBuilder.fromUriString(tmdbApiUrl + "/tv/" + tmdbId)
                    .queryParam("api_key", tmdbApiKey)
                    .queryParam("language", "es-ES")
                    .toUriString();

            return restTemplate.getForObject(url, TmdbTvDetailsDto.class);

        } catch (RestClientException e) {
            throw new ExternalApiException("Error al obtener detalles de TMDB: " + e.getMessage(), HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    private static final Map<String, String> MOVIE_CATEGORIES = Map.of(
        "popular", "/movie/popular",
        "top_rated", "/movie/top_rated",
        "upcoming", "/movie/upcoming",
        "now_playing", "/movie/now_playing"
    );

    private static final Map<String, String> TV_CATEGORIES = Map.of(
        "popular", "/tv/popular",
        "top_rated", "/tv/top_rated",
        "on_the_air", "/tv/on_the_air",
        "airing_today", "/tv/airing_today"
    );

    public TmdbSearchResponseDto browseMovies(String category, int page) {
        String endpoint = MOVIE_CATEGORIES.get(category);
        if (endpoint == null) {
            throw new ExternalApiException("Categoría de película no válida: " + category, HttpStatus.BAD_REQUEST);
        }
        return fetchTmdbList(endpoint, TmdbSearchResponseDto.class, page);
    }

    public TmdbTvResponseDto browseTv(String category, int page) {
        String endpoint = TV_CATEGORIES.get(category);
        if (endpoint == null) {
            throw new ExternalApiException("Categoría de TV no válida: " + category, HttpStatus.BAD_REQUEST);
        }
        return fetchTmdbList(endpoint, TmdbTvResponseDto.class, page);
    }

    public TmdbSearchResponseDto getTrendingMovies(String timeWindow, int page) {
        if (!timeWindow.equals("day") && !timeWindow.equals("week")) {
            throw new ExternalApiException("Periodo no válido: " + timeWindow, HttpStatus.BAD_REQUEST);
        }
        return fetchTmdbList("/trending/movie/" + timeWindow, TmdbSearchResponseDto.class, page);
    }

    public TmdbTvResponseDto getTrendingTv(String timeWindow, int page) {
        if (!timeWindow.equals("day") && !timeWindow.equals("week")) {
            throw new ExternalApiException("Periodo no válido: " + timeWindow, HttpStatus.BAD_REQUEST);
        }
        return fetchTmdbList("/trending/tv/" + timeWindow, TmdbTvResponseDto.class, page);
    }

    private <T> T fetchTmdbList(String path, Class<T> responseType, int page) {
        try {
            String url = UriComponentsBuilder.fromUriString(tmdbApiUrl + path)
                    .queryParam("api_key", tmdbApiKey)
                    .queryParam("language", "es-ES")
                    .queryParam("page", page)
                    .toUriString();
            return restTemplate.getForObject(url, responseType);
        } catch (RestClientException e) {
            throw new ExternalApiException("Error al conectar con TMDB: " + e.getMessage(), HttpStatus.SERVICE_UNAVAILABLE);
        }
    }

    private HomeMediaItemDto toHomeMovie(TmdbMovieDto movie, Integer runtime) {
        if (movie == null || movie.getId() == null) {
            return null;
        }

        return new HomeMediaItemDto(
                movie.getId(),
                "movie",
                fallback(movie.getTitle(), "Sin titulo"),
                fallback(movie.getOriginalTitle(), fallback(movie.getTitle(), "Sin titulo")),
                fallback(movie.getOverview(), ""),
                posterUrl(movie.getPosterPath()),
                yearFromDate(movie.getReleaseDate()),
                movie.getVoteAverage(),
                genreNames(movie.getGenreIds(), MOVIE_GENRES),
                runtime,
                null,
                null,
                null,
                null
        );
    }

    private HomeMediaItemDto toHomeTv(TmdbTvDto tv) {
        if (tv == null || tv.getId() == null) {
            return null;
        }

        return new HomeMediaItemDto(
                tv.getId(),
                "series",
                fallback(tv.getName(), "Sin titulo"),
                fallback(tv.getOriginalName(), fallback(tv.getName(), "Sin titulo")),
                fallback(tv.getOverview(), ""),
                posterUrl(tv.getPosterPath()),
                yearFromDate(tv.getFirstAirDate()),
                tv.getVoteAverage(),
                genreNames(tv.getGenreIds(), TV_GENRES),
                null,
                null,
                null,
                null,
                null
        );
    }

    private String posterUrl(String posterPath) {
        if (posterPath == null || posterPath.isBlank()) {
            return "";
        }
        return TMDB_IMAGE_BASE_URL + posterPath;
    }

    private Integer yearFromDate(String date) {
        if (date == null || date.length() < 4) {
            return null;
        }
        try {
            return Integer.parseInt(date.substring(0, 4));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private List<String> genreNames(List<Integer> genreIds, Map<Integer, String> genres) {
        if (genreIds == null || genreIds.isEmpty()) {
            return Collections.emptyList();
        }
        return genreIds.stream()
                .map(genres::get)
                .filter(Objects::nonNull)
                .toList();
    }

    private String fallback(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }

    private Map<Long, Integer> fetchRuntimes(List<HomeMediaItemDto> items) {
        List<Long> movieIds = items.stream()
                .filter(item -> "movie".equals(item.getType()))
                .map(HomeMediaItemDto::getId)
                .filter(Objects::nonNull)
                .toList();

        if (movieIds.isEmpty()) {
            return Map.of();
        }

        List<CompletableFuture<Map.Entry<Long, Integer>>> futures = movieIds.stream()
                .map(id -> CompletableFuture.supplyAsync(() -> {
                    try {
                        TmdbMovieDetailsDto details = getMovieDetails(id);
                        return Map.<Long, Integer>entry(id, details != null ? details.getRuntime() : null);
                    } catch (Exception e) {
                        return Map.<Long, Integer>entry(id, null);
                    }
                }, executor))
                .toList();

        return futures.stream()
                .map(CompletableFuture::join)
                .filter(e -> e.getValue() != null)
                .collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
    }
}
