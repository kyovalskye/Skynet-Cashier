import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// State
class HomeState extends Equatable {
  final int activeSeatsVIP;
  final int activeSeatsRegular;
  final String todayIncome;
  final List<ChartData> last7DaysSales;
  final List<ChartData> monthlySales;
  final List<Transaction> transactions;
  final ChartSummary last7DaysSummary;
  final ChartSummary monthlySummary;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.activeSeatsVIP = 23,
    this.activeSeatsRegular = 2,
    this.todayIncome = 'Rp 50.000',
    this.last7DaysSales = const [],
    this.monthlySales = const [],
    this.transactions = const [],
    this.last7DaysSummary = const ChartSummary(
      total: 'Rp 56.000',
      sessions: 'Rp 56.000',
      product: 'Rp 56.000',
    ),
    this.monthlySummary = const ChartSummary(
      total: 'Rp 56.000',
      sessions: 'Rp 56.000',
      product: 'Rp 56.000',
    ),
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    int? activeSeatsVIP,
    int? activeSeatsRegular,
    String? todayIncome,
    List<ChartData>? last7DaysSales,
    List<ChartData>? monthlySales,
    List<Transaction>? transactions,
    ChartSummary? last7DaysSummary,
    ChartSummary? monthlySummary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      activeSeatsVIP: activeSeatsVIP ?? this.activeSeatsVIP,
      activeSeatsRegular: activeSeatsRegular ?? this.activeSeatsRegular,
      todayIncome: todayIncome ?? this.todayIncome,
      last7DaysSales: last7DaysSales ?? this.last7DaysSales,
      monthlySales: monthlySales ?? this.monthlySales,
      transactions: transactions ?? this.transactions,
      last7DaysSummary: last7DaysSummary ?? this.last7DaysSummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    activeSeatsVIP,
    activeSeatsRegular,
    todayIncome,
    last7DaysSales,
    monthlySales,
    transactions,
    last7DaysSummary,
    monthlySummary,
    isLoading,
    errorMessage,
  ];
}

// Models
class ChartData {
  final List<double> values;
  final String label;

  ChartData({required this.values, required this.label});
}

class ChartSummary {
  final String total;
  final String sessions;
  final String product;

  const ChartSummary({
    required this.total,
    required this.sessions,
    required this.product,
  });
}

class Transaction {
  final String invoiceNumber;
  final String dueDate;
  final String amount;

  Transaction({
    required this.invoiceNumber,
    required this.dueDate,
    required this.amount,
  });
}

// Cubit
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    loadInitialData();
  }

  void loadInitialData() {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate loading data - replace with actual API calls
      final last7Days = [
        ChartData(values: [80, 40], label: 'April'),
        ChartData(values: [60, 90], label: 'May'),
        ChartData(values: [50, 30], label: 'June'),
        ChartData(values: [40, 80], label: 'July'),
        ChartData(values: [90, 50], label: 'August'),
        ChartData(values: [70, 100], label: 'September'),
        ChartData(values: [60, 40], label: 'October'),
      ];

      final monthly = [
        ChartData(values: [80, 50], label: 'April'),
        ChartData(values: [40, 100], label: 'May'),
        ChartData(values: [70, 60], label: 'June'),
        ChartData(values: [90, 70], label: 'July'),
        ChartData(values: [60, 80], label: 'August'),
        ChartData(values: [80, 50], label: 'September'),
        ChartData(values: [50, 90], label: 'October'),
      ];

      final transactionsList = [
        Transaction(
          invoiceNumber: 'INV-A1B2C3D4',
          dueDate: 'Due date: Monday, 30 October 2025',
          amount: 'Rp 56.000',
        ),
        Transaction(
          invoiceNumber: 'INV-A1B2C3D4',
          dueDate: 'Due date: Monday, 30 October 2025',
          amount: 'Rp 56.000',
        ),
        Transaction(
          invoiceNumber: 'INV-A1B2C3D4',
          dueDate: 'Due date: Monday, 30 October 2025',
          amount: 'Rp 56.000',
        ),
        Transaction(
          invoiceNumber: 'INV-A1B2C3D4',
          dueDate: 'Due date: Monday, 30 October 2025',
          amount: 'Rp 56.000',
        ),
      ];

      emit(
        state.copyWith(
          last7DaysSales: last7Days,
          monthlySales: monthly,
          transactions: transactionsList,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load data: ${e.toString()}',
        ),
      );
    }
  }

  void refreshData() {
    loadInitialData();
  }

  void updateActiveSeats({int? vip, int? regular}) {
    emit(
      state.copyWith(
        activeSeatsVIP: vip ?? state.activeSeatsVIP,
        activeSeatsRegular: regular ?? state.activeSeatsRegular,
      ),
    );
  }

  void updateTodayIncome(String income) {
    emit(state.copyWith(todayIncome: income));
  }

  void addTransaction(Transaction transaction) {
    final updatedTransactions = [...state.transactions, transaction];
    emit(state.copyWith(transactions: updatedTransactions));
  }
}
