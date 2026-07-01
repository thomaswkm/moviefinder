package backend.moviefinder.wishlist.service;

import backend.moviefinder.auth.model.User;
import backend.moviefinder.auth.repository.UserRepository;
import backend.moviefinder.catalog.dto.HomeMediaItemDto;
import backend.moviefinder.catalog.service.CatalogService;
import backend.moviefinder.wishlist.dto.WishlistMovieDto;
import backend.moviefinder.wishlist.model.WishlistMovie;
import backend.moviefinder.wishlist.repository.WishlistMovieRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WishlistService {

    private final WishlistMovieRepository wishlistRepository;
    private final UserRepository userRepository;
    private final CatalogService catalogService;

    public WishlistService(WishlistMovieRepository wishlistRepository, UserRepository userRepository, CatalogService catalogService) {
        this.wishlistRepository = wishlistRepository;
        this.userRepository = userRepository;
        this.catalogService = catalogService;
    }

    // 1. Agregar a la lista
    public String addMovie(String email, Long tmdbId, String mediaType) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
        String normalizedType = normalizeMediaType(mediaType);

        if (wishlistRepository.existsByUserAndTmdbIdAndMediaType(user, tmdbId, normalizedType)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "La película ya está en tu lista");
        }

        WishlistMovie movie = new WishlistMovie();
        movie.setUser(user);
        movie.setTmdbId(tmdbId);
        movie.setMediaType(normalizedType);
        wishlistRepository.save(movie);
        return normalizedType;
    }

    // 2. Eliminar de la lista
    public String removeMovie(String email, Long tmdbId, String mediaType) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));
        String normalizedType = normalizeMediaType(mediaType);

        WishlistMovie movie = wishlistRepository.findByUserAndTmdbIdAndMediaType(user, tmdbId, normalizedType)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "La película no está en tu lista"));

        wishlistRepository.delete(movie);
        return normalizedType;
    }

    // 3. Obtener la lista del usuario
    public List<WishlistMovieDto> getUserWishlist(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        return wishlistRepository.findByUserOrderByAddedAtDesc(user)
                .stream()
                .map(movie -> {
                    WishlistMovieDto dto = new WishlistMovieDto();
                    dto.setTmdbId(movie.getTmdbId());
                    dto.setMediaType(movie.getMediaType());
                    dto.setAddedAt(movie.getAddedAt());
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<HomeMediaItemDto> getUserWishlistMedia(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Usuario no encontrado"));

        return wishlistRepository.findByUserOrderByAddedAtDesc(user)
                .stream()
                .map(movie -> catalogService.getMediaAsHomeMedia(movie.getTmdbId(), movie.getMediaType()))
                .filter(dto -> dto != null)
                .collect(Collectors.toList());
    }

    private String normalizeMediaType(String mediaType) {
        if ("series".equals(mediaType) || "tv".equals(mediaType)) {
            return "series";
        }
        return "movie";
    }
}
