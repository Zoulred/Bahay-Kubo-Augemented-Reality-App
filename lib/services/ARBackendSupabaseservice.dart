import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://lhurfroforcsrcugbjcn.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodXJmcm9mb3Jjc3JjdWdiamNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0Mjk4NDIsImV4cCI6MjA3ODAwNTg0Mn0.C0M7Hwvdmnr5JA-8CgRXCQ9fDHkt4l-JzVZhbyNGlmU';

  final SupabaseClient client = Supabase.instance.client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  Future<AuthResponse> signUp(
      String email, String password, String fullName) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  bool get isLoggedIn => currentUser != null;
}
