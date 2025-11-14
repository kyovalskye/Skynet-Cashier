import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PanelUserCubit extends Cubit<ResultState> {
  final supabase = Supabase.instance.client;

  PanelUserCubit() : super(ResultState(status: 'loading'));

  Future<void> loadUserProfile() async {
    emit(ResultState(status: 'loading'));

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        emit(ResultState(status: 'error', message: 'User not logged in'));
        return;
      }

      // Load current user profile first
      final currentProfile = await supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .single();

      print('Current user role: ${currentProfile['role']}');

      // Jika admin, load semua profiles
      // Jika kasir, hanya tampilkan profile sendiri (tidak perlu query lagi)
      if (currentProfile['role'] == 'admin') {
        // Admin: Query semua profiles
        final allProfiles = await supabase
            .from('profiles')
            .select()
            .order('created_at', ascending: false);

        print('Total users loaded: ${allProfiles.length}');

        emit(
          ResultState(
            status: 'success',
            currentUser: currentProfile,
            allUsers: allProfiles,
            isAdmin: true,
          ),
        );
      } else {
        // Kasir: Hanya tampilkan profile sendiri, tidak query database lagi
        emit(
          ResultState(
            status: 'success',
            currentUser: currentProfile,
            allUsers: [currentProfile],
            isAdmin: false,
          ),
        );
      }
    } catch (e) {
      print('Error loading profile: $e');
      emit(ResultState(status: 'error', message: e.toString()));
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    emit(ResultState(status: 'logout'));
  }
}

// State class untuk handle multiple data
class ResultState {
  final String status; // loading, success, error, logout
  final Map<String, dynamic>? currentUser;
  final List<dynamic>? allUsers;
  final bool isAdmin;
  final String? message;

  ResultState({
    required this.status,
    this.currentUser,
    this.allUsers,
    this.isAdmin = false,
    this.message,
  });
}
