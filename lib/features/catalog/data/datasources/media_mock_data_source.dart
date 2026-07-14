import '../../domain/entities/media_item.dart';
import '../models/media_item_model.dart';
import 'media_data_source.dart';

class MediaMockDataSource implements MediaDataSource {
  const MediaMockDataSource();

  static const _assetBasePath = 'assets/images/movies/mock';

  @override
  Future<List<MediaItemModel>> getHomeMediaItems({
    String mediaType = 'all',
  }) async {
    final items = const [
      MediaItemModel(
        id: 1,
        type: MediaType.movie,
        title: 'The Godfather',
        originalTitle: 'The Godfather',
        overview:
            'El patriarca de una familia criminal transfiere el control de su imperio a su hijo menor.',
        posterUrl: '$_assetBasePath/the-godfather.jpg',
        releaseYear: 1972,
        durationMinutes: 175,
        rating: 9.2,
        genres: ['Crimen', 'Drama'],
        director: 'Francis Ford Coppola',
      ),
      MediaItemModel(
        id: 2,
        type: MediaType.movie,
        title: 'Pulp Fiction',
        originalTitle: 'Pulp Fiction',
        overview:
            'Historias cruzadas de crimen, azar y violencia en Los Angeles.',
        posterUrl: '$_assetBasePath/pulp-fiction.jpg',
        releaseYear: 1994,
        durationMinutes: 154,
        rating: 8.9,
        genres: ['Crimen', 'Drama'],
        director: 'Quentin Tarantino',
      ),
      MediaItemModel(
        id: 3,
        type: MediaType.movie,
        title: 'Perfect Days',
        originalTitle: 'Perfect Days',
        overview:
            'Un limpiador de banos publicos en Tokio encuentra belleza en su rutina diaria.',
        posterUrl: '$_assetBasePath/perfect-days.jpg',
        releaseYear: 2023,
        durationMinutes: 124,
        rating: 7.9,
        genres: ['Drama'],
        director: 'Wim Wenders',
      ),
      MediaItemModel(
        id: 4,
        type: MediaType.movie,
        title: 'The Matrix',
        originalTitle: 'The Matrix',
        overview:
            'Un hacker descubre que la realidad que conoce es una simulacion creada por maquinas.',
        posterUrl: '$_assetBasePath/matrix.jpg',
        releaseYear: 1999,
        durationMinutes: 136,
        rating: 8.7,
        genres: ['Accion', 'Ciencia ficcion'],
        director: 'Lana Wachowski, Lilly Wachowski',
      ),
      MediaItemModel(
        id: 5,
        type: MediaType.movie,
        title: 'Kill Bill: Vol. 1',
        originalTitle: 'Kill Bill: Vol. 1',
        overview:
            'Una exasesina despierta de un coma y busca venganza contra su antiguo escuadron.',
        posterUrl: '$_assetBasePath/kill-bill-vol-1.jpg',
        releaseYear: 2003,
        durationMinutes: 111,
        rating: 8.2,
        genres: ['Accion', 'Suspenso'],
        director: 'Quentin Tarantino',
      ),
      MediaItemModel(
        id: 6,
        type: MediaType.movie,
        title: 'Inglourious Basterds',
        originalTitle: 'Inglourious Basterds',
        overview:
            'Un grupo de soldados aliados planea atacar a lideres nazis durante la Segunda Guerra Mundial.',
        posterUrl: '$_assetBasePath/inglorious-basterds.jpg',
        releaseYear: 2009,
        durationMinutes: 153,
        rating: 8.4,
        genres: ['Belico', 'Drama'],
        director: 'Quentin Tarantino',
      ),
      MediaItemModel(
        id: 7,
        type: MediaType.movie,
        title: 'Goodfellas',
        originalTitle: 'Goodfellas',
        overview:
            'El ascenso y caida de Henry Hill dentro de la mafia neoyorquina.',
        posterUrl: '$_assetBasePath/goodfellas.jpg',
        releaseYear: 1990,
        durationMinutes: 145,
        rating: 8.7,
        genres: ['Crimen', 'Biografia'],
        director: 'Martin Scorsese',
      ),
      MediaItemModel(
        id: 8,
        type: MediaType.movie,
        title: 'Fight Club',
        originalTitle: 'Fight Club',
        overview:
            'Un oficinista insomne y un vendedor de jabon fundan un club clandestino de pelea.',
        posterUrl: '$_assetBasePath/fight-club.jpg',
        releaseYear: 1999,
        durationMinutes: 139,
        rating: 8.8,
        genres: ['Drama', 'Suspenso'],
        director: 'David Fincher',
      ),
      MediaItemModel(
        id: 9,
        type: MediaType.movie,
        title: 'Drive',
        originalTitle: 'Drive',
        overview:
            'Un conductor especialista se involucra en un atraco que amenaza a sus vecinos.',
        posterUrl: '$_assetBasePath/drive.jpg',
        releaseYear: 2011,
        durationMinutes: 100,
        rating: 7.8,
        genres: ['Crimen', 'Drama'],
        director: 'Nicolas Winding Refn',
      ),
      MediaItemModel(
        id: 10,
        type: MediaType.movie,
        title: 'Drive My Car',
        originalTitle: 'Doraibu mai ka',
        overview:
            'Un actor y director de teatro procesa una perdida mientras prepara una obra en Hiroshima.',
        posterUrl: '$_assetBasePath/drive-my-car.jpg',
        releaseYear: 2021,
        durationMinutes: 179,
        rating: 7.6,
        genres: ['Drama'],
        director: 'Ryusuke Hamaguchi',
      ),
      MediaItemModel(
        id: 11,
        type: MediaType.movie,
        title: 'Chungking Express',
        originalTitle: 'Chung Hing sam lam',
        overview:
            'Dos policias de Hong Kong atraviesan encuentros romanticos marcados por el azar.',
        posterUrl: '$_assetBasePath/chungking-express.jpg',
        releaseYear: 1994,
        durationMinutes: 102,
        rating: 8.0,
        genres: ['Drama', 'Romance'],
        director: 'Wong Kar-wai',
      ),
      MediaItemModel(
        id: 12,
        type: MediaType.movie,
        title: 'Blade Runner 2049',
        originalTitle: 'Blade Runner 2049',
        overview:
            'Un blade runner descubre un secreto capaz de desestabilizar lo que queda de la sociedad.',
        posterUrl: '$_assetBasePath/blade-runner-2049.jpg',
        releaseYear: 2017,
        durationMinutes: 164,
        rating: 8.0,
        genres: ['Ciencia ficcion', 'Drama'],
        director: 'Denis Villeneuve',
      ),
      MediaItemModel(
        id: 13,
        type: MediaType.series,
        title: 'Breaking Bad',
        originalTitle: 'Breaking Bad',
        overview:
            'Un profesor de quimica con cancer terminal empieza a fabricar metanfetamina para asegurar el futuro de su familia.',
        posterUrl: '$_assetBasePath/breaking-bad.jpg',
        releaseYear: 2008,
        seasonsCount: 5,
        episodesCount: 62,
        rating: 9.5,
        genres: ['Crimen', 'Drama'],
        creator: 'Vince Gilligan',
      ),
      MediaItemModel(
        id: 14,
        type: MediaType.series,
        title: 'The Walking Dead',
        originalTitle: 'The Walking Dead',
        overview:
            'Un grupo de sobrevivientes intenta mantenerse con vida en un mundo devastado por caminantes.',
        posterUrl: '$_assetBasePath/the-walking-dead.jpg',
        releaseYear: 2010,
        seasonsCount: 11,
        episodesCount: 177,
        rating: 8.1,
        genres: ['Drama', 'Terror'],
        creator: 'Frank Darabont',
      ),
    ];

    return switch (mediaType) {
      'movie' || 'movies' =>
        items
            .where((item) => item.type == MediaType.movie)
            .toList(growable: false),
      'series' || 'tv' =>
        items
            .where((item) => item.type == MediaType.series)
            .toList(growable: false),
      _ => items,
    };
  }

  @override
  Future<List<MediaItemModel>> searchMediaItems(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final all = await getHomeMediaItems();
    final lowerQuery = query.toLowerCase();
    return all
        .where((item) => item.title.toLowerCase().contains(lowerQuery))
        .toList(growable: false);
  }

  @override
  Future<List<MediaItemModel>> getSuggestions() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return const [
      MediaItemModel(
        id: 1,
        type: MediaType.movie,
        title: 'The Godfather',
        originalTitle: 'The Godfather',
        overview:
            'El patriarca de una familia criminal transfiere el control de su imperio a su hijo menor.',
        posterUrl: '$_assetBasePath/the-godfather.jpg',
        releaseYear: 1972,
        durationMinutes: 175,
        rating: 9.2,
        genres: ['Crimen', 'Drama'],
        director: 'Francis Ford Coppola',
      ),
      MediaItemModel(
        id: 2,
        type: MediaType.movie,
        title: 'Pulp Fiction',
        originalTitle: 'Pulp Fiction',
        overview:
            'Historias cruzadas de crimen, azar y violencia en Los Angeles.',
        posterUrl: '$_assetBasePath/pulp-fiction.jpg',
        releaseYear: 1994,
        durationMinutes: 154,
        rating: 8.9,
        genres: ['Crimen', 'Drama'],
        director: 'Quentin Tarantino',
      ),
      MediaItemModel(
        id: 4,
        type: MediaType.movie,
        title: 'The Matrix',
        originalTitle: 'The Matrix',
        overview:
            'Un hacker descubre que la realidad que conoce es una simulacion creada por maquinas.',
        posterUrl: '$_assetBasePath/matrix.jpg',
        releaseYear: 1999,
        durationMinutes: 136,
        rating: 8.7,
        genres: ['Accion', 'Ciencia ficcion'],
        director: 'Lana Wachowski, Lilly Wachowski',
      ),
      MediaItemModel(
        id: 8,
        type: MediaType.movie,
        title: 'Fight Club',
        originalTitle: 'Fight Club',
        overview:
            'Un oficinista insomne y un vendedor de jabon fundan un club clandestino de pelea.',
        posterUrl: '$_assetBasePath/fight-club.jpg',
        releaseYear: 1999,
        durationMinutes: 139,
        rating: 8.8,
        genres: ['Drama', 'Suspenso'],
        director: 'David Fincher',
      ),
      MediaItemModel(
        id: 13,
        type: MediaType.series,
        title: 'Breaking Bad',
        originalTitle: 'Breaking Bad',
        overview:
            'Un profesor de quimica con cancer terminal empieza a fabricar metanfetamina para asegurar el futuro de su familia.',
        posterUrl: '$_assetBasePath/breaking-bad.jpg',
        releaseYear: 2008,
        seasonsCount: 5,
        episodesCount: 62,
        rating: 9.5,
        genres: ['Crimen', 'Drama'],
        creator: 'Vince Gilligan',
      ),
      MediaItemModel(
        id: 7,
        type: MediaType.movie,
        title: 'Goodfellas',
        originalTitle: 'Goodfellas',
        overview:
            'El ascenso y caida de Henry Hill dentro de la mafia neoyorquina.',
        posterUrl: '$_assetBasePath/goodfellas.jpg',
        releaseYear: 1990,
        durationMinutes: 145,
        rating: 8.7,
        genres: ['Crimen', 'Biografia'],
        director: 'Martin Scorsese',
      ),
    ];
  }
}
