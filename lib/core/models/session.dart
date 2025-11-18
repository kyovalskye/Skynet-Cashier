class SessionModel {
  final String id;
  final String seatNumber;
  final String customerName;
  final String duration;
  final String cost;
  final String startTime;
  final String endTime;
  final String remainingTime;
  final DateTime startDateTime;

  SessionModel({
    required this.id,
    required this.seatNumber,
    required this.customerName,
    required this.duration,
    required this.cost,
    required this.startTime,
    required this.endTime,
    required this.remainingTime,
    required this.startDateTime,
  });

  SessionModel copyWith({
    String? id,
    String? seatNumber,
    String? customerName,
    String? duration,
    String? cost,
    String? startTime,
    String? endTime,
    String? remainingTime,
    DateTime? startDateTime,
  }) {
    return SessionModel(
      id: id ?? this.id,
      seatNumber: seatNumber ?? this.seatNumber,
      customerName: customerName ?? this.customerName,
      duration: duration ?? this.duration,
      cost: cost ?? this.cost,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      remainingTime: remainingTime ?? this.remainingTime,
      startDateTime: startDateTime ?? this.startDateTime,
    );
  }

  // From JSON
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      seatNumber: json['seatNumber'] as String,
      customerName: json['customerName'] as String,
      duration: json['duration'] as String,
      cost: json['cost'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      remainingTime: json['remainingTime'] as String,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'customerName': customerName,
      'duration': duration,
      'cost': cost,
      'startTime': startTime,
      'endTime': endTime,
      'remainingTime': remainingTime,
      'startDateTime': startDateTime.toIso8601String(),
    };
  }
}
