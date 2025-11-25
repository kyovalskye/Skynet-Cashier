import 'customer_item.dart';

class ReportData {
  final String selectedPeriod;
  final double totalIncome;
  final int totalTransactions;
  final double sessionIncome;
  final List<CustomerItem> frequentCustomers;

  ReportData({
    required this.selectedPeriod,
    required this.totalIncome,
    required this.totalTransactions,
    required this.sessionIncome,
    required this.frequentCustomers,
  });

  // From JSON
  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      selectedPeriod: json['selectedPeriod'] ?? 'Today',
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      sessionIncome: (json['sessionIncome'] ?? 0).toDouble(),
      frequentCustomers:
          (json['frequentCustomers'] as List<dynamic>?)
              ?.map((item) => CustomerItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedPeriod': selectedPeriod,
      'totalIncome': totalIncome,
      'totalTransactions': totalTransactions,
      'sessionIncome': sessionIncome,
      'frequentCustomers': frequentCustomers
          .map((item) => item.toJson())
          .toList(),
    };
  }

  // CopyWith method for immutability
  ReportData copyWith({
    String? selectedPeriod,
    double? totalIncome,
    int? totalTransactions,
    double? sessionIncome,
    List<CustomerItem>? frequentCustomers,
  }) {
    return ReportData(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      totalIncome: totalIncome ?? this.totalIncome,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      sessionIncome: sessionIncome ?? this.sessionIncome,
      frequentCustomers: frequentCustomers ?? this.frequentCustomers,
    );
  }

  @override
  String toString() {
    return 'ReportData(selectedPeriod: $selectedPeriod, totalIncome: $totalIncome, totalTransactions: $totalTransactions, sessionIncome: $sessionIncome, frequentCustomers: $frequentCustomers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportData &&
        other.selectedPeriod == selectedPeriod &&
        other.totalIncome == totalIncome &&
        other.totalTransactions == totalTransactions &&
        other.sessionIncome == sessionIncome;
  }

  @override
  int get hashCode {
    return selectedPeriod.hashCode ^
        totalIncome.hashCode ^
        totalTransactions.hashCode ^
        sessionIncome.hashCode;
  }
}
