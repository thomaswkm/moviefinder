import '../models/auth_response_model.dart';
import '../models/register_request_model.dart';

abstract interface class AuthDataSource {
  Future<AuthResponseModel> register(RegisterRequestModel request);
}
