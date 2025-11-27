import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/appbar_cubit.dart';
import 'package:skynet_internet_cafe/presentation/logic/navbar_cubit.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppbarContent();
  }
}

class _AppbarContent extends StatelessWidget {
  const _AppbarContent();

  @override
  Widget build(BuildContext context) {
    // Ambil role user dari Supabase
    final supabase = SupabaseService();
    final userRole = supabase.currentUser?.userMetadata?['role'] ?? '';

    return BlocBuilder<AppbarCubit, AppbarState>(
      builder: (context, state) {
        return Row( 
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Panel
            // _AppbarItem(
            //   icon: Icons.person_outline,
            //   isActive: state.selectedIndex == 0,
            //   onTap: () {
            //     context.read<AppbarCubit>().navigateToIndex(0);
            //     context.read<NavbarCubit>().changeTab(-1);
            //     Navigator.pushReplacementNamed(context, '/userpanel');
            //   },
            // ),
            // const SizedBox(width: 12),

            // if (userRole == 'admin') ...[
            //   _AppbarItem(
            //     icon: Icons.people_outline,
            //     isActive: state.selectedIndex == 1,
            //     onTap: () {
            //       context.read<AppbarCubit>().navigateToIndex(1);
            //       context.read<NavbarCubit>().changeTab(-1);
            //       Navigator.pushReplacementNamed(context, '/user-management');
            //     },
            //   ),
            //   const SizedBox(width: 12),
            // ],

            // Reports
            _AppbarItem(
              icon: Icons.description_outlined,
              isActive: state.selectedIndex == 2,
              onTap: () {
                context.read<AppbarCubit>().navigateToIndex(2);
                context.read<NavbarCubit>().changeTab(-1);
                Navigator.pushReplacementNamed(context, '/reports');
              },
            ),
            const SizedBox(width: 12),

            // Settings
            _AppbarItem(
              icon: Icons.settings_outlined,
              isActive: state.selectedIndex == 3,
              onTap: () {
                context.read<AppbarCubit>().navigateToIndex(3);
                context.read<NavbarCubit>().changeTab(-1);
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
          ],
        );
      },
    );
  }
}

class _AppbarItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _AppbarItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue : Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
