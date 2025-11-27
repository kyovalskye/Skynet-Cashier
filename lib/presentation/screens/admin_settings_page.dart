import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/admin_settings_cubit.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminSettingsCubit()..loadSettings(),
      child: const AdminSettingsView(),
    );
  }
}

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Warnet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AdminSettingsCubit, AdminSettingsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF00C853),
              ),
            );
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFD50000),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.settings == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
            );
          }

          if (state.settings == null) {
            return const Center(
              child: Text(
                'Tidak ada pengaturan',
                style: TextStyle(color: Color(0xFF8A8D93)),
              ),
            );
          }

          final settings = state.settings!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Manage your settings',
                  style: TextStyle(color: Color(0xFF8A8D93), fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pengaturan Warnet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Warnet
                _buildSettingCard(
                  title: 'Nama Warnet',
                  child: TextField(
                    controller: TextEditingController(
                      text: settings['nama_warnet'],
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan nama warnet',
                      hintStyle: TextStyle(color: Color(0xFF8A8D93)),
                    ),
                    onSubmitted: (value) {
                      context.read<AdminSettingsCubit>().updateSettings(
                        namaWarnet: value,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Harga Per Jam
                _buildSettingCard(
                  title: 'Harga Per Jam (Default)',
                  child: TextField(
                    controller: TextEditingController(
                      text: settings['harga_per_jam_default'].toString(),
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan harga per jam',
                      hintStyle: TextStyle(color: Color(0xFF8A8D93)),
                      suffixText: 'IDR',
                      suffixStyle: TextStyle(color: Color(0xFF8A8D93)),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) {
                      final price = double.tryParse(value);
                      if (price != null) {
                        context.read<AdminSettingsCubit>().updateSettings(
                          hargaPerJam: price,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Pengaturan Sistem
                _buildSettingCard(
                  title: 'Pengaturan Sistem',
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        title: 'Auto Logout',
                        subtitle: 'Logout otomatis setelah waktu habis',
                        value: settings['auto_logout'] ?? true,
                        onChanged: (value) {
                          context.read<AdminSettingsCubit>().updateSettings(
                            autoLogout: value,
                          );
                        },
                      ),
                      const Divider(color: Color(0xFF2A2A2A), height: 24),
                      _buildSwitchTile(
                        title: 'Notifikasi 5 Menit',
                        subtitle: 'Beri notifikasi 5 menit sebelum waktu habis',
                        value: settings['notifikasi_5menit'] ?? true,
                        onChanged: (value) {
                          context.read<AdminSettingsCubit>().updateSettings(
                            notifikasi5Menit: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info Terakhir Update
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Color(0xFF00BCD4),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Terakhir diupdate: ${_formatDate(settings['updated_at'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A8D93),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF8A8D93), fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: const Color(0xFF00C853),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString.toString());
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString.toString();
    }
  }
}
