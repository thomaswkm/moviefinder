import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';
import 'auth_data_source.dart';

class AuthMockDataSource implements AuthDataSource {
  const AuthMockDataSource();

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
}
