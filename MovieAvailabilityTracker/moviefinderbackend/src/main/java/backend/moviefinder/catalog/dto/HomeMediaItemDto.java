package backend.moviefinder.catalog.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class HomeMediaItemDto {
    private Long id;
    private String type;
    private String title;
    private String originalTitle;
    private String overview;
    private String posterUrl;
    private Integer releaseYear;
    private Double rating;
    private List<String> genres;
    private Integer durationMinutes;
    private Integer seasonsCount;
    private Integer episodesCount;
    private String director;
    private String creator;
}
