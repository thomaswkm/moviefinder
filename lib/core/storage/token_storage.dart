import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';

  String? _token;

  Future<void> saveToken(String token) async {
    _token = token;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  Future<String?> readToken() async {
    if (_token != null) {
      return _token;
    }

    final preferences = await SharedPreferences.getInstance();
    _token = preferences.getString(_tokenKey);
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }
}
