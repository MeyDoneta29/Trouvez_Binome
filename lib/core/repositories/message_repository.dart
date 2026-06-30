import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String matchId) {
    return _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String matchId, MessageModel message) async {
    await _db
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .add(message.toMap());

    await _db.collection('matches').doc(matchId).update({
      'lastMessage': message.content,
      'lastMessageAt': message.sentAt,
    });
  }
}
