class SkillModel {
  final String id;
  final String name;
  final String category;
  final bool isPreset;

  SkillModel({
    required this.id,
    required this.name,
    required this.category,
    this.isPreset = true,
  });

  factory SkillModel.fromMap(Map<String, dynamic> map, String id) {
    return SkillModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      isPreset: map['isPreset'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'isPreset': isPreset,
    };
  }
}