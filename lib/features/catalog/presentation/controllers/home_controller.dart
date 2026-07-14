import 'package:flutter/foundation.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/usecases/get_home_media_items.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._getHomeMediaItems);

  final GetHomeMediaItems _getHomeMediaItems;

  bool _isLoading = false;
  String? _message;
  List<MediaItem> _items = const [];
  final Map<String, List<MediaItem>> _cachedItemsByType = {};
  int _requestVersion = 0;

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<MediaItem> get items => _items;

  Future<void> loadItems({String mediaType = 'all'}) async {
    final normalizedType = _normalizeMediaType(mediaType);
    final cachedItems = _cachedItemsByType[normalizedType];
    if (cachedItems != null) {
      _items = cachedItems;
      _message = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final requestVersion = ++_requestVersion;
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final loadedItems = await _getHomeMediaItems(mediaType: normalizedType);
      if (requestVersion != _requestVersion) {
        return;
      }

      _items = loadedItems;
      _cacheItems(normalizedType, loadedItems);
    } on Exception {
      if (requestVersion != _requestVersion) {
        return;
      }

      _message = 'No se pudo cargar el catalogo.';
      if (_items.isEmpty) {
        _items = const [];
      }
    }

    if (requestVersion != _requestVersion) {
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _cacheItems(String mediaType, List<MediaItem> items) {
    _cachedItemsByType[mediaType] = items;

    if (mediaType == 'all') {
      _cachedItemsByType['movie'] = items
          .where((item) => item.type == MediaType.movie)
          .toList(growable: false);
      _cachedItemsByType['series'] = items
          .where((item) => item.type == MediaType.series)
          .toList(growable: false);
    }
  }

  String _normalizeMediaType(String mediaType) {
    return switch (mediaType) {
      'movies' => 'movie',
      'tv' => 'series',
      'series' || 'movie' => mediaType,
      _ => 'all',
    };
  }
}
