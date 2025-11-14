import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<String> {
  final supabase = Supabase.instance.client;

  LoginCubit() : super('');

  Future<void> login(String email, String password) async {
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
        // Signup dengan user_metadata
        final res = await supabase.auth.signUp(
          email: u['email']!,
          password: u['password']!,
          data: {'nama': u['nama'], 'role': u['role']},
        );

        if (res.user != null) {
          print(
            'Signup success for ${u['email']} - Metadata: ${res.user!.userMetadata}',
          );
        }
      } catch (e) {
        print('Signup error for ${u['email']}: $e');
      }
    }
  }
}
