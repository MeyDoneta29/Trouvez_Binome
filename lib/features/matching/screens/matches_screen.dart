import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/match_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/match_repository.dart';
import '../../../core/theme/app_theme.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = MatchRepository();
  List<MatchModel> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final matches = await _repo.getMatchesForUser(uid);
      setState(() => _matches = matches);
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<MatchModel> get _pending =>
      _matches.where((m) => m.status == MatchStatus.pending).toList();
  List<MatchModel> get _accepted =>
      _matches.where((m) => m.status == MatchStatus.accepted).toList();
  List<MatchModel> get _rejected =>
      _matches.where((m) => m.status == MatchStatus.rejected).toList();

  Future<void> _updateStatus(MatchModel match, MatchStatus status) async {
    await _repo.updateMatchStatus(match.id, status);
    await _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Matchs'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'En attente (${_pending.length})'),
            Tab(text: 'Acceptes (${_accepted.length})'),
            Tab(text: 'Rejetes (${_rejected.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _MatchList(
                  matches: _pending,
                  currentUid: uid,
                  onAccept: (m) => _updateStatus(m, MatchStatus.accepted),
                  onReject: (m) => _updateStatus(m, MatchStatus.rejected),
                  showActions: true,
                ),
                _MatchList(
                  matches: _accepted,
                  currentUid: uid,
                  onChat: (m) => context.push(
                    '/chat/${m.id}/${m.getPartnerName(uid)}',
                  ),
                  showChat: true,
                ),
                _MatchList(
                  matches: _rejected,
                  currentUid: uid,
                ),
              ],
            ),
    );
  }
}

class _MatchList extends StatelessWidget {
  final List<MatchModel> matches;
  final String currentUid;
  final void Function(MatchModel)? onAccept;
  final void Function(MatchModel)? onReject;
  final void Function(MatchModel)? onChat;
  final bool showActions;
  final bool showChat;

  const _MatchList({
    required this.matches,
    required this.currentUid,
    this.onAccept,
    this.onReject,
    this.onChat,
    this.showActions = false,
    this.showChat = false,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Text(
          'Aucun match dans cette categorie',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (_, i) {
        final match = matches[i];
        final partnerName = match.getPartnerName(currentUid);
        final score = (match.score * 100).toInt();

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
                      backgroundColor: AppTheme.primary.withOpacity(0.15),
                      child: Text(
                        partnerName.isNotEmpty
                            ? partnerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Score de compatibilite : $score%',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: score >= 70
                            ? AppTheme.success.withOpacity(0.1)
                            : score >= 40
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$score%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: score >= 70
                              ? AppTheme.success
                              : score >= 40
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => onReject?.call(match),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Refuser'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onAccept?.call(match),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accepter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                            minimumSize: const Size(0, 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (showChat) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onChat?.call(match),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Envoyer un message'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
