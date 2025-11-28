import 'dart:typed_data';
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

class ImageUploading extends PurchaseState {}

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
  // UPLOAD IMAGE - Support Web & Mobile
  // ======================
  Future<String?> uploadImageBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa upload gambar'));
        return null;
      }

      // Emit loading state
      emit(ImageUploading());

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'product_${timestamp}_$fileName';

      // Upload to Supabase Storage menggunakan bytes
      await supabase.storage
          .from('product-images')
          .uploadBinary(uniqueFileName, imageBytes);

      // Get public URL
      final String publicUrl = supabase.storage
          .from('product-images')
          .getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      emit(PurchaseError('Gagal upload gambar: $e'));
      return null;
    }
  }

  // ======================
  // DELETE IMAGE FROM STORAGE
  // ======================
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      await supabase.storage.from('product-images').remove([fileName]);
    } catch (e) {
      // Silent fail - tidak perlu emit error
      print('Error deleting image: $e');
    }
  }

  // ======================
  // LOAD PRODUCTS
  // ======================
  Future<void> loadProducts({String? category}) async {
    try {
      emit(PurchaseLoading());
      final userRole = getUserRole();

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
    String? oldImageUrl,
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
        // Delete old image if exists and different from new
        if (oldImageUrl != null && oldImageUrl != imageUrl) {
          await deleteImageFromStorage(oldImageUrl);
        }
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
  Future<void> deleteProduct(String productId, String? imageUrl) async {
    try {
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa menghapus produk'));
        return;
      }

      // Delete image first
      if (imageUrl != null) {
        await deleteImageFromStorage(imageUrl);
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
