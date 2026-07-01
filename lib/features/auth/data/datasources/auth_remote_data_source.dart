import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import 'auth_data_source.dart';

class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post('/api/auth/login', body: request.toJson());
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    final response = await _apiClient.post('/api/auth/register', body: request.toJson());
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> getCurrentUser(String token) async {
    final response = await _apiClient.get('/api/auth/me');
    final json = response as Map<String, dynamic>;

    return AuthResponseModel(
      userId: (json['id'] as num).toInt(),
      email: json['email'] as String,
      username: json['username'] as String,
      token: token,
    );
  }
}
