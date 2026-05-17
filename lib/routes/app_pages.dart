import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/forgotPassword_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/doctor_info_screen.dart';
import '../screens/available_doctors_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/appointments_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/hospital_interface_screen.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),
    AppRoutes.login: (context) => const LoginScreen(),
    AppRoutes.home: (context) => const HomeScreen(),
    AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
    AppRoutes.register: (context) => const RegisterScreen(),
    AppRoutes.profile: (context) => const ProfileScreen(),
    AppRoutes.doctorInfo: (context) => const DoctorInfoScreen(),
    AppRoutes.availableDoctors: (context) => const AvailableDoctorsScreen(),
    AppRoutes.schedule: (context) => const ScheduleScreen(),
    AppRoutes.appointments: (context) => const AppointmentsScreen(),
    AppRoutes.chat: (context) => const ChatScreen(),
    AppRoutes.feedback: (context) => const FeedbackScreen(),
    AppRoutes.admin: (context) => const AdminScreen(),
    AppRoutes.hospitalInterface: (context) => const HospitalInterfaceScreen(),
  };
}