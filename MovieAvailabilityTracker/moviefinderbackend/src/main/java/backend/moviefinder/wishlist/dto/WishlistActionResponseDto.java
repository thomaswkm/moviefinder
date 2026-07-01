package backend.moviefinder.wishlist.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class WishlistActionResponseDto {
    private Long tmdbId;
    private String mediaType;
    private boolean inWishlist;
    private String message;
}
