import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class HospitalDetailScreen extends StatefulWidget {
  final String hospitalId;
  const HospitalDetailScreen({super.key, required this.hospitalId});

  @override
  State<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends State<HospitalDetailScreen> {
  final _db = DatabaseService();
  HospitalModel? _hospital;
  List<DoctorModel> _doctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await _db.getHospital(widget.hospitalId);
    final docs = await _db.getDoctorsByHospital(widget.hospitalId);
    if (mounted) {
      setState(() {
        _hospital = h;
        _doctors = docs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_hospital == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Facility not found.')),
      );
    }

    final h = _hospital!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: h.type == 'hospital'
                        ? [AppColors.primary, AppColors.primaryDark]
                        : [AppColors.accent, const Color(0xFF009E72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    h.type == 'hospital'
                        ? Icons.local_hospital_rounded
                        : Icons.medical_services_rounded,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verified
                  Row(
                    children: [
                      Expanded(
                        child: Text(h.name,
                            style: Theme.of(context).textTheme.displaySmall),
                      ),
                      if (h.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: AppColors.primary, size: 14),
                              SizedBox(width: 4),
                              Text('Verified',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  )),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(h.address,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  StarRating(rating: h.rating, count: h.reviewCount, size: 15),
                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.call_rounded,
                          label: 'Call',
                          onTap: () => launchUrl(Uri.parse('tel:${h.phone}')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.directions_rounded,
                          label: 'Directions',
                          onTap: () => launchUrl(Uri.parse(
                              'https://maps.google.com/?q=${h.lat},${h.lng}')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          onTap: () =>
                              launchUrl(Uri.parse('mailto:${h.email}')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Hours
                  _InfoSection(
                    title: 'Operating Hours',
                    icon: Icons.schedule_rounded,
                    child: Text(h.hours,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 16),

                  // Services
                  _InfoSection(
                    title: 'Services',
                    icon: Icons.medical_services_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: h.services
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    )),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Doctors
                  Text('Available Doctors',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),

                  if (_doctors.isEmpty)
                    const EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No doctors listed',
                      subtitle: 'Check back later.',
                    )
                  else
                    ...(_doctors.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DoctorCard(doctor: d),
                        ))),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoSection(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/doctor/${doctor.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            DoctorAvatar(name: doctor.name, photoUrl: doctor.photoUrl, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(doctor.specialty,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarRating(
                          rating: doctor.rating,
                          count: doctor.reviewCount),
                      const Spacer(),
                      Text(
                        '₱${doctor.consultationFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}