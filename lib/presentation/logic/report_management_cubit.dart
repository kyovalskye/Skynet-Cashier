import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// State
class ReportManagementState extends Equatable {
  final bool isLoading;
  final String selectedFilter;
  final String totalIncome;
  final int totalTransactions;
  final String sessionIncome;
  final String productIncome;
  final List<Map<String, dynamic>> frequentProducts;
  final List<Map<String, dynamic>> frequentCustomers;
  final String? errorMessage;

  const ReportManagementState({
    this.isLoading = false,
    this.selectedFilter = 'Today',
    this.totalIncome = '40.000',
    this.totalTransactions = 10,
    this.sessionIncome = '25.000',
    this.productIncome = '15.000',
    this.frequentProducts = const [],
    this.frequentCustomers = const [],
    this.errorMessage,
  });

  ReportManagementState copyWith({
    bool? isLoading,
    String? selectedFilter,
    String? totalIncome,
    int? totalTransactions,
    String? sessionIncome,
    String? productIncome,
    List<Map<String, dynamic>>? frequentProducts,
    List<Map<String, dynamic>>? frequentCustomers,
    String? errorMessage,
  }) {
    return ReportManagementState(
      isLoading: isLoading ?? this.isLoading,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      totalIncome: totalIncome ?? this.totalIncome,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      sessionIncome: sessionIncome ?? this.sessionIncome,
      productIncome: productIncome ?? this.productIncome,
      frequentProducts: frequentProducts ?? this.frequentProducts,
      frequentCustomers: frequentCustomers ?? this.frequentCustomers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    selectedFilter,
    totalIncome,
    totalTransactions,
    sessionIncome,
    productIncome,
    frequentProducts,
    frequentCustomers,
    errorMessage,
  ];
}

// Cubit
class ReportManagementCubit extends Cubit<ReportManagementState> {
  ReportManagementCubit() : super(const ReportManagementState());

  // Load initial report data
  Future<void> loadReportData() async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - replace with actual API call
      final List<Map<String, dynamic>> products = [
        {
          'name': 'Mie Sedaap',
          'type': 'Type: Snacks',
          'sold': 'Terjual: 14 Product',
        },
        {
          'name': 'Mie Sedaap',
          'type': 'Type: Snacks',
          'sold': 'Terjual: 14 Product',
        },
        {
          'name': 'Mie Sedaap',
          'type': 'Type: Snacks',
          'sold': 'Terjual: 14 Product',
        },
      ];

      final List<Map<String, dynamic>> customers = [
        {'name': 'Hambali Pudding', 'visits': 'Visit: 8 Times'},
        {'name': 'Hambali Pudding', 'visits': 'Visit: 8 Times'},
        {'name': 'Hambali Pudding', 'visits': 'Visit: 8 Times'},
      ];

      emit(
        state.copyWith(
          isLoading: false,
          frequentProducts: products,
          frequentCustomers: customers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load report data: ${e.toString()}',
        ),
      );
    }
  }

  // Set filter (Today, This week, This month)
  void setFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
    _fetchDataForFilter(filter);
  }

  // Fetch data based on selected filter
  Future<void> _fetchDataForFilter(String filter) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate API call with different data based on filter
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock data based on filter - replace with actual API call
      Map<String, dynamic> data;

      switch (filter) {
        case 'Today':
          data = {
            'totalIncome': '40.000',
            'totalTransactions': 10,
            'sessionIncome': '25.000',
            'productIncome': '15.000',
          };
          break;
        case 'This week':
          data = {
            'totalIncome': '280.000',
            'totalTransactions': 65,
            'sessionIncome': '175.000',
            'productIncome': '105.000',
          };
          break;
        case 'This month':
          data = {
            'totalIncome': '1.200.000',
            'totalTransactions': 280,
            'sessionIncome': '750.000',
            'productIncome': '450.000',
          };
          break;
        default:
          data = {
            'totalIncome': '40.000',
            'totalTransactions': 10,
            'sessionIncome': '25.000',
            'productIncome': '15.000',
          };
      }

      emit(
        state.copyWith(
          isLoading: false,
          totalIncome: data['totalIncome'] as String,
          totalTransactions: data['totalTransactions'] as int,
          sessionIncome: data['sessionIncome'] as String,
          productIncome: data['productIncome'] as String,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to fetch data: ${e.toString()}',
        ),
      );
    }
  }

  // Refresh report data
  Future<void> refreshData() async {
    await loadReportData();
  }

  // Export report
  Future<void> exportReport() async {
    try {
      // Implement export logic here
      // For example: generate PDF, CSV, etc.
      await Future.delayed(const Duration(seconds: 1));

      // Show success message or handle export
      print('Report exported successfully');
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to export report: ${e.toString()}',
        ),
      );
    }
  }

  // Filter products by category
  void filterProductsByCategory(String category) {
    emit(state.copyWith(isLoading: true));

    // Implement filtering logic
    // This would typically involve an API call or local filtering

    emit(state.copyWith(isLoading: false));
  }

  // Clear error message
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
