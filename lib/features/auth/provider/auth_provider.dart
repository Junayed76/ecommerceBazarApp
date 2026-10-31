import 'package:flutter/foundation.dart';

import '../../../core/network/api_exceptions.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

/// Exposes the authentication session to the widget tree.
class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.repository, bool autoRestore = true}) {
    if (autoRestore) restoreSession();
  }

  final AuthRepository repository;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isSigningIn => _status == AuthStatus.signingIn;

  /// Restores a previous session, showing the cached user while the token is
  /// verified against the API.
  Future<void> restoreSession() async {
    final cached = repository.cachedUser;
    if (cached != null) {
      _user = cached;
      _status = AuthStatus.authenticated;
      notifyListeners();
    }

    try {
      final user = await repository.restoreSession();
      _user = user;
      _status = user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } catch (_) {
      _status = _user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _status = AuthStatus.signingIn;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await repository.signIn(
        username: username,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on UnauthorizedException {
      _errorMessage = 'Wrong username or password. Please try again.';
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Sign in failed. Please try again.';
    }

    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await repository.signOut();
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
