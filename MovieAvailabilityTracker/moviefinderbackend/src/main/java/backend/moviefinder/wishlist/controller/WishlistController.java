package backend.moviefinder.wishlist.controller;

import backend.moviefinder.catalog.dto.HomeMediaItemDto;
import backend.moviefinder.wishlist.dto.WishlistActionResponseDto;
import backend.moviefinder.wishlist.dto.WishlistMovieDto;
import backend.moviefinder.wishlist.service.WishlistService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/wishlist")
public class WishlistController {

    private final WishlistService wishlistService;

    public WishlistController(WishlistService wishlistService) {
        this.wishlistService = wishlistService;
    }

    @PostMapping("/{tmdbId}")
    public ResponseEntity<WishlistActionResponseDto> addMovieToWishlist(
            @PathVariable Long tmdbId,
            @RequestParam(defaultValue = "movie") String mediaType,
            Principal principal) {
        // principal.getName() nos da el email del usuario logueado gracias al JWT
        String normalizedType = wishlistService.addMovie(principal.getName(), tmdbId, mediaType);
        return ResponseEntity.ok(new WishlistActionResponseDto(
                tmdbId,
                normalizedType,
                true,
                "Película agregada a tu lista."
        ));
    }

    @DeleteMapping("/{tmdbId}")
    public ResponseEntity<WishlistActionResponseDto> removeMovieFromWishlist(
            @PathVariable Long tmdbId,
            @RequestParam(defaultValue = "movie") String mediaType,
            Principal principal) {
        String normalizedType = wishlistService.removeMovie(principal.getName(), tmdbId, mediaType);
        return ResponseEntity.ok(new WishlistActionResponseDto(
                tmdbId,
                normalizedType,
                false,
                "Película eliminada de tu lista."
        ));
    }

    @GetMapping
    public ResponseEntity<List<WishlistMovieDto>> getWishlist(Principal principal) {
        List<WishlistMovieDto> wishlist = wishlistService.getUserWishlist(principal.getName());
        return ResponseEntity.ok(wishlist);
    }

    @GetMapping("/media")
    public ResponseEntity<List<HomeMediaItemDto>> getWishlistMedia(Principal principal) {
        return ResponseEntity.ok(wishlistService.getUserWishlistMedia(principal.getName()));
    }
}
