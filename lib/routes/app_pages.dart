import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/forgotPassword_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
    AppRoutes.register: (context) => const RegisterScreen(),
    AppRoutes.profile: (context) => const ProfileScreen(),
  };
}