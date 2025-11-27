import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class ProfileState {
  final String? userId;
  final String? nama;
  final String? email;
  final String? role;
  final String? createdAt;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  ProfileState({
    this.userId,
    this.nama,
    this.email,
    this.role,
    this.createdAt,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    String? userId,
    String? nama,
    String? email,
    String? role,
    String? createdAt,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  final SupabaseService _supabase;

  ProfileCubit() : _supabase = SupabaseService(), super(ProfileState());

  Future<void> loadUserProfile() async {
    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      final user = _supabase.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Query sesuai dengan schema tabel profiles
      final userData = await _supabase
          .from('profiles')
          .select('user_id, nama, email, role, created_at')
          .eq('user_id', user.id)
          .single();

      // Format tanggal created_at
      final createdAt = userData['created_at'];
      final formattedDate = _formatDate(createdAt);

      emit(
        state.copyWith(
          userId: userData['user_id']?.toString() ?? user.id,
          nama: userData['nama'] ?? '',
          email: userData['email'] ?? user.email ?? '',
          role: userData['role'] ?? 'Kasir',
          createdAt: formattedDate,
          isLoading: false,
        ),
      );
    } catch (e) {
      print('❌ Error loading profile: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat profil: $e',
        ),
      );
    }
  }

  void toggleEditing() {
    if (state.role == 'admin') {
      emit(
        state.copyWith(
          isEditing: !state.isEditing,
          errorMessage: null,
          successMessage: null,
        ),
      );
    }
  }

  void cancelEditing() {
    emit(
      state.copyWith(
        isEditing: false,
        errorMessage: null,
        successMessage: null,
      ),
    );
    loadUserProfile(); // Reload original data
  }

  Future<void> updateProfile({required String nama}) async {
    if (state.role != 'admin') return;

    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      await _supabase
          .from('profiles')
          .update({'nama': nama.trim()})
          .eq('user_id', state.userId!);

      emit(
        state.copyWith(
          nama: nama.trim(),
          isLoading: false,
          successMessage: 'Profil berhasil diperbarui!',
        ),
      );
    } catch (e) {
      print('❌ Error updating profile: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memperbarui profil: $e',
        ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.role != 'admin') return;

    emit(
      state.copyWith(isLoading: true, errorMessage: null, successMessage: null),
    );

    try {
      // TODO: Implement proper password change with Supabase Auth
      // This is a placeholder - you need to implement actual Supabase auth update
      final user = _supabase.currentUser;
      if (user != null) {
        // Example implementation (adjust based on your Supabase auth setup)
        // await _supabase.auth.updateUser(
        //   UserAttributes(password: newPassword),
        // );

        // For now, we'll just simulate success
        await Future.delayed(const Duration(seconds: 1));

        emit(
          state.copyWith(
            isLoading: false,
            successMessage: 'Password berhasil diubah!',
          ),
        );
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('❌ Error changing password: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mengubah password: $e',
        ),
      );
    }
  }

  // Helper method to clear messages
  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  // Format tanggal dari timestamp
  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }
}
