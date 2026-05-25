class UserModel {
  final String id;
  final String name;
  final String email;
  final String filiere;
  final String annee;
  final String bio;
  final String github;
  final String linkedin;
  final double profileCompletion;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.filiere,
    required this.annee,
    this.bio = '',
    this.github = '',
    this.linkedin = '',
    this.profileCompletion = 0.0,
    required this.createdAt,
  });

  // Convertir un document Firestore en UserModel
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      filiere: map['filiere'] ?? '',
      annee: map['annee'] ?? '',
      bio: map['bio'] ?? '',
      github: map['github'] ?? '',
      linkedin: map['linkedin'] ?? '',
      profileCompletion: (map['profileCompletion'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Convertir un UserModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'filiere': filiere,
      'annee': annee,
      'bio': bio,
      'github': github,
      'linkedin': linkedin,
      'profileCompletion': profileCompletion,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}