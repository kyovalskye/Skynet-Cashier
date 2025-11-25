// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'supabase_service.dart';

// class AuthService {
//   final _client = SupabaseService().client;

//   Future<AuthResponse> login(String email, String password) async {
//     return await _client.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );
//   }

//   Future<AuthResponse> register(
//     String email,
//     String password, {
//     Map<String, dynamic>? metadata,
//   }) async {
//     return await _client.auth.signUp(
//       email: email, 
//       password: password,
//       data: metadata,
//     );
//   }

//   Future<void> logout() async {
//     await _client.auth.signOut();
//   }

//   User? get user => _client.auth.currentUser;
//   Session? get session => _client.auth.currentSession;
//   bool get isLoggedIn => session != null;

//   Stream<AuthState> get onAuthChange => _client.auth.onAuthStateChange;
// }
