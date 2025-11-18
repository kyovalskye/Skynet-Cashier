import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/models/seat.dart';

class SeatCubit extends Cubit<List<Seat>> {
  SeatCubit()
    : super(
        List.generate(
          25,
          (i) => Seat(name: "Seat ${i + 1}", isOccupied: false),
        ),
      );

  void toggleSeat(int index) {
    final updated = List<Seat>.from(state);
    updated[index] = updated[index].copyWith(
      isOccupied: !updated[index].isOccupied,
    );
    emit(updated);
  }
}
