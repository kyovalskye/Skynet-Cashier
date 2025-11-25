import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<String> {
  final supabase = Supabase.instance.client;

  LoginCubit() : super('');

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit('failed');
      return;
    }

    emit('loading');
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        print('Login success - User metadata: ${res.user!.userMetadata}');
        emit('success');
      } else {
        emit('failed');
      }
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      emit('failed');
    } catch (e) {
      print('Login error: $e');
      emit('failed');
    }
  }

  Future<void> signupIfNotExist() async {
    final users = [
      {
        'email': 'admin@skynet.com',
        'password': 'adminwarnet',
        'nama': 'Admin Warnet',
        'role': 'admin',
      },
      {
        'email': 'kasir1@skynet.com',
        'password': 'kasirwarnet',
        'nama': 'Kasir 1',
        'role': 'kasir',
      },
    ];

    for (final u in users) {
      try {
        // Cek apakah user sudah ada dengan mencoba sign in
        try {
          await supabase.auth.signInWithPassword(
            email: u['email']!,
            password: u['password']!,
          );
          print('User ${u['email']} sudah ada');
          // Sign out setelah cek
          await supabase.auth.signOut();
          continue;
        } on AuthException {
          // User belum ada, lanjut signup
        }

        // Signup user baru dengan user_metadata
        final res = await supabase.auth.signUp(
          email: u['email']!,
          password: u['password']!,
          data: {'nama': u['nama'], 'role': u['role']},
        );

        if (res.user != null) {
          print(
            'Signup success untuk ${u['email']} - Metadata: ${res.user!.userMetadata}',
          );
          // Sign out setelah signup
          await supabase.auth.signOut();
        }
      } on AuthException catch (e) {
        print('Auth error untuk ${u['email']}: ${e.message}');
      } catch (e) {
        print('Signup error untuk ${u['email']}: $e');
      }
    }
  }
}
