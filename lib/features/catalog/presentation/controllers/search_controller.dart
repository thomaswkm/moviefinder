import 'package:flutter/foundation.dart';

import '../../data/datasources/media_data_source.dart';
import '../../domain/entities/media_item.dart';

class MediaSearchController extends ChangeNotifier {
  MediaSearchController(this._dataSource);

  final MediaDataSource _dataSource;

  bool _isLoading = false;
  String? _message;
  List<MediaItem> _items = const [];
  List<MediaItem> _suggestions = const [];
  String _lastQuery = '';

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<MediaItem> get items => _items;
  List<MediaItem> get suggestions => _suggestions;
  bool get hasSuggestions => _suggestions.isNotEmpty;
  bool get hasSearched => _lastQuery.isNotEmpty;

  Future<void> loadSuggestions() async {
    try {
      final models = await _dataSource.getSuggestions();
      _suggestions =
          models.map((item) => item.toEntity()).toList(growable: false);
      notifyListeners();
    } on Exception {
      // Silently fail, suggestions are optional
    }
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    _lastQuery = trimmedQuery;

    if (trimmedQuery.isEmpty) {
      _items = const [];
      _message = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final models = await _dataSource.searchMediaItems(trimmedQuery);
      _items = models.map((item) => item.toEntity()).toList(growable: false);
    } on Exception {
      _message = 'No se pudo realizar la busqueda.';
      _items = const [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
