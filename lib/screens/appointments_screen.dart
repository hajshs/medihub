import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/bottom_nav.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 16),
            const Text(
              "My Appointments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // TABS
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xff4a7957),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xff4a7957),
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Past"),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentList(context),
                  const Center(child: Text("No past appointments")),
                ],
              ),
            ),

            BottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAppointmentCard(context),
      ],
    );
  }

  Widget _buildAppointmentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // DOCTOR INFO ROW
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(width: 60, height: 60, color: Colors.grey[300]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dr. Abhishek",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Today, 07:00 PM",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f0ea),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Scheduled",
                      style: TextStyle(
                        color: Color(0xff4a7957),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // RESCHEDULE + SEE DETAILS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.schedule),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Reschedule",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorInfo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4a7957),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "See Details",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // MESSAGE DOCTOR
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff4a7957)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(
                Icons.chat_outlined,
                color: Color(0xff4a7957),
                size: 18,
              ),
              label: const Text(
                "Message Doctor",
                style: TextStyle(color: Color(0xff4a7957)),
              ),
            ),
          ),

        ],
      ),
    );
  }
}