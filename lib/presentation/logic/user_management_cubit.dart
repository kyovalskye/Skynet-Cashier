import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class UserManagementState {
  final List<Map<String, dynamic>> users;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  UserManagementState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  UserManagementState copyWith({
    List<Map<String, dynamic>>? users,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class UserManagementCubit extends Cubit<UserManagementState> {
  final _supabase = SupabaseService();

  UserManagementCubit() : super(UserManagementState());

  Future<void> loadUsers() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await _supabase
          .from('profiles')
          .select('user_id, email, nama, role, created_at')
          .order('created_at', ascending: false);

      final users = List<Map<String, dynamic>>.from(response as List);

      emit(state.copyWith(users: users, isLoading: false));
    } catch (e) {
      print('❌ Error loading users: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load users: $e',
        ),
      );    
    }
  }

  // Register user baru
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // 1. Sign up user menggunakan Supabase Auth
      final authResponse = await _supabase.signUp(
        email: email,
        password: password,
        metadata: {'nama': fullName, 'role': role},
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // 2. Insert ke tabel profiles
      await _supabase.from('profiles').upsert({
        'user_id': authResponse.user!.id,
        'email': email,
        'nama': fullName,
        'role': role,
      });

      // 3. Reload users
      await loadUsers();

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'User $fullName berhasil ditambahkan',
        ),
      );
    } catch (e) {
      print('❌ Error registering user: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal menambahkan user: $e',
        ),
      );
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Hapus dari tabel profiles
      await _supabase.from('profiles').delete().eq('user_id', userId);

      // Reload users
      await loadUsers();

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'User berhasil dihapus',
        ),
      );
    } catch (e) {
      print('❌ Error deleting user: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal menghapus user: $e',
        ),
      );
    }
  }
}
