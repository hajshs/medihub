import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../routes/app_routes.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_outlined, 0, AppRoutes.home),
          _navItem(context, Icons.calendar_month_outlined, 1, AppRoutes.appointments),
          _navItem(context, FontAwesomeIcons.circleUser, 2, AppRoutes.profile),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, int index, String route) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xffe8f0ea) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xff4a7957) : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}