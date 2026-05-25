import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Créer un utilisateur dans Firestore
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(_collection)
        .doc(user.id)
        .set(user.toMap());
  }

  // Récupérer un utilisateur par son ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update(data);
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .delete();
  }

  // Écouter les changements d'un utilisateur en temps réel
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}