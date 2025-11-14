import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String _supabaseUrl = 'https://aooagunulvslopiezhuk.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvb2FndW51bHZzbG9waWV6aHVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEwODQ2NDAsImV4cCI6MjA3NjY2MDY0MH0.EXKy9BQv6w6xBJ5oNJuh4bsUQk5lumA3mfQy7xm9tmo';

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    print('✅ Supabase initialized successfully');
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('❌ SignIn error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      print('❌ SignUp error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ SignOut error: $e');
      rethrow;
    }
  }

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
  bool get isAuthenticated => currentSession != null;

  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
