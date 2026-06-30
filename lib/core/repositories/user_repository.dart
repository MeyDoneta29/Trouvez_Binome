import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<UserModel>> searchUsers({
    String? filiere,
    String? annee,
    List<String>? competences,
    String? query,
    String? excludeUid,
  }) async {
    Query<Map<String, dynamic>> ref = _db.collection('users');

    if (filiere != null && filiere.isNotEmpty) {
      ref = ref.where('filiere', isEqualTo: filiere);
    }
    if (annee != null && annee.isNotEmpty) {
      ref = ref.where('annee', isEqualTo: annee);
    }

    final snapshot = await ref.limit(50).get();

    List<UserModel> users = snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => u.uid != excludeUid)
        .toList();

    if (competences != null && competences.isNotEmpty) {
      users = users.where((u) {
        return competences.any((c) => u.competences.contains(c));
      }).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      users = users.where((u) {
        return u.nom.toLowerCase().contains(q) ||
            u.filiere.toLowerCase().contains(q);
      }).toList();
    }

    return users;
  }

  Future<List<UserModel>> getAllUsers({String? excludeUid}) async {
    final snapshot = await _db.collection('users').limit(50).get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .where((u) => u.uid != excludeUid)
        .toList();
  }

  Future<void> updateCompetences(String uid, List<String> competences) async {
    double completion = _calculateCompletion(competences: competences);
    await _db.collection('users').doc(uid).update({
      'competences': competences,
      'profileCompletion': completion,
    });
  }

  Future<void> updateDisponibilites(
      String uid, List<String> disponibilites) async {
    await _db.collection('users').doc(uid).update({
      'disponibilites': disponibilites,
    });
  }

  double _calculateCompletion({List<String>? competences}) {
    double score = 0.3;
    if (competences != null && competences.isNotEmpty) score += 0.3;
    return score.clamp(0.0, 1.0);
  }
}
