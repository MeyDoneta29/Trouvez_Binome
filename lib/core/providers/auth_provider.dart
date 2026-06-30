import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get loading => _loading;

  AuthProvider() {
    _repo.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        _user = await _repo.getCurrentUserData();
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> register({
    required String nom,
    required String email,
    required String password,
    required String filiere,
    required String annee,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.register(
        nom: nom,
        email: email,
        password: password,
        filiere: filiere,
        annee: annee,
      );
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _repo.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateLocalUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  String _parseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'Cet email est deja utilise.';
    } else if (error.contains('wrong-password') ||
        error.contains('invalid-credential')) {
      return 'Email ou mot de passe incorrect.';
    } else if (error.contains('user-not-found')) {
      return 'Aucun compte avec cet email.';
    } else if (error.contains('weak-password')) {
      return 'Mot de passe trop faible (min 6 caracteres).';
    }
    return 'Une erreur est survenue. Reessayez.';
  }
}
