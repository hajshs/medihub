import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabs;
  List<AppointmentModel> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    final appts = await _db.getPatientAppointments(uid);
    if (mounted) setState(() { _appointments = appts; _loading = false; });
  }

  List<AppointmentModel> _filtered(AppointmentStatus status) =>
      _appointments.where((a) => a.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabs,
          labelStyle: const TextStyle(
              fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontFamily: 'Outfit', fontSize: 13),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: [
            _tab('Pending', _filtered(AppointmentStatus.pending).length),
            _tab('Approved', _filtered(AppointmentStatus.approved).length),
            _tab('Completed', _filtered(AppointmentStatus.completed).length),
            _tab('Cancelled', _filtered(AppointmentStatus.cancelled).length),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _list(AppointmentStatus.pending),
                _list(AppointmentStatus.approved),
                _list(AppointmentStatus.completed),
                _list(AppointmentStatus.cancelled),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/search'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Appointment',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Tab _tab(String label, int count) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _list(AppointmentStatus status) {
    final items = _filtered(status);
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No ${status.label.toLowerCase()} appointments',
        subtitle: status == AppointmentStatus.pending ||
                status == AppointmentStatus.approved
            ? 'Book an appointment to get started.'
            : 'Your ${status.label.toLowerCase()} appointments will appear here.',
        actionLabel: status == AppointmentStatus.pending
            ? 'Find a Doctor'
            : null,
        onAction: () => context.go('/search'),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AppointmentCard(
          appointment: items[i],
          onCancel: status == AppointmentStatus.pending ? () => _cancel(items[i]) : null,
          onFeedback: status == AppointmentStatus.completed
              ? () => context.push('/feedback/${items[i].id}')
              : null,
        ),
      ),
    );
  }

  Future<void> _cancel(AppointmentModel appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: AppColors.cancelled))),
        ],
      ),
    );

    if (confirm == true) {
      await _db.updateAppointmentStatus(appt.id, AppointmentStatus.cancelled);
      _load();
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

// ─── Appointment Card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onFeedback;

  const _AppointmentCard(
      {required this.appointment, this.onCancel, this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return GestureDetector(
      onTap: () => context.push('/appointment/${a.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DoctorAvatar(name: a.doctorName, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.doctorName,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(a.doctorSpecialty,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                StatusBadge(status: a.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                _Info(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${a.date.day}/${a.date.month}/${a.date.year}'),
                const SizedBox(width: 20),
                _Info(icon: Icons.access_time_rounded, text: a.timeSlot),
                const SizedBox(width: 20),
                _Info(
                    icon: Icons.payments_outlined,
                    text:
                        '₱${a.consultationFee.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 6),
            _Info(
                icon: Icons.local_hospital_outlined,
                text: a.hospitalName),
            if (onCancel != null || onFeedback != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onFeedback != null)
                    Expanded(
                      child: AppButton(
                        label: 'Leave Review',
                        icon: Icons.star_outline_rounded,
                        onTap: onFeedback,
                      ),
                    ),
                  if (onCancel != null)
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        onTap: onCancel,
                        outline: true,
                        color: AppColors.cancelled,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}