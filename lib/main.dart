import 'package:flutter/material.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4a7957),
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        final builder = AppPages.routes[settings.name];
        if (builder == null) return null;

        // Bottom nav screens — no animation (feels like tabs)
        const noTransitionRoutes = [
          AppRoutes.home,
          AppRoutes.appointments,
          AppRoutes.profile,
        ];

        if (noTransitionRoutes.contains(settings.name)) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => builder(context),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          );
        }

        // All other screens — slide up from bottom
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, animation, __) => builder(context),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    );
  }
}