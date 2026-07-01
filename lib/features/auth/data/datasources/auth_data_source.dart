import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

abstract interface class AuthDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);

  Future<AuthResponseModel> register(RegisterRequestModel request);

  Future<AuthResponseModel> getCurrentUser(String token);
}
