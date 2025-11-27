import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class ProfileState {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? role;
  final bool isLoading;
  final bool isEditing;
  final String? errorMessage;
  final String? successMessage;

  ProfileState({
    this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.isLoading = false,
    this.isEditing = false,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    bool? isLoading,
    bool? isEditing,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  final _supabase = SupabaseService();

  ProfileCubit() : super(ProfileState());

  Future<void> loadUserProfile() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final user = _supabase.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userData = await _supabase
          .from('profiles')
          .select('nama, role, phone')
          .eq('user_id', user.id)
          .single();

      emit(
        state.copyWith(
          userId: user.id,
          fullName: userData['nama'] ?? '',
          email: user.email ?? '',
          phone: userData['phone'] ?? '',
          role: userData['role'],
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
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void cancelEditing() {
    emit(state.copyWith(isEditing: false));
    loadUserProfile();
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      await _supabase
          .from('profiles')
          .update({'nama': fullName.trim(), 'phone': phone.trim()})
          .eq('user_id', state.userId!);

      emit(
        state.copyWith(
          fullName: fullName.trim(),
          phone: phone.trim(),
          isEditing: false,
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
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // TODO: Implement password change dengan Supabase
      // await _supabase.updatePassword(newPassword);

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Password berhasil diubah!',
        ),
      );
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
}
