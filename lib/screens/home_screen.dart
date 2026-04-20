import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void handleProfile() {
    Navigator.pushNamed(context, AppRoutes.profile);
  }

  void handleSearch() {
    print("Search tapped");
    // TODO: Navigator.pushNamed(context, AppRoutes.search);
  }

  void handleStethoscope() {}

  void handleNotifications() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // CUSTOM HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // LEFT SIDE — profile + greeting
                  Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.circleUser,
                          size: 40,
                        ),
                        onPressed: handleProfile,
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, Juan!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "How are you feeling?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // RIGHT SIDE — two buttons
                  Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.stethoscope,
                          size: 22,
                        ),
                        onPressed: handleStethoscope,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 26,
                        ),
                        onPressed: handleNotifications,
                      ),
                    ],
                  ),

                ],
              ),

              const SizedBox(height: 16),

              // SEARCH BAR
              GestureDetector(
                onTap: handleSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "Search...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // REST OF YOUR HOME CONTENT GOES HERE

            ],
          ),
        ),
      ),
    );
  }
}