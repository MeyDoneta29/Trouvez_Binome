import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/match_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/repositories/match_repository.dart';
import '../../../core/theme/app_theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final _repo = MatchRepository();
  List<MatchModel> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final matches = await _repo.getAcceptedMatches(uid);
      setState(() => _conversations = matches);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune conversation',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acceptez des matchs pour commencer a discuter',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (_, i) {
                    final match = _conversations[i];
                    final partnerName = match.getPartnerName(uid);
                    return ListTile(
                      leading: CircleAvatar(
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
                      title: Text(
                        partnerName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Appuyez pour discuter',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/chat/${match.id}/$partnerName',
                      ),
                    );
                  },
                ),
    );
  }
}
