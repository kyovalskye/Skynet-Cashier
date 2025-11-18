class Seat {
  final String name;
  final bool isOccupied;

  const Seat({required this.name, required this.isOccupied});

  Seat copyWith({String? name, bool? isOccupied}) {
    return Seat(
      name: name ?? this.name,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }
}
