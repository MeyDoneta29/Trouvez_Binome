import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill_model.dart';

class SkillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'skills';

  // Récupérer toutes les compétences prédéfinies
  Future<List<SkillModel>> getPresetSkills() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isPreset', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Récupérer les compétences par catégorie
  Future<List<SkillModel>> getSkillsByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Ajouter une nouvelle compétence
  Future<void> addSkill(SkillModel skill) async {
    await _firestore
        .collection(_collection)
        .doc(skill.id)
        .set(skill.toMap());
  }

  // Rechercher une compétence par nom
  Future<List<SkillModel>> searchSkills(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .get();

    return snapshot.docs
        .map((doc) => SkillModel.fromMap(doc.data(), doc.id))
        .where((skill) =>
            skill.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}