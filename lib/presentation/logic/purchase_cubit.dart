import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// STATES
abstract class PurchaseState {}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseLoaded extends PurchaseState {
  final List<Map<String, dynamic>> products;
  final String userRole;
  final bool isAdmin;

  PurchaseLoaded({required this.products, required this.userRole})
    : isAdmin = userRole == 'admin';
}

class PurchaseError extends PurchaseState {
  final String message;
  PurchaseError(this.message);
}

// CUBIT
class PurchaseCubit extends Cubit<PurchaseState> {
  final supabase = Supabase.instance.client;

  PurchaseCubit() : super(PurchaseInitial());

  String getUserRole() {
    final user = supabase.auth.currentUser;
    if (user == null) return 'guest';
    return user.userMetadata?['role'] ?? 'kasir';
  }

  // ======================
  // LOAD PRODUCTS
  // ======================
  Future<void> loadProducts({String? category}) async {
    try {
      emit(PurchaseLoading());
      final userRole = getUserRole();

      // SELECT EXPLICIT — fix error produk.name
      var query = supabase.from('produk').select("""
        produkid,
        namaproduk,
        harga,
        stok,
        kategori,
        gambar_url,
        created_at
      """);

      if (category != null && category != 'All') {
        query = query.eq('kategori', category);
      }

      final data = await query.order('namaproduk');

      final transformedData = (data as List).map((item) {
        return {
          'id': item['produkid'],
          'name': item['namaproduk'],
          'price': item['harga'],
          'stock': item['stok'],
          'category': item['kategori'],
          'image_url': item['gambar_url'],
          'created_at': item['created_at'],
        };
      }).toList();

      emit(PurchaseLoaded(products: transformedData, userRole: userRole));
    } catch (e) {
      emit(PurchaseError("Gagal memuat produk: $e"));
    }
  }

  // ======================
  // ADD PRODUCT
  // ======================
  Future<void> addProduct({
    required String name,
    required int price,
    required int stock,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa menambah produk'));
        return;
      }

      await supabase.from('produk').insert({
        'namaproduk': name,
        'harga': price,
        'stok': stock,
        'kategori': category,
        'gambar_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      await loadProducts();
    } catch (e) {
      emit(PurchaseError('Gagal menambah produk: $e'));
    }
  }

  // ======================
  // UPDATE PRODUCT
  // ======================
  Future<void> updateProduct({
    required String productId,
    required String name,
    required int price,
    required int stock,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa mengupdate produk'));
        return;
      }

      final updateData = {
        'namaproduk': name,
        'harga': price,
        'stok': stock,
        'kategori': category,
      };

      if (imageUrl != null) {
        updateData['gambar_url'] = imageUrl;
      }

      await supabase
          .from('produk')
          .update(updateData)
          .eq('produkid', productId);

      await loadProducts();
    } catch (e) {
      emit(PurchaseError('Gagal mengupdate produk: $e'));
    }
  }

  // ======================
  // DELETE PRODUCT
  // ======================
  Future<void> deleteProduct(String productId) async {
    try {
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa menghapus produk'));
        return;
      }

      await supabase.from('produk').delete().eq('produkid', productId);

      await loadProducts();
    } catch (e) {
      emit(PurchaseError('Gagal menghapus produk: $e'));
    }
  }

  // ======================
  // SEARCH PRODUCT
  // ======================
  Future<void> searchProducts(String query, {String? category}) async {
    try {
      emit(PurchaseLoading());
      final role = getUserRole();

      var q = supabase
          .from('produk')
          .select("""
        produkid,
        namaproduk,
        harga,
        stok,
        kategori,
        gambar_url,
        created_at
      """)
          .ilike('namaproduk', '%$query%');

      if (category != null && category != 'All') {
        q = q.eq('kategori', category);
      }

      final data = await q.order('namaproduk');

      final transformed = (data as List).map((item) {
        return {
          'id': item['produkid'],
          'name': item['namaproduk'],
          'price': item['harga'],
          'stock': item['stok'],
          'category': item['kategori'],
          'image_url': item['gambar_url'],
          'created_at': item['created_at'],
        };
      }).toList();

      emit(PurchaseLoaded(products: transformed, userRole: role));
    } catch (e) {
      emit(PurchaseError('Gagal mencari produk: $e'));
    }
  }
}
