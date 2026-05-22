import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _db = DatabaseService();
  AppointmentModel? _appointment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;
    final appts = await _db.getPatientAppointments(uid);
    final appt = appts.where((a) => a.id == widget.appointmentId).firstOrNull;
    if (mounted) setState(() { _appointment = appt; _loading = false; });
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.cancelled)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _db.updateAppointmentStatus(widget.appointmentId, AppointmentStatus.cancelled);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_appointment == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Appointment not found.')));
    }

    final a = _appointment!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _statusColor(a.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor(a.status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(a.status), color: _statusColor(a.status), size: 28),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.status.label,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(a.status),
                        ),
                      ),
                      Text(
                        _statusDesc(a.status),
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          color: _statusColor(a.status).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Doctor info
            _Section(
              title: 'Doctor',
              child: Row(
                children: [
                  DoctorAvatar(name: a.doctorName, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.doctorName, style: Theme.of(context).textTheme.titleLarge),
                        Text(a.doctorSpecialty,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary)),
                        Text(a.hospitalName, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () => context.push('/doctor/${a.doctorId}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date & time
            _Section(
              title: 'Schedule',
              child: Row(
                children: [
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: '${_monthName(a.date.month)} ${a.date.day}, ${a.date.year}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoTile(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: a.timeSlot,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fees
            _Section(
              title: 'Consultation Fee',
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    '₱${a.consultationFee.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            if (a.notes != null && a.notes!.isNotEmpty) ...[
              _Section(
                title: 'Notes',
                child: Text(a.notes!, style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 16),
            ],

            // Documents
            if (a.documentUrls.isNotEmpty) ...[
              _Section(
                title: 'Attached Documents',
                child: Column(
                  children: a.documentUrls.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text('Document ${e.key + 1}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Booked on
            _Section(
              title: 'Booking Info',
              child: _InfoTile(
                icon: Icons.info_outline_rounded,
                label: 'Booked on',
                value:
                    '${_monthName(a.createdAt.month)} ${a.createdAt.day}, ${a.createdAt.year}',
              ),
            ),
            const SizedBox(height: 28),

            // Actions
            if (a.status == AppointmentStatus.pending) ...[
              AppButton(
                label: 'Cancel Appointment',
                onTap: _cancel,
                outline: true,
                color: AppColors.cancelled,
                icon: Icons.cancel_outlined,
              ),
              const SizedBox(height: 12),
            ],

            if (a.status == AppointmentStatus.completed) ...[
              AppButton(
                label: 'Leave a Review',
                icon: Icons.star_outline_rounded,
                onTap: () => context.push('/feedback/${a.id}'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Message Doctor',
                icon: Icons.chat_bubble_outline_rounded,
                outline: true,
                onTap: () => context.push('/chats'),
              ),
              const SizedBox(height: 12),
            ],

            if (a.status == AppointmentStatus.approved) ...[
              AppButton(
                label: 'Message Doctor',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => context.push('/chats'),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Cancel Appointment',
                onTap: _cancel,
                outline: true,
                color: AppColors.cancelled,
                icon: Icons.cancel_outlined,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:   return AppColors.pending;
      case AppointmentStatus.approved:  return AppColors.approved;
      case AppointmentStatus.completed: return AppColors.completed;
      case AppointmentStatus.cancelled: return AppColors.cancelled;
    }
  }

  IconData _statusIcon(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:   return Icons.hourglass_top_rounded;
      case AppointmentStatus.approved:  return Icons.check_circle_outline_rounded;
      case AppointmentStatus.completed: return Icons.task_alt_rounded;
      case AppointmentStatus.cancelled: return Icons.cancel_outlined;
    }
  }

  String _statusDesc(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:   return 'Waiting for provider confirmation';
      case AppointmentStatus.approved:  return 'Your appointment is confirmed';
      case AppointmentStatus.completed: return 'Appointment has been completed';
      case AppointmentStatus.cancelled: return 'This appointment was cancelled';
    }
  }

  String _monthName(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m - 1];
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHint,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Outfit', fontSize: 11, color: AppColors.textHint)),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ],
    );
  }
}