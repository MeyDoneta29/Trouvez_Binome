import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/models/match_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/repositories/match_repository.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class StudentCard extends StatelessWidget {
  final UserModel user;

  const StudentCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Text(
                    user.nom.isNotEmpty ? user.nom[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${user.filiere} - ${user.annee}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.disponibilites.isNotEmpty
                        ? AppTheme.success.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.disponibilites.isNotEmpty ? 'Disponible' : 'Occupe',
                    style: TextStyle(
                      fontSize: 12,
                      color: user.disponibilites.isNotEmpty
                          ? AppTheme.success
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                user.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            if (user.competences.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: user.competences.take(4).map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.accent),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendMatchRequest(context),
                icon: const Icon(Icons.favorite_border, size: 18),
                label: const Text('Demander en binome'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMatchRequest(BuildContext context) async {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) return;

    final repo = MatchRepository();
    final exists = await repo.matchExists(currentUser.uid, user.uid);
    if (exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande deja envoyee')),
        );
      }
      return;
    }

    final score = _calculateScore(currentUser, user);
    final match = MatchModel(
      id: '',
      userId1: currentUser.uid,
      userId2: user.uid,
      nomUser1: currentUser.nom,
      nomUser2: user.nom,
      score: score,
      status: MatchStatus.pending,
      createdAt: DateTime.now(),
    );

    await repo.createMatch(match);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande envoyee a ${user.nom}')),
      );
    }
  }

  double _calculateScore(UserModel user1, UserModel user2) {
    if (user1.competences.isEmpty && user2.competences.isEmpty) return 0.5;
    final common = user1.competences
        .where((c) => user2.competences.contains(c))
        .length;
    final total = (user1.competences.length + user2.competences.length) / 2;
    return total == 0 ? 0 : (common / total).clamp(0.0, 1.0);
  }
}
