class CustomerItem {
  final String name;
  final int visits;

  CustomerItem({required this.name, required this.visits});

  // From JSON
  factory CustomerItem.fromJson(Map<String, dynamic> json) {
    return CustomerItem(name: json['name'] ?? '', visits: json['visits'] ?? 0);
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'visits': visits};
  }

  // CopyWith method for immutability
  CustomerItem copyWith({String? name, int? visits}) {
    return CustomerItem(name: name ?? this.name, visits: visits ?? this.visits);
  }

  @override
  String toString() {
    return 'CustomerItem(name: $name, visits: $visits)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerItem &&
        other.name == name &&
        other.visits == visits;
  }

  @override
  int get hashCode => name.hashCode ^ visits.hashCode;
}
