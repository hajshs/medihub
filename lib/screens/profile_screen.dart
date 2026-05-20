import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../routes/app_routes.dart';
import '../../widgets/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // PROFILE PHOTO
            const CircleAvatar(
              radius: 55,
              backgroundImage: AssetImage('assets/logo.png'),
            ),

            const SizedBox(height: 16),

            // NAME
            const Text(
              "Coco Martin",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // EMAIL
            const Text(
              "cocomartint@gmail.com",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),

            // MENU ITEMS
            _buildMenuItem(
              icon: FontAwesomeIcons.user,
              label: "Edit Profile",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.lock,
              label: "Change Password",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.globe,
              label: "Languages",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.fileLines,
              label: "Legal and Policies",
              onTap: () {},
            ),
            _buildMenuItem(
              icon: FontAwesomeIcons.circleQuestion,
              label: "Help and Support",
              onTap: () {},
            ),

            const SizedBox(height: 8),

            // LOGOUT
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
            ),

            const Spacer(),

            // BOTTOM NAV
            BottomNav(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, size: 18, color: Colors.black87),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}