import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class SettingsState {
  final String? userRole;
  final bool isLoading;
  final String? errorMessage;

  SettingsState({this.userRole, this.isLoading = false, this.errorMessage});

  SettingsState copyWith({
    String? userRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final _supabase = SupabaseService();

  SettingsCubit() : super(SettingsState());

  Future<void> loadUserRole() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final currentUser = _supabase.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('user_id', currentUser.id)
          .single();

      final role = response['role'] as String;

      emit(state.copyWith(userRole: role, isLoading: false));
    } catch (e) {
      print('❌ Error loading user role: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat role pengguna: $e',
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.signOut();
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }
}
