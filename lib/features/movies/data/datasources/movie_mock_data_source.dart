import '../models/movie_model.dart';
import 'movie_data_source.dart';

class MovieMockDataSource implements MovieDataSource {
  const MovieMockDataSource();

  static const _assetBasePath = 'assets/images/movies/mock';

  @override
  Future<List<MovieModel>> getHomeMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const [
      MovieModel(
        id: 1,
        title: 'The Godfather',
        originalTitle: 'The Godfather',
        overview:
            'El patriarca de una familia criminal transfiere el control de su imperio a su hijo menor.',
        posterAssetPath: '$_assetBasePath/the-godfather.jpg',
        releaseYear: 1972,
        durationMinutes: 175,
        rating: 9.2,
        genres: ['Crimen', 'Drama'],
        director: 'Francis Ford Coppola',
      ),
      MovieModel(
        id: 2,
        title: 'Pulp Fiction',
        originalTitle: 'Pulp Fiction',
        overview:
            'Historias cruzadas de crimen, azar y violencia en Los Angeles.',
        posterAssetPath: '$_assetBasePath/pulp-fiction.jpg',
        releaseYear: 1994,
        durationMinutes: 154,
        rating: 8.9,
        genres: ['Crimen', 'Drama'],
        director: 'Quentin Tarantino',
      ),
      MovieModel(
        id: 3,
        title: 'Perfect Days',
        originalTitle: 'Perfect Days',
        overview:
            'Un limpiador de banos publicos en Tokio encuentra belleza en su rutina diaria.',
        posterAssetPath: '$_assetBasePath/perfect-days.jpg',
        releaseYear: 2023,
        durationMinutes: 124,
        rating: 7.9,
        genres: ['Drama'],
        director: 'Wim Wenders',
      ),
      MovieModel(
        id: 4,
        title: 'The Matrix',
        originalTitle: 'The Matrix',
        overview:
            'Un hacker descubre que la realidad que conoce es una simulacion creada por maquinas.',
        posterAssetPath: '$_assetBasePath/matrix.jpg',
        releaseYear: 1999,
        durationMinutes: 136,
        rating: 8.7,
        genres: ['Accion', 'Ciencia ficcion'],
        director: 'Lana Wachowski, Lilly Wachowski',
      ),
      MovieModel(
        id: 5,
        title: 'Kill Bill: Vol. 1',
        originalTitle: 'Kill Bill: Vol. 1',
        overview:
            'Una exasesina despierta de un coma y busca venganza contra su antiguo escuadron.',
        posterAssetPath: '$_assetBasePath/kill-bill-vol-1.jpg',
        releaseYear: 2003,
        durationMinutes: 111,
        rating: 8.2,
        genres: ['Accion', 'Suspenso'],
        director: 'Quentin Tarantino',
      ),
      MovieModel(
        id: 6,
        title: 'Inglourious Basterds',
        originalTitle: 'Inglourious Basterds',
        overview:
            'Un grupo de soldados aliados planea atacar a lideres nazis durante la Segunda Guerra Mundial.',
        posterAssetPath: '$_assetBasePath/inglorious-basterds.jpg',
        releaseYear: 2009,
        durationMinutes: 153,
        rating: 8.4,
        genres: ['Belico', 'Drama'],
        director: 'Quentin Tarantino',
      ),
      MovieModel(
        id: 7,
        title: 'Goodfellas',
        originalTitle: 'Goodfellas',
        overview:
            'El ascenso y caida de Henry Hill dentro de la mafia neoyorquina.',
        posterAssetPath: '$_assetBasePath/goodfellas.jpg',
        releaseYear: 1990,
        durationMinutes: 145,
        rating: 8.7,
        genres: ['Crimen', 'Biografia'],
        director: 'Martin Scorsese',
      ),
      MovieModel(
        id: 8,
        title: 'Fight Club',
        originalTitle: 'Fight Club',
        overview:
            'Un oficinista insomne y un vendedor de jabon fundan un club clandestino de pelea.',
        posterAssetPath: '$_assetBasePath/fight-club.jpg',
        releaseYear: 1999,
        durationMinutes: 139,
        rating: 8.8,
        genres: ['Drama', 'Suspenso'],
        director: 'David Fincher',
      ),
      MovieModel(
        id: 9,
        title: 'Drive',
        originalTitle: 'Drive',
        overview:
            'Un conductor especialista se involucra en un atraco que amenaza a sus vecinos.',
        posterAssetPath: '$_assetBasePath/drive.jpg',
        releaseYear: 2011,
        durationMinutes: 100,
        rating: 7.8,
        genres: ['Crimen', 'Drama'],
        director: 'Nicolas Winding Refn',
      ),
      MovieModel(
        id: 10,
        title: 'Drive My Car',
        originalTitle: 'Doraibu mai ka',
        overview:
            'Un actor y director de teatro procesa una perdida mientras prepara una obra en Hiroshima.',
        posterAssetPath: '$_assetBasePath/drive-my-car.jpg',
        releaseYear: 2021,
        durationMinutes: 179,
        rating: 7.6,
        genres: ['Drama'],
        director: 'Ryusuke Hamaguchi',
      ),
      MovieModel(
        id: 11,
        title: 'Chungking Express',
        originalTitle: 'Chung Hing sam lam',
        overview:
            'Dos policias de Hong Kong atraviesan encuentros romanticos marcados por el azar.',
        posterAssetPath: '$_assetBasePath/chungking-express.jpg',
        releaseYear: 1994,
        durationMinutes: 102,
        rating: 8.0,
        genres: ['Drama', 'Romance'],
        director: 'Wong Kar-wai',
      ),
      MovieModel(
        id: 12,
        title: 'Blade Runner 2049',
        originalTitle: 'Blade Runner 2049',
        overview:
            'Un blade runner descubre un secreto capaz de desestabilizar lo que queda de la sociedad.',
        posterAssetPath: '$_assetBasePath/blade-runner-2049.jpg',
        releaseYear: 2017,
        durationMinutes: 164,
        rating: 8.0,
        genres: ['Ciencia ficcion', 'Drama'],
        director: 'Denis Villeneuve',
      ),
    ];
  }
}
