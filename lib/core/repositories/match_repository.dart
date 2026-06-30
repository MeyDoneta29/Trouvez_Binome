import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class MatchRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createMatch(MatchModel match) async {
    final doc = await _db.collection('matches').add(match.toMap());
    return doc.id;
  }

  Future<void> updateMatchStatus(String matchId, MatchStatus status) async {
    await _db.collection('matches').doc(matchId).update({
      'status': status.name,
    });
  }

  Future<List<MatchModel>> getMatchesForUser(String uid) async {
    final snap1 = await _db
        .collection('matches')
        .where('userId1', isEqualTo: uid)
        .get();
    final snap2 = await _db
        .collection('matches')
        .where('userId2', isEqualTo: uid)
        .get();

    final all = [...snap1.docs, ...snap2.docs];
    return all.map((doc) => MatchModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<List<MatchModel>> getAcceptedMatches(String uid) async {
    final matches = await getMatchesForUser(uid);
    return matches
        .where((m) => m.status == MatchStatus.accepted)
        .toList();
  }

  Future<bool> matchExists(String uid1, String uid2) async {
    final snap = await _db
        .collection('matches')
        .where('userId1', isEqualTo: uid1)
        .where('userId2', isEqualTo: uid2)
        .get();
    return snap.docs.isNotEmpty;
  }
}
