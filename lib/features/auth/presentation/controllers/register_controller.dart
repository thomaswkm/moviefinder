import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/usecases/register_user.dart';

class RegisterController extends ChangeNotifier {
  RegisterController(this._registerUser);

  final RegisterUser _registerUser;

  bool _isLoading = false;
  String? _message;
  Map<String, String> _fieldErrors = const {};
  AuthenticatedUser? _registeredUser;

  bool get isLoading => _isLoading;
  String? get message => _message;
  Map<String, String> get fieldErrors => _fieldErrors;
  AuthenticatedUser? get registeredUser => _registeredUser;

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _message = null;
    _fieldErrors = const {};
    _registeredUser = null;
    notifyListeners();

    final result = await _registerUser(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    switch (result) {
      case Success<AuthenticatedUser>(value: final user):
        _registeredUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      case Failure<AuthenticatedUser>(
        message: final message,
        fieldErrors: final fieldErrors,
      ):
        _message = message;
        _fieldErrors = fieldErrors;
        _isLoading = false;
        notifyListeners();
        return false;
    }
  }
}
