import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/datasources/wishlist_data_source.dart';
import '../../domain/entities/media_item.dart';

class WishlistController extends ChangeNotifier {
  WishlistController(this._dataSource);

  final WishlistDataSource _dataSource;

  bool _isLoading = false;
  String? _message;
  List<MediaItem> _items = const [];
  Set<int> _ids = const {};
  final Set<int> _pendingIds = <int>{};
  int _idsRequestVersion = 0;

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<MediaItem> get items => _items;
  bool contains(int tmdbId) => _ids.contains(tmdbId);
  bool isPending(int tmdbId) => _pendingIds.contains(tmdbId);

  Future<void> load() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      final models = await _dataSource.getWishlistMedia();
      _items = models.map((item) => item.toEntity()).toList(growable: false);
      _ids = _items.map((item) => item.id).toSet();
    } on Exception {
      _message = 'No se pudo cargar tu watchlist.';
      _items = const [];
      _ids = const {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadIds() async {
    final requestVersion = ++_idsRequestVersion;

    try {
      final ids = await _dataSource.getWishlistIds();
      if (requestVersion == _idsRequestVersion) {
        _ids = ids;
        notifyListeners();
      }
    } on Exception {
      if (requestVersion == _idsRequestVersion) {
        notifyListeners();
      }
    }
  }

  Future<void> toggle(MediaItem item) async {
    if (_pendingIds.contains(item.id)) {
      return;
    }

    final wasInWishlist = _ids.contains(item.id);
    _idsRequestVersion++;
    _pendingIds.add(item.id);
    _message = null;
    notifyListeners();

    try {
      final mediaType = item.type == MediaType.series ? 'series' : 'movie';
      if (wasInWishlist) {
        await _dataSource.removeMovie(item.id, mediaType);
        _ids = ({..._ids}..remove(item.id));
        _items = _items.where((media) => media.id != item.id).toList(growable: false);
      } else {
        await _dataSource.addMovie(item.id, mediaType);
        _ids = {..._ids, item.id};
      }
    } on ApiException catch (exception) {
      if (!wasInWishlist && exception.statusCode == 409) {
        _ids = {..._ids, item.id};
      } else if (wasInWishlist && exception.statusCode == 404) {
        _ids = ({..._ids}..remove(item.id));
        _items = _items.where((media) => media.id != item.id).toList(growable: false);
      } else {
        _revert(item, wasInWishlist);
      }
    } on Exception {
      _revert(item, wasInWishlist);
    }

    _pendingIds.remove(item.id);
    notifyListeners();
  }

  void _revert(MediaItem item, bool wasInWishlist) {
    _message = 'No se pudo actualizar tu watchlist.';
  }
}
