import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

class HospitalInterfaceScreen extends StatelessWidget {
  const HospitalInterfaceScreen({super.key});

  final List<Map<String, String>> messages = const [
    {'name': 'Samantha William', 'preview': 'Lorem ipsum dolor sit amet..'},
    {'name': 'Tony Soap', 'preview': 'Lorem ipsum dolor sit amet..'},
    {'name': 'Jordan Nico', 'preview': 'Lorem ipsum dolor sit amet..'},
  ];

  final List<Map<String, String>> requests = const [
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
                    const Text("Hospital Interface",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),

                    const SizedBox(height: 16),

                    // MESSAGES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Messages",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text("View All",
                              style: TextStyle(color: Color(0xff4a7957))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ...messages.map((msg) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(msg['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(msg['preview']!,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    )),

                    const SizedBox(height: 16),

                    const Text("Appointment Request",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                    const SizedBox(height: 10),

                    ...requests.map((req) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(req['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(req['time']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          Text(req['doctor']!,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text("Accept",
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text("Decline",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff4a7957),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text("Message",
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