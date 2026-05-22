// ─── USER MODEL ───────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String role; // 'patient' | 'provider' | 'admin'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.role = 'patient',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photo_url'],
      role: map['role'] ?? 'patient',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photo_url': photoUrl,
        'role': role,
      };

  UserModel copyWith({String? name, String? phone, String? photoUrl}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      createdAt: createdAt,
    );
  }
}

// ─── HOSPITAL MODEL ───────────────────────────────────────────────────────────

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final List<String> services;
  final String phone;
  final String email;
  final String hours;
  final double rating;
  final int reviewCount;
  final String? photoUrl;
  final String type; // 'hospital' | 'clinic'
  final bool isVerified;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.services,
    required this.phone,
    required this.email,
    required this.hours,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.photoUrl,
    this.type = 'clinic',
    this.isVerified = false,
  });

  factory HospitalModel.fromMap(Map<String, dynamic> m) {
    // services may be stored as a comma-separated string or a List
    List<String> parseServices(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return raw.toString().split(',').map((s) => s.trim()).toList();
    }

    return HospitalModel(
      id: m['id'].toString(),
      name: m['name'] ?? '',
      address: m['address'] ?? '',
      lat: (m['lat'] ?? 0.0).toDouble(),
      lng: (m['lng'] ?? 0.0).toDouble(),
      services: parseServices(m['services']),
      phone: m['phone'] ?? '',
      email: m['email'] ?? '',
      hours: m['hours'] ?? '',
      rating: (m['rating'] ?? 0.0).toDouble(),
      reviewCount: m['review_count'] ?? 0,
      photoUrl: m['photo_url'],
      type: m['type'] ?? 'clinic',
      isVerified: m['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'services': services.join(','),
        'phone': phone,
        'email': email,
        'hours': hours,
        'rating': rating,
        'review_count': reviewCount,
        'photo_url': photoUrl,
        'type': type,
        'is_verified': isVerified,
      };
}

// ─── DOCTOR MODEL ─────────────────────────────────────────────────────────────

class DoctorModel {
  final String id;
  final String hospitalId;
  final String name;
  final String specialty;
  final String bio;
  final double consultationFee;
  final String? photoUrl;
  final double rating;
  final int reviewCount;
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final int slotDuration; // minutes

  DoctorModel({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.consultationFee,
    this.photoUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
    this.slotDuration = 30,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> m) {
    List<String> parseDays(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return raw.toString().split(',').map((s) => s.trim()).toList();
    }

    return DoctorModel(
      id: m['id'].toString(),
      hospitalId: m['hospital_id'].toString(),
      name: m['name'] ?? '',
      specialty: m['specialty'] ?? '',
      bio: m['bio'] ?? '',
      consultationFee: (m['consultation_fee'] ?? 0.0).toDouble(),
      photoUrl: m['photo_url'],
      rating: (m['rating'] ?? 0.0).toDouble(),
      reviewCount: m['review_count'] ?? 0,
      availableDays: parseDays(m['available_days']),
      startTime: m['start_time'] ?? '08:00',
      endTime: m['end_time'] ?? '17:00',
      slotDuration: m['slot_duration'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() => {
        'hospital_id': hospitalId,
        'name': name,
        'specialty': specialty,
        'bio': bio,
        'consultation_fee': consultationFee,
        'photo_url': photoUrl,
        'rating': rating,
        'review_count': reviewCount,
        'available_days': availableDays.join(','),
        'start_time': startTime,
        'end_time': endTime,
        'slot_duration': slotDuration,
      };
}

// ─── APPOINTMENT MODEL ────────────────────────────────────────────────────────

enum AppointmentStatus { pending, approved, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:   return 'Pending';
      case AppointmentStatus.approved:  return 'Approved';
      case AppointmentStatus.completed: return 'Completed';
      case AppointmentStatus.cancelled: return 'Cancelled';
    }
  }
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String hospitalId;
  final String hospitalName;
  final DateTime date;
  final String timeSlot;
  final AppointmentStatus status;
  final String? notes;
  final List<String> documentUrls;
  final double consultationFee;
  final DateTime createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.hospitalId,
    required this.hospitalName,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.pending,
    this.notes,
    this.documentUrls = const [],
    required this.consultationFee,
    required this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> m) {
    List<String> parseDocs(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      if (raw.toString().isEmpty) return [];
      return raw.toString().split(',');
    }

    return AppointmentModel(
      id: m['id'].toString(),
      patientId: m['patient_id'].toString(),
      patientName: m['patient_name'] ?? '',
      doctorId: m['doctor_id'].toString(),
      doctorName: m['doctor_name'] ?? '',
      doctorSpecialty: m['doctor_specialty'] ?? '',
      hospitalId: m['hospital_id'].toString(),
      hospitalName: m['hospital_name'] ?? '',
      date: DateTime.parse(m['date']),
      timeSlot: m['time_slot'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == (m['status'] ?? 'pending'),
        orElse: () => AppointmentStatus.pending,
      ),
      notes: m['notes'],
      documentUrls: parseDocs(m['document_urls']),
      consultationFee: (m['consultation_fee'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
          m['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'patient_id': patientId,
        'patient_name': patientName,
        'doctor_id': doctorId,
        'doctor_name': doctorName,
        'doctor_specialty': doctorSpecialty,
        'hospital_id': hospitalId,
        'hospital_name': hospitalName,
        'date': date.toIso8601String(),
        'time_slot': timeSlot,
        'status': status.name,
        'notes': notes,
        'document_urls': documentUrls.join(','),
        'consultation_fee': consultationFee,
      };

  AppointmentModel copyWith({AppointmentStatus? status, String? notes}) =>
      AppointmentModel(
        id: id,
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        date: date,
        timeSlot: timeSlot,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        documentUrls: documentUrls,
        consultationFee: consultationFee,
        createdAt: createdAt,
      );
}

// ─── REVIEW MODEL ─────────────────────────────────────────────────────────────

class ReviewModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String hospitalId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.hospitalId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> m) => ReviewModel(
        id: m['id'].toString(),
        patientId: m['patient_id'].toString(),
        patientName: m['patient_name'] ?? '',
        doctorId: m['doctor_id'].toString(),
        hospitalId: m['hospital_id'].toString(),
        rating: (m['rating'] ?? 0.0).toDouble(),
        comment: m['comment'] ?? '',
        createdAt: DateTime.parse(
            m['created_at'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toMap() => {
        'patient_id': patientId,
        'patient_name': patientName,
        'doctor_id': doctorId,
        'hospital_id': hospitalId,
        'rating': rating,
        'comment': comment,
      };
}

// ─── MESSAGE MODEL ────────────────────────────────────────────────────────────

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> m) => MessageModel(
        id: m['id'].toString(),
        chatId: m['chat_id'].toString(),
        senderId: m['sender_id'].toString(),
        senderName: m['sender_name'] ?? '',
        text: m['text'] ?? '',
        timestamp: DateTime.parse(
            m['created_at'] ?? DateTime.now().toIso8601String()),
        isRead: m['is_read'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'chat_id': chatId,
        'sender_id': senderId,
        'sender_name': senderName,
        'text': text,
        'is_read': isRead,
      };
}

// ─── CHAT MODEL ───────────────────────────────────────────────────────────────

class ChatModel {
  final String id;
  final String user1Id;
  final String user1Name;
  final String user2Id;
  final String user2Name;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatModel({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatModel.fromMap(Map<String, dynamic> m) => ChatModel(
        id: m['id'].toString(),
        user1Id: m['user1_id'].toString(),
        user1Name: m['user1_name'] ?? '',
        user2Id: m['user2_id'].toString(),
        user2Name: m['user2_name'] ?? '',
        lastMessage: m['last_message'] ?? '',
        lastMessageTime: DateTime.parse(
            m['last_message_time'] ?? DateTime.now().toIso8601String()),
      );

  String otherUserName(String myId) =>
      myId == user1Id ? user2Name : user1Name;

  String otherUserId(String myId) =>
      myId == user1Id ? user2Id : user1Id;
}

// ─── NOTIFICATION MODEL ───────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? referenceId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.referenceId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> m) =>
      NotificationModel(
        id: m['id'].toString(),
        userId: m['user_id'].toString(),
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        type: m['type'] ?? 'system',
        isRead: m['is_read'] ?? false,
        createdAt: DateTime.parse(
            m['created_at'] ?? DateTime.now().toIso8601String()),
        referenceId: m['reference_id']?.toString(),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': isRead,
        'reference_id': referenceId,
      };
}
