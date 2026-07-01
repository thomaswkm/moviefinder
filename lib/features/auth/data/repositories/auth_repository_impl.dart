import '../../../../core/result/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource, this._tokenStorage);

  final AuthDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<AuthenticatedUser?>> getCurrentUser() async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      return const Success(null);
    }

    try {
      final response = await _dataSource.getCurrentUser(token);
      return Success(response.toEntity());
    } on Exception {
      await _tokenStorage.clearToken();
      return const Failure('La sesion expiro. Inicia sesion nuevamente.');
    }
  }

  @override
  Future<Result<AuthenticatedUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.login(
        LoginRequestModel(email: email, password: password),
      );
      await _tokenStorage.saveToken(response.token);
      return Success(response.toEntity());
    } on Exception {
      return const Failure('No se pudo iniciar sesion. Intentalo nuevamente.');
    }
  }

  @override
  Future<Result<AuthenticatedUser>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.register(
        RegisterRequestModel(
          username: _usernameFromEmail(email),
          email: email,
          password: password,
        ),
      );
      await _tokenStorage.saveToken(response.token);
      return Success(response.toEntity());
    } on Exception {
      return const Failure('No se pudo crear la cuenta. Intentalo nuevamente.');
    }
  }

  @override
  Future<void> logout() {
    return _tokenStorage.clearToken();
  }

  String _usernameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    return localPart.isEmpty ? 'user' : localPart;
  }
}
