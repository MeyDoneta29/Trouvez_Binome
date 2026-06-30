import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_theme.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late Set<String> _selected;

  final List<String> _jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
  final List<String> _creneaux = [
    '8h-10h', '10h-12h', '12h-14h',
    '14h-16h', '16h-18h', '18h-20h'
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _selected = Set<String>.from(user?.disponibilites ?? []);
  }

  String _key(String jour, String creneau) => '$jour-$creneau';

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final list = _selected.toList();
    await userProvider.updateDisponibilites(auth.user!.uid, list);
    auth.updateLocalUser(auth.user!.copyWith(disponibilites: list));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilites mises a jour')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Disponibilites'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selectionner vos creneaux disponibles',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selected.length} creneau(x) selectionne(s)',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Table(
                border: TableBorder.all(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                columnWidths: const {
                  0: FixedColumnWidth(60),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                    ),
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      ..._jours.map(
                        (j) => TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              j,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ..._creneaux.map((creneau) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              creneau,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        ..._jours.map((jour) {
                          final key = _key(jour, creneau);
                          final isSelected = _selected.contains(key);
                          return TableCell(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                if (isSelected) {
                                  _selected.remove(key);
                                } else {
                                  _selected.add(key);
                                }
                              }),
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.8)
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 18)
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: AppTheme.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                const Text('Disponible',
                    style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(width: 24),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Non disponible',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
