class MessageModel {
  final String id;
  final String senderId;
  final String senderNom;
  final String content;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderNom,
    required this.content,
    required this.sentAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderNom: map['senderNom'] ?? '',
      content: map['content'] ?? '',
      sentAt: map['sentAt'] != null
          ? (map['sentAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderNom': senderNom,
      'content': content,
      'sentAt': sentAt,
    };
  }
}
