import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class DatabaseService {
  final _client = Supabase.instance.client;

  // ── HOSPITALS ─────────────────────────────────────────────────────────────

  Future<List<HospitalModel>> getHospitals() async {
    final data = await _client
        .from('hospitals')
        .select()
        .order('name');
    return (data as List).map((m) => HospitalModel.fromMap(m)).toList();
  }

  Future<List<HospitalModel>> searchHospitals(String query) async {
    if (query.isEmpty) return getHospitals();

    final data = await _client
        .from('hospitals')
        .select()
        .or('name.ilike.%$query%,address.ilike.%$query%,services.ilike.%$query%');
    return (data as List).map((m) => HospitalModel.fromMap(m)).toList();
  }

  Future<HospitalModel?> getHospital(String id) async {
    final data = await _client
        .from('hospitals')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return HospitalModel.fromMap(data);
  }

  // ── DOCTORS ───────────────────────────────────────────────────────────────

  Future<List<DoctorModel>> getDoctorsByHospital(String hospitalId) async {
    final data = await _client
        .from('doctors')
        .select()
        .eq('hospital_id', hospitalId)
        .order('name');
    return (data as List).map((m) => DoctorModel.fromMap(m)).toList();
  }

  Future<DoctorModel?> getDoctor(String id) async {
    final data = await _client
        .from('doctors')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return DoctorModel.fromMap(data);
  }

  /// Returns time slots already booked for a doctor on a given date.
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    final dateStr = date.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'
    final data = await _client
        .from('appointments')
        .select('time_slot')
        .eq('doctor_id', doctorId)
        .eq('date', dateStr)
        .inFilter('status', ['pending', 'approved']);
    return (data as List).map((m) => m['time_slot'] as String).toList();
  }

  // ── APPOINTMENTS ──────────────────────────────────────────────────────────

  Future<String> createAppointment(AppointmentModel appt) async {
    final res = await _client
        .from('appointments')
        .insert(appt.toMap())
        .select('id')
        .single();

    final id = res['id'].toString();

    // Notify patient
    await _addNotification(
      userId: appt.patientId,
      title: 'Appointment Booked',
      body: 'Your appointment with ${appt.doctorName} on '
          '${_fmtDate(appt.date)} at ${appt.timeSlot} is pending confirmation.',
      type: 'appointment',
      referenceId: id,
    );

    return id;
  }

  Future<List<AppointmentModel>> getPatientAppointments(
      String patientId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('patient_id', patientId)
        .order('date', ascending: false);
    return (data as List).map((m) => AppointmentModel.fromMap(m)).toList();
  }

  /// Real-time stream for patient appointments
  Stream<List<AppointmentModel>> watchPatientAppointments(String patientId) {
    return _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('patient_id', patientId)
        .order('date', ascending: false)
        .map((data) =>
            data.map((m) => AppointmentModel.fromMap(m)).toList());
  }

  Future<List<AppointmentModel>> getProviderAppointments(
      String hospitalId) async {
    final data = await _client
        .from('appointments')
        .select()
        .eq('hospital_id', hospitalId)
        .order('date', ascending: false);
    return (data as List).map((m) => AppointmentModel.fromMap(m)).toList();
  }

  Stream<List<AppointmentModel>> watchProviderAppointments(
      String hospitalId) {
    return _client
        .from('appointments')
        .stream(primaryKey: ['id'])
        .eq('hospital_id', hospitalId)
        .order('date', ascending: false)
        .map((data) =>
            data.map((m) => AppointmentModel.fromMap(m)).toList());
  }

  Future<void> updateAppointmentStatus(
      String id, AppointmentStatus status) async {
    await _client
        .from('appointments')
        .update({'status': status.name})
        .eq('id', id);
  }

  // ── REVIEWS ───────────────────────────────────────────────────────────────

  Future<void> addReview(ReviewModel review) async {
    await _client.from('reviews').insert(review.toMap());

    // Recalculate doctor's average rating
    final data = await _client
        .from('reviews')
        .select('rating')
        .eq('doctor_id', review.doctorId);
    final ratings = (data as List).map((m) => (m['rating'] as num).toDouble());
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _client.from('doctors').update({
      'rating': avg,
      'review_count': ratings.length,
    }).eq('id', review.doctorId);
  }

  Future<List<ReviewModel>> getDoctorReviews(String doctorId) async {
    final data = await _client
        .from('reviews')
        .select()
        .eq('doctor_id', doctorId)
        .order('created_at', ascending: false);
    return (data as List).map((m) => ReviewModel.fromMap(m)).toList();
  }

  // ── MESSAGING ─────────────────────────────────────────────────────────────

  Future<String> getOrCreateChat(
    String myId,
    String myName,
    String otherId,
    String otherName,
  ) async {
    // Look for existing chat between the two users
    final existing = await _client
        .from('chats')
        .select()
        .or('and(user1_id.eq.$myId,user2_id.eq.$otherId),and(user1_id.eq.$otherId,user2_id.eq.$myId)')
        .maybeSingle();

    if (existing != null) return existing['id'].toString();

    final res = await _client.from('chats').insert({
      'user1_id': myId,
      'user1_name': myName,
      'user2_id': otherId,
      'user2_name': otherName,
      'last_message': '',
      'last_message_time': DateTime.now().toIso8601String(),
    }).select('id').single();

    return res['id'].toString();
  }

  Future<List<ChatModel>> getUserChats(String userId) async {
    final data = await _client
        .from('chats')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('last_message_time', ascending: false);
    return (data as List).map((m) => ChatModel.fromMap(m)).toList();
  }

  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((data) =>
            data.map((m) => MessageModel.fromMap(m)).toList());
  }

  Future<void> sendMessage(String chatId, MessageModel msg) async {
    await _client.from('messages').insert(msg.toMap());
    await _client.from('chats').update({
      'last_message': msg.text,
      'last_message_time': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────────────────────

  Future<void> _addNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? referenceId,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'is_read': false,
      'reference_id': referenceId,
    });
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List).map((m) => NotificationModel.fromMap(m)).toList();
  }

  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((m) => NotificationModel.fromMap(m)).toList());
  }

  Future<void> markNotificationRead(String notifId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notifId);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  // ── FILE UPLOAD ───────────────────────────────────────────────────────────

  Future<String> uploadFile(File file, String path) async {
    await _client.storage
        .from('medihub-files')
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from('medihub-files').getPublicUrl(path);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}
