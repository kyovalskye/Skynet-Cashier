import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/panel_user_cubit.dart';
import 'package:skynet_internet_cafe/presentation/screens/login_page.dart';

class PanelUserPage extends StatelessWidget {
  const PanelUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PanelUserCubit()..loadUserProfile(),
      child: BlocConsumer<PanelUserCubit, ResultState>(
        listener: (context, state) {
          if (state.status == 'logout') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          } else if (state.status == 'error') {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.isAdmin ? 'Admin Panel' : 'Profile User'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<PanelUserCubit>().logout();
                  },
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ResultState state) {
    if (state.status == 'loading') {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == 'error') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message ?? 'Terjadi kesalahan'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PanelUserCubit>().loadUserProfile();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Success state
    if (state.isAdmin) {
      return _buildAdminView(state);
    } else {
      return _buildKasirView(state);
    }
  }

  // Tampilan untuk Admin (lihat semua user)
  Widget _buildAdminView(ResultState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current User Info
          const Text(
            'Logged in as:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildUserCard(state.currentUser!, isCurrentUser: true),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // All Users List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Semua User:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${state.allUsers?.length ?? 0} users',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: state.allUsers?.length ?? 0,
              itemBuilder: (context, index) {
                final user = state.allUsers![index];
                final isCurrent =
                    user['user_id'] == state.currentUser!['user_id'];
                return _buildUserCard(user, isCurrentUser: isCurrent);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan untuk Kasir (hanya lihat dirinya sendiri)
  Widget _buildKasirView(ResultState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Anda:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildUserCard(state.currentUser!, isCurrentUser: true),
        ],
      ),
    );
  }

  // Card untuk menampilkan user info
  Widget _buildUserCard(
    Map<String, dynamic> user, {
    bool isCurrentUser = false,
  }) {
    return Card(
      elevation: isCurrentUser ? 6 : 2,
      color: isCurrentUser ? Colors.blue.shade50 : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isCurrentUser) const SizedBox(height: 12),

            _buildInfoRow('User ID', user['user_id'] ?? '-'),
            const Divider(height: 24),
            _buildInfoRow('Nama', user['nama'] ?? '-'),
            const Divider(height: 24),
            _buildInfoRow('Email', user['email'] ?? '-'),
            const Divider(height: 24),
            _buildInfoRow(
              'Role',
              user['role'] ?? '-',
              valueColor: user['role'] == 'admin' ? Colors.red : Colors.green,
            ),
            const Divider(height: 24),
            _buildInfoRow('Created At', user['created_at'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 14, color: valueColor)),
        ),
      ],
    );
  }
}
