import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

class AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserRepository _userRepository = UserRepository();

  // Création automatique du document User dans Firestore
  // après l'inscription via Firebase Auth
  Future<void> createUserAfterRegister({
    required String userId,
    required String name,
    required String email,
    required String filiere,
    required String annee,
  }) async {
    // On vérifie d'abord si le user existe déjà
    final existingUser = await _userRepository.getUserById(userId);

    if (existingUser != null) return; // déjà créé, on ne fait rien

    // On crée le modèle User
    final newUser = UserModel(
      id: userId,
      name: name,
      email: email,
      filiere: filiere,
      annee: annee,
      createdAt: DateTime.now(),
    );

    // On sauvegarde dans Firestore
    await _userRepository.createUser(newUser);
  }

  // Récupérer le User connecté depuis Firestore
  Future<UserModel?> getCurrentUser(String userId) async {
    return await _userRepository.getUserById(userId);
  }

  // Supprimer le document User lors de la suppression du compte
  Future<void> deleteUserData(String userId) async {
    await _userRepository.deleteUser(userId);
  }
}