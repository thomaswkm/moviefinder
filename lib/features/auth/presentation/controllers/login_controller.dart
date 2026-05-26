import 'package:flutter/foundation.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/usecases/login_user.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._loginUser);

  final LoginUser _loginUser;

  bool _isLoading = false;
  String? _message;
  Map<String, String> _fieldErrors = const {};
  AuthenticatedUser? _authenticatedUser;

  bool get isLoading => _isLoading;
  String? get message => _message;
  Map<String, String> get fieldErrors => _fieldErrors;
  AuthenticatedUser? get authenticatedUser => _authenticatedUser;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _message = null;
    _fieldErrors = const {};
    _authenticatedUser = null;
    notifyListeners();

    final result = await _loginUser(email: email, password: password);

    switch (result) {
      case Success<AuthenticatedUser>(value: final user):
        _authenticatedUser = user;
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
