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
      routes: AppPages.routes,
    );
  }
}