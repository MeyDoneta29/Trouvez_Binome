enum MatchStatus { pending, accepted, rejected }

class MatchModel {
  final String id;
  final String userId1;
  final String userId2;
  final String nomUser1;
  final String nomUser2;
  final double score;
  final MatchStatus status;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.nomUser1,
    required this.nomUser2,
    required this.score,
    required this.status,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      userId1: map['userId1'] ?? '',
      userId2: map['userId2'] ?? '',
      nomUser1: map['nomUser1'] ?? '',
      nomUser2: map['nomUser2'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => MatchStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId1': userId1,
      'userId2': userId2,
      'nomUser1': nomUser1,
      'nomUser2': nomUser2,
      'score': score,
      'status': status.name,
      'createdAt': createdAt,
    };
  }

  String getPartnerName(String currentUid) {
    return currentUid == userId1 ? nomUser2 : nomUser1;
  }

  String getPartnerId(String currentUid) {
    return currentUid == userId1 ? userId2 : userId1;
  }
}
