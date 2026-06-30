import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/student_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final _userRepo = UserRepository();

  String _filterFiliere = '';
  String _filterAnnee = '';
  List<UserModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  final List<String> _filieres = ['', 'CSI', 'GE', 'GC', 'GM', 'TELE', 'INFO'];
  final List<String> _annees = ['', 'L1', 'L2', 'L3', 'M1', 'M2'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    final currentUid = context.read<AuthProvider>().user?.uid;
    try {
      final results = await _userRepo.searchUsers(
        filiere: _filterFiliere.isNotEmpty ? _filterFiliere : null,
        annee: _filterAnnee.isNotEmpty ? _filterAnnee : null,
        query: _searchCtrl.text.trim(),
        excludeUid: currentUid,
      );
      setState(() => _results = results);
    } catch (e) {
      setState(() => _results = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _searched = true;
    });
    final currentUid = context.read<AuthProvider>().user?.uid;
    try {
      final results = await _userRepo.getAllUsers(excludeUid: currentUid);
      setState(() => _results = results);
    } catch (_) {
      setState(() => _results = []);
    }
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher un Binome')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom ou filiere...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppTheme.primary),
                      onPressed: _search,
                    ),
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterFiliere,
                        decoration: const InputDecoration(
                          labelText: 'Filiere',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: _filieres
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(f.isEmpty ? 'Toutes' : f),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _filterFiliere = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterAnnee,
                        decoration: const InputDecoration(
                          labelText: 'Annee',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        items: _annees
                            .map((a) => DropdownMenuItem(
                                  value: a,
                                  child: Text(a.isEmpty ? 'Toutes' : a),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _filterAnnee = v ?? ''),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Filtrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : !_searched
                    ? const Center(
                        child: Text(
                          'Recherchez des etudiants',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : _results.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun etudiant trouve',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _results.length,
                            itemBuilder: (_, i) =>
                                StudentCard(user: _results[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
