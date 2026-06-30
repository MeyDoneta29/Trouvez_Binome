import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/skills_screen.dart';
import '../../features/availability/screens/availability_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/matching/screens/matches_screen.dart';
import '../../features/messaging/screens/conversations_screen.dart';
import '../../features/messaging/screens/chat_screen.dart';

class AppRouter {
  static GoRouter createRouter(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isAuth = auth.status == AuthStatus.authenticated;
        final isUnknown = auth.status == AuthStatus.unknown;
        final loc = state.matchedLocation;

        if (isUnknown) return '/';
        if (!isAuth && loc != '/login' && loc != '/register') return '/login';
        if (isAuth && (loc == '/login' || loc == '/register')) return '/home';
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/skills', builder: (_, __) => const SkillsScreen()),
        GoRoute(
            path: '/availability',
            builder: (_, __) => const AvailabilityScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/matches', builder: (_, __) => const MatchesScreen()),
        GoRoute(
            path: '/conversations',
            builder: (_, __) => const ConversationsScreen()),
        GoRoute(
          path: '/chat/:matchId/:partnerName',
          builder: (_, state) => ChatScreen(
            matchId: state.pathParameters['matchId']!,
            partnerName: state.pathParameters['partnerName']!,
          ),
        ),
      ],
    );
  }
}
