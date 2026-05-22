import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});
  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  late TabController _tabs;
  List<AppointmentModel> _appointments = [];
  bool _loading = true;
  String? _hospitalId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    // For a provider, we find their hospital via doctors table
    // For simplicity in this school project, we'll load all appointments
    // In production, providers would have a linked hospitalId in their user record
    final uid = context.read<AuthProvider>().user?.id;
    if (uid == null) return;

    // Try to get appointments for all hospitals (demo mode)
    try {
      final hospitals = await _db.getHospitals();
      if (hospitals.isNotEmpty) {
        _hospitalId = hospitals.first.id;
        final appts = await _db.getProviderAppointments(_hospitalId!);
        if (mounted) setState(() { _appointments = appts; _loading = false; });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AppointmentModel> _filtered(AppointmentStatus? status) {
    if (status == null) return _appointments;
    return _appointments.where((a) => a.status == status).toList();
  }

  Future<void> _updateStatus(AppointmentModel appt, AppointmentStatus status) async {
    await _db.updateAppointmentStatus(appt.id, status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _filtered(AppointmentStatus.pending);
    final approved = _filtered(AppointmentStatus.approved);
    final all = _filtered(null);

    // Stats
    final total = _appointments.length;
    final pendingCount = pending.length;
    final approvedCount = approved.length;
    final completedCount = _filtered(AppointmentStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
              fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            _tab('Pending', pendingCount),
            _tab('Approved', approvedCount),
            const Tab(text: 'All'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats row
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    children: [
                      _Stat(label: 'Total', value: '$total', color: AppColors.primary),
                      _Stat(label: 'Pending', value: '$pendingCount', color: AppColors.pending),
                      _Stat(label: 'Approved', value: '$approvedCount', color: AppColors.approved),
                      _Stat(label: 'Done', value: '$completedCount', color: AppColors.completed),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _list(pending, showActions: true),
                      _list(approved, showApproved: true),
                      _list(all),
                    ],
                  ),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Text('$count',
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      );

  Widget _list(List<AppointmentModel> items,
      {bool showActions = false, bool showApproved = false}) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No appointments',
        subtitle: 'Appointments will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _ProviderApptCard(
          appointment: items[i],
          onApprove: showActions
              ? () => _updateStatus(items[i], AppointmentStatus.approved)
              : null,
          onDecline: showActions
              ? () => _updateStatus(items[i], AppointmentStatus.cancelled)
              : null,
          onComplete: showApproved
              ? () => _updateStatus(items[i], AppointmentStatus.completed)
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Outfit', fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ProviderApptCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onComplete;

  const _ProviderApptCard({
    required this.appointment,
    this.onApprove,
    this.onDecline,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
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
              DoctorAvatar(name: a.patientName, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.patientName, style: Theme.of(context).textTheme.titleLarge),
                    Text('Dr. ${a.doctorName}',
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
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${a.date.day}/${a.date.month}/${a.date.year}  ·  ${a.timeSlot}',
                  style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text('₱${a.consultationFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.notes_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(a.notes!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],

          if (onApprove != null || onDecline != null || onComplete != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onDecline != null)
                  Expanded(
                    child: AppButton(
                      label: 'Decline',
                      onTap: onDecline,
                      outline: true,
                      color: AppColors.cancelled,
                    ),
                  ),
                if (onDecline != null && onApprove != null)
                  const SizedBox(width: 10),
                if (onApprove != null)
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      onTap: onApprove,
                      icon: Icons.check_rounded,
                    ),
                  ),
                if (onComplete != null)
                  Expanded(
                    child: AppButton(
                      label: 'Mark Complete',
                      onTap: onComplete,
                      icon: Icons.task_alt_rounded,
                      color: AppColors.accent,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}