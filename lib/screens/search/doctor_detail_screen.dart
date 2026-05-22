import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class DoctorDetailScreen extends StatefulWidget {
  final String doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final _db = DatabaseService();
  DoctorModel? _doctor;
  List<ReviewModel> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await _db.getDoctor(widget.doctorId);
    final revs = await _db.getDoctorReviews(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doc;
        _reviews = revs;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_doctor == null) {
      return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Doctor not found.')));
    }

    final d = _doctor!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: AppButton(
            label: 'Book Appointment',
            icon: Icons.calendar_today_rounded,
            onTap: () => context.push('/book/${d.id}'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  DoctorAvatar(name: d.name, photoUrl: d.photoUrl, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text(d.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.primary)),
                        const SizedBox(height: 8),
                        StarRating(
                            rating: d.rating, count: d.reviewCount, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _StatBox(
                  label: 'Fee',
                  value: '₱${d.consultationFee.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Slot',
                  value: '${d.slotDuration} min',
                  icon: Icons.timer_outlined,
                ),
                const SizedBox(width: 12),
                _StatBox(
                  label: 'Reviews',
                  value: '${d.reviewCount}',
                  icon: Icons.star_outline_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bio
            Text('About', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(d.bio, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            // Available days
            Text('Available Days',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: d.availableDays.map((day) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(day,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      )),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              '${d.startTime} – ${d.endTime}  ·  ${d.slotDuration}-minute slots',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Reviews
            Row(
              children: [
                Text('Patient Reviews',
                    style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                Text('${_reviews.length} review${_reviews.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),

            if (_reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: EmptyState(
                  icon: Icons.reviews_outlined,
                  title: 'No reviews yet',
                  subtitle: 'Be the first to leave a review.',
                ),
              )
            else
              ...(_reviews.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReviewCard(review: r),
                  ))),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DoctorAvatar(name: review.patientName, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.patientName,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StarRating(rating: review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}