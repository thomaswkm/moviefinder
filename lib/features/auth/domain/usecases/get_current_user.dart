import '../../../../core/result/result.dart';
import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthenticatedUser?>> call() {
    return _repository.getCurrentUser();
  }
}
