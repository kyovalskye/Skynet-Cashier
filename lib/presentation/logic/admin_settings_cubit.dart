import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class AdminSettingsState {
  final Map<String, dynamic>? settings;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  AdminSettingsState({
    this.settings,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AdminSettingsState copyWith({
    Map<String, dynamic>? settings,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return AdminSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AdminSettingsCubit extends Cubit<AdminSettingsState> {
  final _supabase = SupabaseService();

  AdminSettingsCubit() : super(AdminSettingsState());

  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final response = await _supabase
          .from('settings')
          .select(
            'id, nama_warnet, harga_per_jam_default, auto_logout, notifikasi_5menit, updated_at',
          )
          .limit(1)
          .single();

      emit(state.copyWith(settings: response, isLoading: false));
    } catch (e) {
      print('❌ Error loading settings: $e');

      // Jika tidak ada settings, buat default
      try {
        await _createDefaultSettings();
      } catch (createError) {
        print('❌ Error creating default settings: $createError');
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Gagal memuat pengaturan: $e',
          ),
        );
      }
    }
  }

  Future<void> _createDefaultSettings() async {
    final currentUser = _supabase.currentUser;

    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    await _supabase.from('settings').insert({
      'nama_warnet': 'SkyNet Warnet',
      'harga_per_jam_default': 5000,
      'auto_logout': true,
      'notifikasi_5menit': true,
      'updated_by': currentUser.id,
    });

    // Load settings setelah dibuat
    await loadSettings();
  }

  Future<void> updateSettings({
    String? namaWarnet,
    double? hargaPerJam,
    bool? autoLogout,
    bool? notifikasi5Menit,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final currentUser = _supabase.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (state.settings == null) {
        throw Exception('No settings loaded');
      }

      final updateData = <String, dynamic>{
        'updated_by': currentUser.id,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (namaWarnet != null) updateData['nama_warnet'] = namaWarnet;
      if (hargaPerJam != null) {
        updateData['harga_per_jam_default'] = hargaPerJam;
      }
      if (autoLogout != null) updateData['auto_logout'] = autoLogout;
      if (notifikasi5Menit != null) {
        updateData['notifikasi_5menit'] = notifikasi5Menit;
      }

      await _supabase
          .from('settings')
          .update(updateData)
          .eq('id', state.settings!['id']);

      await loadSettings();

      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Pengaturan berhasil diperbarui',
        ),
      );
    } catch (e) {
      print('❌ Error updating settings: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memperbarui pengaturan: $e',
        ),
      );
    }
  }
}
