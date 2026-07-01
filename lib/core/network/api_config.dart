class ApiConfig {
  const ApiConfig({required this.baseUrl});

  final String baseUrl;

  static const development = ApiConfig(baseUrl: 'http://localhost:8080');
}
