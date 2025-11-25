import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/models/seat.dart';
import 'package:skynet_internet_cafe/presentation/logic/seat_cubit.dart';
import 'package:skynet_internet_cafe/presentation/widgets/appbar_widget.dart';
import 'package:skynet_internet_cafe/presentation/widgets/navbar_widget.dart';

class SeatManagementPage extends StatelessWidget {
  const SeatManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SeatCubit(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          toolbarHeight: 70,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seat Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage your seat',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          actions: const [AppbarWidget(), SizedBox(width: 8)],
        ),
        backgroundColor: Colors.black,
        bottomNavigationBar: NavbarWidget(),
        body: SafeArea(
          child: BlocBuilder<SeatCubit, List<Seat>>(
            builder: (context, seats) {
              final total = seats.length;
              final occupied = seats.where((e) => e.isOccupied).length;
              final available = total - occupied;

              return Column(
                children: [
                  // ==== HEADER ====
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _stat("Total", total.toString(), Colors.white),
                        _stat("Occupied", occupied.toString(), Colors.blue),
                        _stat("Available", available.toString(), Colors.green),
                      ],
                    ),
                  ),

                  // ==== GRID ====
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: seats.length,
                      itemBuilder: (context, i) {
                        final seat = seats[i];
                        return _SeatCard(
                          seatName: seat.name,
                          status: seat.isOccupied ? "Occupied" : "Available",
                          onTap: () => context.read<SeatCubit>().toggleSeat(i),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _stat(String name, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, color: color)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _SeatCard extends StatelessWidget {
  final String seatName;
  final String status;
  final VoidCallback onTap;

  const _SeatCard({
    required this.seatName,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final occupied = status == "Occupied";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff111418),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff2A2F36), width: 1.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xff1E2227),
              child: Icon(Icons.computer, size: 26, color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              seatName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: occupied ? Colors.red : const Color(0xff0CA6E9),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
