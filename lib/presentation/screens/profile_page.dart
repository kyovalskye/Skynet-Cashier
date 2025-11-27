import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';
import 'package:skynet_internet_cafe/presentation/logic/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadUserProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profiles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: const Color(0xFF00C853),
              ),
            );
            // Clear success message after showing
            Future.delayed(const Duration(milliseconds: 100), () {
              context.read<ProfileCubit>().clearMessages();
            });
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFD50000),
              ),
            );
            // Clear error message after showing
            Future.delayed(const Duration(milliseconds: 100), () {
              context.read<ProfileCubit>().clearMessages();
            });
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.userId == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                // const Text(
                //   'User information',
                //   style: TextStyle(color: Color(0xFF8A8D93), fontSize: 14),
                // ),
                // const SizedBox(height: 8),
                // const Text(
                //   'Profil Saya',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 24,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
                // const SizedBox(height: 32),

                // User Info Card
                _buildUserInfoCard(context, state),
                const SizedBox(height: 24),

                // Action Buttons (Hanya untuk Admin)
                if (state.role == 'admin') _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, ProfileState state) {
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
          // Role Badge
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //   decoration: BoxDecoration(
          //     color: state.role == 'admin'
          //         ? const Color(0xFF00C853).withOpacity(0.2)
          //         : const Color(0xFF00BCD4).withOpacity(0.2),
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(
          //       color: state.role == 'admin'
          //           ? const Color(0xFF00C853)
          //           : const Color(0xFF00BCD4),
          //     ),
          //   ),
          //   child: Text(
          //     state.role?.toUpperCase() ?? 'USER',
          //     style: TextStyle(
          //       color: state.role == 'admin'
          //           ? const Color(0xFF00C853)
          //           : const Color(0xFF00BCD4),
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 20),

          // User ID
          _buildInfoRow(
            context: context,
            icon: Icons.badge_outlined,
            label: 'User ID',
            value: state.userId ?? '-',
            copyable: true,
          ),
          const SizedBox(height: 16),

          // Nama (Editable untuk Admin)
          state.isEditing && state.role == 'admin'
              ? _buildEditableNameField(context, state)
              : _buildInfoRow(
                  context: context,
                  icon: Icons.person_outline,
                  label: 'Username',
                  value: state.nama ?? '-',
                ),
          const SizedBox(height: 16),

          // Email
          _buildInfoRow(
            context: context,
            icon: Icons.email_outlined,
            label: 'Email',
            value: state.email ?? '-',
          ),
          const SizedBox(height: 16),

          // Role
          _buildInfoRow(
            context: context,
            icon: Icons.work_outline,
            label: 'Role',
            value: state.role?.toUpperCase() ?? '-',
          ),
          const SizedBox(height: 16),

          // Created At (Tanggal Bergabung)
          _buildInfoRow(
            context: context,
            icon: Icons.calendar_today_outlined,
            label: 'Joined in',
            value: state.createdAt ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF8A8D93), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF8A8D93), fontSize: 14),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (copyable && value != '-')
                    IconButton(
                      onPressed: () {
                        // TODO: Implement copy to clipboard
                        // For now, just show a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User ID disalin ke clipboard'),
                            backgroundColor: Color(0xFF00C853),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.content_copy,
                        color: Color(0xFF8A8D93),
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableNameField(BuildContext context, ProfileState state) {
    final nameController = TextEditingController(text: state.nama);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Lengkap',
          style: TextStyle(color: Color(0xFF8A8D93), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.person_outline,
                  color: Color(0xFF8A8D93),
                  size: 20,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    hintText: 'Masukkan nama lengkap',
                    hintStyle: TextStyle(color: Color(0xFF8A8D93)),
                  ),
                  onChanged: (value) {
                    // Update name in real-time
                    context.read<ProfileCubit>().updateProfile(nama: value);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileState state) {
    return Column(
      children: [
        // Edit Profile Button (Hanya untuk Admin)
        if (!state.isEditing)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ProfileCubit>().toggleEditing();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Edit Profil',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<ProfileCubit>().cancelEditing();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF8A8D93)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF8A8D93),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<ProfileCubit>().toggleEditing();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil disimpan!'),
                        backgroundColor: Color(0xFF00C853),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 16),

        // Change Password Button (Hanya untuk Admin)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showChangePasswordDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF9800),
              side: const BorderSide(color: Color(0xFFFF9800)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Change Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: currentPasswordController,
                      label: 'Password Lama',
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: newPasswordController,
                      label: 'Password Baru',
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'Konfirmasi Password',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8A8D93),
                        side: const BorderSide(color: Color(0xFF8A8D93)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password baru tidak cocok!'),
                                backgroundColor: Color(0xFFD50000),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context);
                          await context.read<ProfileCubit>().changePassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ubah',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A8D93), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label harus diisi';
              }
              if (label.contains('Baru') && value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
