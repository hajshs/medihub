import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  int selectedTab = 0;
  final List<String> tabs = ['Users', 'Hospitals', 'Doctor'];

  final List<Map<String, String>> users = [
    {'name': 'John', 'time': 'Today, 07:00 PM', 'doctor': 'Dr Scatter'},
    {'name': 'Lalata', 'time': 'Today, 07:00 PM', 'doctor': 'Dr Scatter'},
    {'name': 'Lloyd', 'time': 'Today, 07:00 PM', 'doctor': 'Dr Scatter'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Medihub Admin interface",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // STATS CARD
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _AdminStat(label: 'Users', value: '102,569'),
                          _AdminStat(label: 'Doctors', value: '268'),
                          _AdminStat(label: 'Hospitals', value: '52'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TABS
                    Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = selectedTab == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedTab = index),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xff4a7957)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // USER LIST
                    ...users.map((user) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(user['time']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(user['doctor']!,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Edit Booking",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4a7957),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Remove booking",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
            BottomNav(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String value;
  const _AdminStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}