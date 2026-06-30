import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repo = UserRepository();

  UserModel? _currentUser;
  bool _loading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get loading => _loading;
  String? get error => _error;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel user) async {
    _loading = true;
    notifyListeners();
    try {
      await _repo.updateUser(user);
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateCompetences(String uid, List<String> competences) async {
    _loading = true;
    notifyListeners();
    try {
      await _repo.updateCompetences(uid, competences);
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(competences: competences);
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateDisponibilites(
      String uid, List<String> disponibilites) async {
    _loading = true;
    notifyListeners();
    try {
      await _repo.updateDisponibilites(uid, disponibilites);
      if (_currentUser != null) {
        _currentUser =
            _currentUser!.copyWith(disponibilites: disponibilites);
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}
