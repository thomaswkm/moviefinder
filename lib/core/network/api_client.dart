import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required this.config, required this.tokenStorage, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final ApiConfig config;
  final TokenStorage tokenStorage;
  final http.Client _httpClient;

  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    final uri = _uri(path, queryParameters);
    final response = await _httpClient.get(uri, headers: await _headers());
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _httpClient.post(
      _uri(path, queryParameters),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {Map<String, String>? queryParameters}) async {
    final response = await _httpClient.delete(
      _uri(path, queryParameters),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${config.baseUrl}$normalizedPath').replace(
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, String>> _headers() async {
    final token = await tokenStorage.readToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      final body = utf8.decode(response.bodyBytes);
      try {
        return jsonDecode(body);
      } on FormatException {
        return body;
      }
    }

    throw ApiException(
      response.body.isEmpty ? 'Request failed' : response.body,
      statusCode: response.statusCode,
    );
  }
}
