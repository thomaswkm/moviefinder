import '../../../../core/result/result.dart';
import '../entities/authenticated_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthenticatedUser>> register({
    required String email,
    required String password,
  });
}
