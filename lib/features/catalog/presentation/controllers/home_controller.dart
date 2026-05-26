import 'package:flutter/foundation.dart';

import '../../domain/entities/media_item.dart';
import '../../domain/usecases/get_home_media_items.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._getHomeMediaItems);

  final GetHomeMediaItems _getHomeMediaItems;

  bool _isLoading = false;
  String? _message;
  List<MediaItem> _items = const [];

  bool get isLoading => _isLoading;
  String? get message => _message;
  List<MediaItem> get items => _items;

  Future<void> loadItems() async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      _items = await _getHomeMediaItems();
    } on Exception {
      _message = 'No se pudo cargar el catalogo.';
      _items = const [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
