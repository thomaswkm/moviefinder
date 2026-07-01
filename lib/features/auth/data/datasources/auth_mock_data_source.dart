import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  const AuthMockDataSource();

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return AuthResponseModel(
      userId: 1,
      email: request.email,
      username: _usernameFromEmail(request.email),
      token: 'mock-jwt-token',
    );
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return AuthResponseModel(
      userId: 1,
      email: request.email,
      username: request.username,
      token: 'mock-jwt-token',
    );
  }

  @override
  Future<AuthResponseModel> getCurrentUser(String token) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return AuthResponseModel(
      userId: 1,
      email: 'mock.user@moviefinder.local',
      username: 'mock.user',
      token: token,
    );
  }

  String _usernameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'user' : localPart;
  }
}
