import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> register({
    required String nom,
    required String email,
    required String password,
    required String filiere,
    required String annee,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      nom: nom,
      email: email,
      filiere: filiere,
      annee: annee,
      competences: [],
      disponibilites: [],
      profileCompletion: 0.3,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    return user;
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _db
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
