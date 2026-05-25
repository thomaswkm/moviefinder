import '../../../../core/result/result.dart';
import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthenticatedUser>> call({
    required String email,
    required String password,
    required String confirmPassword,
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
    }

    if (confirmPassword.isEmpty) {
      validationErrors['confirmPassword'] = 'Confirma tu password.';
    } else if (password != confirmPassword) {
      validationErrors['confirmPassword'] = 'Las contrasenas no coinciden.';
    }

    if (validationErrors.isNotEmpty) {
      return Failure(
        'Revisa los campos del formulario.',
        fieldErrors: validationErrors,
      );
    }

    return _repository.register(email: normalizedEmail, password: password);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
