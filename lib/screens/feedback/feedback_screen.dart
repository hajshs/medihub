import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class FeedbackScreen extends StatefulWidget {
  final String appointmentId;
  const FeedbackScreen({super.key, required this.appointmentId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _db = DatabaseService();
  final _commentCtrl = TextEditingController();
  AppointmentModel? _appointment;
  double _rating = 5;
  bool _loading = true;
  bool _submitting = false;
  bool _submitted = false;

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

  Future<void> _submit() async {
    if (_appointment == null) return;
    setState(() => _submitting = true);

    final user = context.read<AuthProvider>().user!;
    final review = ReviewModel(
      id: '',
      patientId: user.id,
      patientName: user.name,
      doctorId: _appointment!.doctorId,
      hospitalId: _appointment!.hospitalId,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await _db.addReview(review);
      if (mounted) setState(() { _submitting = false; _submitted = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave a Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _submitted
              ? _successView()
              : _formView(),
    );
  }

  Widget _formView() {
    final a = _appointment;
    if (a == null) return const Center(child: Text('Appointment not found.'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.primary)),
                      Text(a.hospitalName, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Rating
          Center(
            child: Column(
              children: [
                Text('How was your experience?',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  _ratingLabel(_rating),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: _ratingColor(_rating),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 48,
                  glow: false,
                  itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: Color(0xFFFFC107)),
                  onRatingUpdate: (r) => setState(() => _rating = r),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Comment
          Text('Tell us more (optional)',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Share your experience...',
            controller: _commentCtrl,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'Submit Review',
            icon: Icons.check_rounded,
            onTap: _submit,
            loading: _submitting,
          ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.accent, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Review Submitted!',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              'Thank you for your feedback. It helps other patients make informed decisions.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Done',
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r >= 5) return 'Excellent!';
    if (r >= 4) return 'Very Good';
    if (r >= 3) return 'Good';
    if (r >= 2) return 'Fair';
    return 'Poor';
  }

  Color _ratingColor(double r) {
    if (r >= 4) return AppColors.approved;
    if (r >= 3) return AppColors.pending;
    return AppColors.cancelled;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }
}