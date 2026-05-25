import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'profiles';

  // Créer ou mettre à jour un profil
  Future<void> saveProfile(ProfileModel profile) async {
    await _firestore
        .collection(_collection)
        .doc(profile.userId)
        .set(profile.toMap());
  }

  // Récupérer un profil par userId
  Future<ProfileModel?> getProfile(String userId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return ProfileModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Mettre à jour les disponibilités
  Future<void> updateAvailability(
    String userId,
    Map<String, List<String>> availability,
  ) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({'availability': availability});
  }

  // Écouter le profil en temps réel
  Stream<ProfileModel?> watchProfile(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ProfileModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}