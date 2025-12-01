import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

// States
abstract class CustomerManagementState {}

class CustomerManagementInitial extends CustomerManagementState {}

class CustomerManagementLoading extends CustomerManagementState {}

class CustomerManagementLoaded extends CustomerManagementState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;

  CustomerManagementLoaded({
    required this.customers,
    required this.filteredCustomers,
  });
}

class CustomerManagementError extends CustomerManagementState {
  final String message;

  CustomerManagementError(this.message);
}

// Model
class Customer {
  final String id;
  final String nama;
  final String? noTelp;
  final String? email;
  final DateTime createdAt;
  final double totalSpent;
  final int visitCount;

  Customer({
    required this.id,
    required this.nama,
    this.noTelp,
    this.email,
    required this.createdAt,
    this.totalSpent = 0,
    this.visitCount = 0,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      nama: json['nama'],
      noTelp: json['no_telp'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      visitCount: json['visit_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'no_telp': noTelp, 'email': email};
  }
}

// Cubit
class CustomerManagementCubit extends Cubit<CustomerManagementState> {
  final SupabaseService _supabaseService;
  List<Customer> _allCustomers = [];

  CustomerManagementCubit(this._supabaseService)
    : super(CustomerManagementInitial());

  Future<void> loadCustomers() async {
    try {
      emit(CustomerManagementLoading());

      // Query dengan JOIN untuk mendapatkan total spent dan visit count
      final response = await _supabaseService
          .from('customer')
          .select('''
            *,
            total_spent:transaksi(total).sum(),
            visit_count:transaksi(kode_transaksi).count()
          ''')
          .order('created_at', ascending: false);

      _allCustomers = (response as List).map((json) {
        // Parse aggregated data
        final totalSpent = json['total_spent'] ?? 0;
        final visitCount = json['visit_count'] ?? 0;

        return Customer(
          id: json['id'],
          nama: json['nama'],
          noTelp: json['no_telp'],
          email: json['email'],
          createdAt: DateTime.parse(json['created_at']),
          totalSpent: totalSpent is num ? totalSpent.toDouble() : 0.0,
          visitCount: visitCount is int ? visitCount : 0,
        );
      }).toList();

      emit(
        CustomerManagementLoaded(
          customers: _allCustomers,
          filteredCustomers: _allCustomers,
        ),
      );
    } catch (e) {
      emit(CustomerManagementError('Gagal memuat data customer: $e'));
    }
  }

  void searchCustomers(String query) {
    if (state is CustomerManagementLoaded) {
      final currentState = state as CustomerManagementLoaded;

      if (query.isEmpty) {
        emit(
          CustomerManagementLoaded(
            customers: currentState.customers,
            filteredCustomers: currentState.customers,
          ),
        );
        return;
      }

      final filtered = currentState.customers.where((customer) {
        return customer.nama.toLowerCase().contains(query.toLowerCase()) ||
            (customer.noTelp?.contains(query) ?? false) ||
            (customer.email?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();

      emit(
        CustomerManagementLoaded(
          customers: currentState.customers,
          filteredCustomers: filtered,
        ),
      );
    }
  }

  Future<bool> addCustomer({
    required String nama,
    String? noTelp,
    String? email,
  }) async {
    try {
      await _supabaseService.from('customer').insert({
        'nama': nama,
        'no_telp': noTelp,
        'email': email,
      });

      await loadCustomers();
      return true;
    } catch (e) {
      emit(CustomerManagementError('Gagal menambahkan customer: $e'));
      return false;
    }
  }

  Future<bool> updateCustomer({
    required String id,
    required String nama,
    String? noTelp,
    String? email,
  }) async {
    try {
      await _supabaseService
          .from('customer')
          .update({'nama': nama, 'no_telp': noTelp, 'email': email})
          .eq('id', id);

      await loadCustomers();
      return true;
    } catch (e) {
      emit(CustomerManagementError('Gagal mengupdate customer: $e'));
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _supabaseService.from('customer').delete().eq('id', id);

      await loadCustomers();
      return true;
    } catch (e) {
      emit(CustomerManagementError('Gagal menghapus customer: $e'));
      return false;
    }
  }
}
