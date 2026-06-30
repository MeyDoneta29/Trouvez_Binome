class UserModel {
  final String uid;
  final String nom;
  final String email;
  final String filiere;
  final String annee;
  final String? bio;
  final String? github;
  final String? linkedin;
  final List<String> competences;
  final List<String> disponibilites;
  final double profileCompletion;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.nom,
    required this.email,
    required this.filiere,
    required this.annee,
    this.bio,
    this.github,
    this.linkedin,
    this.competences = const [],
    this.disponibilites = const [],
    this.profileCompletion = 0.0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      filiere: map['filiere'] ?? '',
      annee: map['annee'] ?? '',
      bio: map['bio'],
      github: map['github'],
      linkedin: map['linkedin'],
      competences: List<String>.from(map['competences'] ?? []),
      disponibilites: List<String>.from(map['disponibilites'] ?? []),
      profileCompletion: (map['profileCompletion'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'filiere': filiere,
      'annee': annee,
      'bio': bio,
      'github': github,
      'linkedin': linkedin,
      'competences': competences,
      'disponibilites': disponibilites,
      'profileCompletion': profileCompletion,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? nom,
    String? filiere,
    String? annee,
    String? bio,
    String? github,
    String? linkedin,
    List<String>? competences,
    List<String>? disponibilites,
    double? profileCompletion,
  }) {
    return UserModel(
      uid: uid,
      nom: nom ?? this.nom,
      email: email,
      filiere: filiere ?? this.filiere,
      annee: annee ?? this.annee,
      bio: bio ?? this.bio,
      github: github ?? this.github,
      linkedin: linkedin ?? this.linkedin,
      competences: competences ?? this.competences,
      disponibilites: disponibilites ?? this.disponibilites,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      createdAt: createdAt,
    );
  }
    double calculateCompletion() {
    double score = 0.2;
    if (bio != null && bio!.isNotEmpty) score += 0.15;
    if (github != null && github!.isNotEmpty) score += 0.1;
    if (linkedin != null && linkedin!.isNotEmpty) score += 0.1;
    if (competences.isNotEmpty) score += 0.25;
    if (disponibilites.isNotEmpty) score += 0.2;
    return score.clamp(0.0, 1.0);
  }
}
