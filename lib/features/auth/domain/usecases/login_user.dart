import '../../../../core/result/result.dart';
import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthenticatedUser>> call({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final validationErrors = <String, String>{};

    if (normalizedEmail.isEmpty) {
      validationErrors['email'] = 'Ingresa tu email.';
    } else if (!_isValidEmail(normalizedEmail)) {
      validationErrors['email'] = 'Ingresa un email valido.';
    }

    if (password.isEmpty) {
      validationErrors['password'] = 'Ingresa tu password.';
    } else if (password.length < 6) {
      validationErrors['password'] =
          'El password debe tener al menos 6 caracteres.';
    }

    if (validationErrors.isNotEmpty) {
      return Failure(
        'Revisa los campos del formulario.',
        fieldErrors: validationErrors,
      );
    }

    return _repository.login(email: normalizedEmail, password: password);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
