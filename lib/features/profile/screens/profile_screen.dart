import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _linkedinCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nomCtrl = TextEditingController(text: user?.nom ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _githubCtrl = TextEditingController(text: user?.github ?? '');
    _linkedinCtrl = TextEditingController(text: user?.linkedin ?? '');
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _bioCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final current = auth.user!;
    var updated = current.copyWith(
          nom: _nomCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          github: _githubCtrl.text.trim(),
          linkedin: _linkedinCtrl.text.trim(),
        );
    updated = updated.copyWith(profileCompletion: updated.calculateCompletion());
    await userProvider.updateProfile(updated);
    auth.updateLocalUser(updated);
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis a jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_editing) {
                _save();
              } else {
                setState(() => _editing = true);
              }
            },
            child: Text(
              _editing ? 'Enregistrer' : 'Modifier',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  user?.nom.isNotEmpty == true
                      ? user!.nom[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nomCtrl,
                label: 'Nom complet',
                icon: Icons.person_outline,
                enabled: _editing,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _bioCtrl,
                label: 'Bio',
                icon: Icons.info_outline,
                enabled: _editing,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _githubCtrl,
                label: 'Lien GitHub',
                icon: Icons.code,
                enabled: _editing,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _linkedinCtrl,
                label: 'Lien LinkedIn',
                icon: Icons.link,
                enabled: _editing,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Mes competences',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/skills'),
                    child: const Text('Modifier'),
                  ),
                ],
              ),
              if (user?.competences.isEmpty ?? true)
                const Text(
                  'Aucune competence ajoutee',
                  style: TextStyle(color: AppTheme.textSecondary),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: user!.competences
                      .map((c) => Chip(
                            label: Text(c),
                            backgroundColor:
                                AppTheme.primary.withOpacity(0.1),
                            labelStyle:
                                const TextStyle(color: AppTheme.primary),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/availability'),
                icon: const Icon(Icons.calendar_today_outlined),
                label: const Text('Gerer mes disponibilites'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
