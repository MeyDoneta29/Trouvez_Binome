class ProfileModel {
  final String userId;
  final List<String> skillIds;
  final Map<String, List<String>> availability;
  final DateTime updatedAt;

  ProfileModel({
    required this.userId,
    required this.skillIds,
    required this.availability,
    required this.updatedAt,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map, String userId) {
    return ProfileModel(
      userId: userId,
      skillIds: List<String>.from(map['skills'] ?? []),
      availability: Map<String, List<String>>.from(
        (map['availability'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skills': skillIds,
      'availability': availability,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}