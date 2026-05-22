import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/search/hospital_detail_screen.dart';
import '../screens/search/doctor_detail_screen.dart';
import '../screens/appointment/book_appointment_screen.dart';
import '../screens/appointment/appointments_screen.dart';
import '../screens/appointment/appointment_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/messaging/chats_screen.dart';
import '../screens/messaging/chat_detail_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/provider/provider_dashboard_screen.dart';
import '../models/models.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final isAuth = status == AuthStatus.authenticated;
      final isLoading = status == AuthStatus.loading;
      final onAuthPage = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');

      if (isLoading) return null;
      if (!isAuth && !onAuthPage) return '/login';
      if (isAuth && onAuthPage) return '/home';
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Main shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            MainShell(child: child, location: state.matchedLocation),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (_, __) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // ── Detail screens (no bottom nav) ────────────────────────────────────
      GoRoute(
        path: '/hospital/:id',
        builder: (_, state) =>
            HospitalDetailScreen(hospitalId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/doctor/:id',
        builder: (_, state) =>
            DoctorDetailScreen(doctorId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/book/:doctorId',
        builder: (_, state) =>
            BookAppointmentScreen(doctorId: state.pathParameters['doctorId']!),
      ),
      GoRoute(
        path: '/appointment/:id',
        builder: (_, state) =>
            AppointmentDetailScreen(appointmentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (_, __) => const ChatsScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (_, state) =>
            ChatDetailScreen(chatId: state.pathParameters['chatId']!),
      ),
      GoRoute(
        path: '/feedback/:appointmentId',
        builder: (_, state) => FeedbackScreen(
            appointmentId: state.pathParameters['appointmentId']!),
      ),
      GoRoute(
        path: '/provider-dashboard',
        builder: (_, __) => const ProviderDashboardScreen(),
      ),
    ],
  );
}

// ─── Bottom Nav Shell ─────────────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  int _currentIndex() {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(currentIndex: _currentIndex()),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/search'); break;
            case 2: context.go('/appointments'); break;
            case 3: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today_rounded),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
