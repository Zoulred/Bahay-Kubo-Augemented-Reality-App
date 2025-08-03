import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final authResponse = await client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );

    if (authResponse.user != null) {
      await client.from('profiles').insert({
        'id': authResponse.user!.id,
        'email': email.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return authResponse;
  }

  static Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await client.from('profiles').select().eq('id', userId).single();
      return response;
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }
}
