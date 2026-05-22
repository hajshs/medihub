import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AuthService {
  final _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Register ──────────────────────────────────────────────────────────────

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = 'patient',
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (res.user == null) throw Exception('Registration failed.');

    final user = UserModel(
      id: res.user!.id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    await _client.from('users').insert(user.toMap());

    return user;
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) throw Exception('Login failed.');

    return await _fetchUserData(res.user!.id);
  }

  // ── Get current user data ─────────────────────────────────────────────────

  Future<UserModel?> getCurrentUserData() async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      return await _fetchUserData(uid);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> _fetchUserData(String uid) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', uid)
        .single();
    return UserModel.fromMap(data);
  }

  // ── Update profile ────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photo_url'] = photoUrl;

    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', uid);
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Error message helper ──────────────────────────────────────────────────

  String getErrorMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('already registered')) return 'This email is already registered.';
    if (msg.contains('invalid login')) return 'Incorrect email or password.';
    if (msg.contains('email not confirmed')) return 'Please confirm your email first.';
    if (msg.contains('weak')) return 'Password must be at least 6 characters.';
    if (msg.contains('network')) return 'Network error. Check your connection.';
    return 'An error occurred. Please try again.';
  }
}
