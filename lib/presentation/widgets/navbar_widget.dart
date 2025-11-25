import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/navbar_cubit.dart';
import '../logic/appbar_cubit.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavbarCubit, int>(
      builder: (context, currentIndex) {
        // Jika di halaman AppBar, currentIndex = -1, semua icon jadi putih
        final isInAppbarPage = currentIndex == -1;

        return BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isInAppbarPage ? Colors.white : Colors.cyan,
          unselectedItemColor: Colors.white,
          // Jika -1, paksa ke 0 untuk avoid error, tapi visualnya tetap putih semua
          currentIndex: isInAppbarPage ? 0 : currentIndex,
          // Disable selection indicator ketika di AppBar page
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (i) {
            // Update NavBar state
            context.read<NavbarCubit>().changeTab(i);

            // Coba reset AppBar, tapi kalau error skip aja
            try {
              context.read<AppbarCubit>().navigateToIndex(-1);
            } catch (e) {
              // AppbarCubit mungkin belum tersedia, skip
            }

            // Navigasi ke halaman yang dipilih
            switch (i) {
              case 0:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/schedule');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/purchase');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/seat');
                break;
              case 4:
                Navigator.pushReplacementNamed(context, '/reports');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Purchase',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Seat'),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              label: 'Reports',
            ),
          ],
        );
      },
    );
  }
}
