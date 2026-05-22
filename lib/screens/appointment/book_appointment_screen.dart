import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorId;
  const BookAppointmentScreen({super.key, required this.doctorId});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _db = DatabaseService();
  final _notesCtrl = TextEditingController();
  final _picker = ImagePicker();

  DoctorModel? _doctor;
  HospitalModel? _hospital;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  List<String> _bookedSlots = [];
  List<File> _documents = [];
  bool _loading = true;
  bool _booking = false;

  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await _db.getDoctor(widget.doctorId);
    if (doc == null) { if (mounted) setState(() => _loading = false); return; }
    final hosp = await _db.getHospital(doc.hospitalId);
    if (mounted) {
      setState(() {
        _doctor = doc;
        _hospital = hosp;
        _loading = false;
      });
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    if (_doctor == null) return;
    final booked = await _db.getBookedSlots(_doctor!.id, _selectedDate);
    if (mounted) setState(() => _bookedSlots = booked);
  }

  List<String> _generateSlots() {
    if (_doctor == null) return [];
    final slots = <String>[];
    final parts = _doctor!.startTime.split(':');
    var h = int.parse(parts[0]);
    var m = int.parse(parts[1]);
    final endParts = _doctor!.endTime.split(':');
    final endH = int.parse(endParts[0]);
    final endM = int.parse(endParts[1]);

    while (h < endH || (h == endH && m < endM)) {
      slots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      m += _doctor!.slotDuration;
      while (m >= 60) { m -= 60; h++; }
    }
    return slots;
  }

  bool _isDayAvailable(DateTime date) {
    if (_doctor == null) return false;
    final dayName = _days[date.weekday - 1];
    return _doctor!.availableDays.contains(dayName);
  }

  Future<void> _pickDocument() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _documents.add(File(file.path)));
  }

  Future<void> _book() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    setState(() => _booking = true);
    final user = context.read<AuthProvider>().user!;

    // Upload documents
    final docUrls = <String>[];
    for (final f in _documents) {
      final url = await _db.uploadFile(
          f, 'documents/${user.id}/${DateTime.now().millisecondsSinceEpoch}');
      docUrls.add(url);
    }

    final appt = AppointmentModel(
      id: '',
      patientId: user.id,
      patientName: user.name,
      doctorId: _doctor!.id,
      doctorName: _doctor!.name,
      doctorSpecialty: _doctor!.specialty,
      hospitalId: _hospital!.id,
      hospitalName: _hospital!.name,
      date: _selectedDate,
      timeSlot: _selectedSlot!,
      consultationFee: _doctor!.consultationFee,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      documentUrls: docUrls,
      createdAt: DateTime.now(),
    );

    try {
      final id = await _db.createAppointment(appt);
      if (mounted) {
        context.pop();
        context.push('/appointment/$id');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: AppColors.approved,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _booking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
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

    final slots = _generateSlots();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedSlot != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Consultation fee: ₱${_doctor!.consultationFee.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              AppButton(
                label: 'Confirm Booking',
                onTap: _book,
                loading: _booking,
                icon: Icons.check_circle_outline_rounded,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  DoctorAvatar(
                      name: _doctor!.name,
                      photoUrl: _doctor!.photoUrl,
                      size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_doctor!.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(_doctor!.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.primary)),
                        if (_hospital != null)
                          Text(_hospital!.name,
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date picker
            Text('Select Date',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final date = DateTime.now().add(Duration(days: i + 1));
                  final available = _isDayAvailable(date);
                  final selected = _selectedDate.day == date.day &&
                      _selectedDate.month == date.month;
                  return GestureDetector(
                    onTap: available
                        ? () {
                            setState(() {
                              _selectedDate = date;
                              _selectedSlot = null;
                            });
                            _loadSlots();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 54,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : available
                                ? AppColors.surface
                                : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _days[date.weekday - 1],
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? Colors.white
                                  : available
                                      ? AppColors.textSecondary
                                      : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : available
                                      ? AppColors.textPrimary
                                      : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Time slots
            Text('Available Slots',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '${_bookedSlots.length} of ${slots.length} slots taken',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: slots.map((slot) {
                final booked = _bookedSlots.contains(slot);
                final selected = _selectedSlot == slot;
                return GestureDetector(
                  onTap: booked ? null : () => setState(() => _selectedSlot = slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: booked
                          ? AppColors.surfaceVariant
                          : selected
                              ? AppColors.primary
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: booked
                            ? AppColors.border
                            : selected
                                ? AppColors.primary
                                : AppColors.border,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: booked
                            ? AppColors.textHint
                            : selected
                                ? Colors.white
                                : AppColors.textPrimary,
                        decoration: booked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notes
            Text('Notes (Optional)',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Describe your concern...',
              controller: _notesCtrl,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 20),

            // Documents
            Row(
              children: [
                Text('Documents',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 8),
                Text('(Optional)',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_documents.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._documents.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value.path.split('/').last,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            color: AppColors.textHint,
                            onPressed: () => setState(
                                () => _documents.removeAt(e.key)),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }
}