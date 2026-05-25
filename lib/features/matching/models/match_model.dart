// Les statuts possibles d'un match
enum MatchStatus { pending, accepted, rejected }

class MatchModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final double score;
  final MatchStatus status;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.score,
    this.status = MatchStatus.pending,
    required this.createdAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'score': score,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}