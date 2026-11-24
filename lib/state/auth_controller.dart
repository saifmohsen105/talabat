import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._service);

  final AuthService _service;
  bool isLoading = false;
  String? errorMessage;

  bool get isSignedIn => _service.currentUser != null;
  String? get userEmail => _service.currentUser?.email;

  Future<void> signIn(String email, String password) async {
    await _run(() => _service.signIn(email, password));
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    var immediateSession = false;
    await _run(() async {
      immediateSession = await _service.signUp(
        name: name,
        email: email,
        password: password,
      );
    });
    return immediateSession;
  }

  Future<void> signOut() async {
    await _run(_service.signOut);
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      errorMessage = _friendlyError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('Invalid login credentials')) {
      return 'Email or password is incorrect.';
    }
    if (message.contains('User already registered')) {
      return 'An account already exists for this email.';
    }
    return message.replaceFirst('AuthException: ', '');
  }
}
