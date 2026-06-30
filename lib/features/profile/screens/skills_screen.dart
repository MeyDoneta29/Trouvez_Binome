import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  late List<String> _selected;
  String _searchQuery = '';

  final Map<String, List<String>> _skillsByCategory = {
    'Langages': [
      'Python', 'Java', 'Dart', 'JavaScript', 'C', 'C++', 'C#',
      'PHP', 'Swift', 'Kotlin', 'Go', 'Rust', 'TypeScript'
    ],
    'Frameworks': [
      'Flutter', 'React', 'Angular', 'Vue.js', 'Django', 'Spring Boot',
      'Laravel', 'Node.js', 'Express', 'FastAPI', 'Next.js'
    ],
    'Bases de donnees': [
      'MySQL', 'PostgreSQL', 'MongoDB', 'Firebase', 'SQLite',
      'Redis', 'Oracle', 'Supabase'
    ],
    'Outils': [
      'Git', 'Docker', 'Kubernetes', 'Linux', 'GitHub', 'GitLab',
      'Figma', 'VS Code', 'Android Studio', 'Postman'
    ],
    'Soft Skills': [
      'Travail en equipe', 'Communication', 'Leadership',
      'Gestion du temps', 'Creativite', 'Autonomie', 'Organisation'
    ],
  };

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _selected = List<String>.from(user?.competences ?? []);
  }

  List<String> get _filteredSkills {
    if (_searchQuery.isEmpty) return [];
    return _skillsByCategory.values
        .expand((s) => s)
        .where((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    await userProvider.updateCompetences(auth.user!.uid, _selected);
    final updated = auth.user!.copyWith(competences: _selected);
    auth.updateLocalUser(updated.copyWith(profileCompletion: updated.calculateCompletion()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Competences mises a jour')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Competences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher une competence...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_selected.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              color: AppTheme.primary.withOpacity(0.05),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selected
                    .map((s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 13)),
                          backgroundColor: AppTheme.primary.withOpacity(0.15),
                          labelStyle: const TextStyle(color: AppTheme.primary),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () =>
                              setState(() => _selected.remove(s)),
                        ))
                    .toList(),
              ),
            ),
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildCategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredSkills;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (_, i) => _SkillTile(
        skill: results[i],
        selected: _selected.contains(results[i]),
        onTap: () => setState(() {
          if (_selected.contains(results[i])) {
            _selected.remove(results[i]);
          } else {
            _selected.add(results[i]);
          }
        }),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _skillsByCategory.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((skill) {
                final isSelected = _selected.contains(skill);
                return FilterChip(
                  label: Text(skill),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    if (isSelected) {
                      _selected.remove(skill);
                    } else {
                      _selected.add(skill);
                    }
                  }),
                  selectedColor: AppTheme.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final String skill;
  final bool selected;
  final VoidCallback onTap;

  const _SkillTile(
      {required this.skill, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(skill),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : const Icon(Icons.circle_outlined, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
