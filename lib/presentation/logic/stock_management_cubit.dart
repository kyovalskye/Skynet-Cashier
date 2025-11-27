import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';

// Model Product
class Product {
  final String id;
  final String name;
  final String category;
  final int stock;
  final int price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['produktid'].toString(),
      name: json['namaproduk'] ?? '',
      category: json['kategori'] ?? 'Uncategorized',
      stock: json['stok'] ?? 0,
      price: json['harga'] ?? 0,
      imageUrl: json['gambar_url'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    int? stock,
    int? price,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// States
abstract class StockManagementState {}

class StockManagementInitial extends StockManagementState {}

class StockManagementLoading extends StockManagementState {}

class StockManagementLoaded extends StockManagementState {
  final List<Product> products;
  final String userRole;

  StockManagementLoaded(this.products, this.userRole);
}

class StockManagementError extends StockManagementState {
  final String message;

  StockManagementError(this.message);
}

// Cubit
class StockManagementCubit extends Cubit<StockManagementState> {
  StockManagementCubit() : super(StockManagementInitial());

  final _supabase = SupabaseService();
  List<Product> _allProducts = [];
  String _userRole = 'kasir'; // default

  Future<void> loadProducts() async {
    emit(StockManagementLoading());

    try {
      // Get user role from profiles table
      final user = _supabase.currentUser;
      if (user != null) {
        try {
          final userData = await _supabase
              .from('profiles')
              .select('role')
              .eq('user_id', user.id)
              .single();
          _userRole = userData['role'] ?? 'kasir';
          print('✅ User role: $_userRole');
        } catch (e) {
          print('⚠️ Could not fetch user role, defaulting to kasir: $e');
          _userRole = 'kasir';
        }
      }

      // Fetch products from Supabase (table: produk)
      final response = await _supabase
          .from('produk')
          .select()
          .order('namaproduk', ascending: true);

      _allProducts = (response as List)
          .map((json) => Product.fromJson(json))
          .toList();

      print('✅ Loaded ${_allProducts.length} products');
      emit(StockManagementLoaded(_allProducts, _userRole));
    } catch (e) {
      print('❌ Error loading products: $e');
      emit(StockManagementError('Gagal memuat produk: ${e.toString()}'));
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    // Check if user is admin
    if (_userRole != 'admin') {
      emit(StockManagementError('Hanya admin yang dapat mengubah stok'));
      return;
    }

    try {
      // Update stock in Supabase (table: produk, column: stok)
      await _supabase
          .from('produk')
          .update({'stok': newStock})
          .eq('produktid', productId);

      // Update local data
      final index = _allProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _allProducts[index] = _allProducts[index].copyWith(stock: newStock);
        emit(StockManagementLoaded(List.from(_allProducts), _userRole));
      }

      print('✅ Stock updated successfully for product $productId');
    } catch (e) {
      print('❌ Error updating stock: $e');
      emit(StockManagementError('Gagal memperbarui stok: ${e.toString()}'));
      // Reload to restore previous state
      loadProducts();
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      emit(StockManagementLoaded(_allProducts, _userRole));
      return;
    }

    final filtered = _allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(StockManagementLoaded(filtered, _userRole));
  }

  void filterByStockStatus(String status) {
    List<Product> filtered;

    switch (status.toLowerCase()) {
      case 'out':
      case 'habis':
        filtered = _allProducts.where((p) => p.stock == 0).toList();
        break;
      case 'low':
      case 'menipis':
        filtered = _allProducts
            .where((p) => p.stock > 0 && p.stock < 10)
            .toList();
        break;
      case 'available':
      case 'tersedia':
        filtered = _allProducts
            .where((p) => p.stock >= 10 && p.stock < 50)
            .toList();
        break;
      case 'high':
      case 'banyak':
        filtered = _allProducts.where((p) => p.stock >= 50).toList();
        break;
      default:
        filtered = _allProducts;
    }

    emit(StockManagementLoaded(filtered, _userRole));
  }

  void filterByCategory(String category) {
    if (category.toLowerCase() == 'all' || category.isEmpty) {
      emit(StockManagementLoaded(_allProducts, _userRole));
      return;
    }

    final filtered = _allProducts
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();

    emit(StockManagementLoaded(filtered, _userRole));
  }

  void sortProducts(String sortBy) {
    final sorted = List<Product>.from(_allProducts);

    switch (sortBy.toLowerCase()) {
      case 'name':
      case 'nama':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'stock_asc':
      case 'stok_asc':
        sorted.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'stock_desc':
      case 'stok_desc':
        sorted.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'category':
      case 'kategori':
        sorted.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'price_asc':
      case 'harga_asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
      case 'harga_desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    emit(StockManagementLoaded(sorted, _userRole));
  }

  // Get low stock products (stock < 10)
  List<Product> getLowStockProducts() {
    return _allProducts.where((p) => p.stock > 0 && p.stock < 10).toList();
  }

  // Get out of stock products
  List<Product> getOutOfStockProducts() {
    return _allProducts.where((p) => p.stock == 0).toList();
  }

  // Get total products count
  int getTotalProducts() => _allProducts.length;

  // Get total stock value
  int getTotalStockValue() {
    return _allProducts.fold(
      0,
      (sum, product) => sum + (product.stock * product.price),
    );
  }

  // Get products by category
  Map<String, int> getProductCountByCategory() {
    final Map<String, int> categoryCounts = {};
    for (var product in _allProducts) {
      categoryCounts[product.category] =
          (categoryCounts[product.category] ?? 0) + 1;
    }
    return categoryCounts;
  }

  // Get all unique categories
  List<String> getAllCategories() {
    return _allProducts.map((p) => p.category).toSet().toList()..sort();
  }
}
