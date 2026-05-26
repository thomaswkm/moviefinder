import '../../../../core/result/result.dart';
import '../entities/authenticated_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthenticatedUser?>> getCurrentUser();

  Future<Result<AuthenticatedUser>> login({
    required String email,
    required String password,
  });

  Future<Result<AuthenticatedUser>> register({
    required String email,
    required String password,
  });

  Future<void> logout();
}
