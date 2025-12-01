// File: lib/presentation/logic/purchase_cubit.dart
import 'dart:async';
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

// ✅ State baru untuk notifikasi sukses delete
class PurchaseDeleted extends PurchaseState {
  final String productName;
  PurchaseDeleted(this.productName);
}

// CUBIT
class PurchaseCubit extends Cubit<PurchaseState> {
  final supabase = Supabase.instance.client;

  // 🔥 Realtime subscription
  RealtimeChannel? _realtimeChannel;
  String? _currentCategory;

  PurchaseCubit() : super(PurchaseInitial());

  String getUserRole() {
    final user = supabase.auth.currentUser;
    if (user == null) return 'guest';
    return user.userMetadata?['role'] ?? 'kasir';
  }

  // ======================
  // 🔥 SETUP REALTIME LISTENER
  // ======================
  void setupRealtimeListener({String? category}) {
    _currentCategory = category;

    // Unsubscribe dari channel sebelumnya
    _realtimeChannel?.unsubscribe();

    // Create channel baru untuk produk dan stok
    _realtimeChannel = supabase.channel('produk-stok-changes');

    // Listen ke perubahan di tabel produk
    _realtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'produk',
          callback: (payload) {
            print('🔥 Realtime Event (produk): ${payload.eventType}');
            loadProducts(category: _currentCategory, silent: true);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stok',
          callback: (payload) {
            print('🔥 Realtime Event (stok): ${payload.eventType}');
            loadProducts(category: _currentCategory, silent: true);
          },
        )
        .subscribe();

    print('✅ Realtime listener started for category: ${category ?? "All"}');
  }

  // ======================
  // 🔥 DISPOSE REALTIME
  // ======================
  @override
  Future<void> close() {
    _realtimeChannel?.unsubscribe();
    print('❌ Realtime listener stopped');
    return super.close();
  }

  // ======================
  // UPLOAD IMAGE
  // ======================
  Future<String?> uploadImageBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      emit(ImageUploading());

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'product_${timestamp}_$fileName';

      await supabase.storage
          .from('product-images')
          .uploadBinary(uniqueFileName, imageBytes);

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

      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      await supabase.storage.from('product-images').remove([fileName]);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // ======================
  // 🔥 LOAD PRODUCTS (with JOIN to stok table)
  // ======================
  Future<void> loadProducts({String? category, bool silent = false}) async {
    try {
      if (!silent) {
        emit(PurchaseLoading());
      }

      final userRole = getUserRole();

      // Query dengan JOIN ke tabel stok
      var query = supabase.from('produk').select('''
        produkid,
        namaproduk,
        harga,
        kategori,
        gambar_url,
        created_at,
        stok(jumlah)
      ''');

      if (category != null && category != 'All') {
        query = query.eq('kategori', category);
      }

      final response = await query.order('namaproduk');

      // Parse response
      List<dynamic> dataList;
      if (response is List) {
        dataList = response;
      } else if (response is Map) {
        dataList = [response];
      } else {
        dataList = [];
      }

      final transformedData = dataList.map((item) {
        // Ambil jumlah stok dari JOIN
        int stock = 0;
        if (item['stok'] != null &&
            item['stok'] is List &&
            (item['stok'] as List).isNotEmpty) {
          stock = item['stok'][0]['jumlah'] ?? 0;
        }

        return {
          'id': item['produkid'],
          'name': item['namaproduk'],
          'price': item['harga'],
          'stock': stock,
          'category': item['kategori'],
          'image_url': item['gambar_url'],
          'created_at': item['created_at'],
        };
      }).toList();

      emit(PurchaseLoaded(products: transformedData, userRole: userRole));

      // 🔥 Setup realtime listener setelah load pertama kali
      if (!silent) {
        setupRealtimeListener(category: category);
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      emit(PurchaseError("Gagal memuat produk: $e"));
    }
  }

  // ======================
  // ADD PRODUCT (Tanpa Stok)
  // ======================
  Future<void> addProduct({
    required String name,
    required int price,
    required String category,
    String? imageUrl,
  }) async {
    try {
      // Insert produk (tanpa stok)
      await supabase.from('produk').insert({
        'namaproduk': name,
        'harga': price,
        'kategori': category,
        'gambar_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Product added');
      // Realtime akan auto-reload
    } catch (e) {
      print('❌ Error adding product: $e');
      emit(PurchaseError('Gagal menambah produk: $e'));
    }
  }

  // ======================
  // UPDATE PRODUCT (Tanpa Stok)
  // ======================
  Future<void> updateProduct({
    required String productId,
    required String name,
    required int price,
    required String category,
    String? imageUrl,
    String? oldImageUrl,
  }) async {
    try {
      // Update produk
      final updateData = {
        'namaproduk': name,
        'harga': price,
        'kategori': category,
      };

      if (imageUrl != null) {
        updateData['gambar_url'] = imageUrl;

        if (oldImageUrl != null && oldImageUrl != imageUrl) {
          await deleteImageFromStorage(oldImageUrl);
        }
      }

      await supabase
          .from('produk')
          .update(updateData)
          .eq('produkid', productId);

      print('✅ Product updated');
      // Realtime akan auto-reload
    } catch (e) {
      print('❌ Error updating product: $e');
      emit(PurchaseError('Gagal mengupdate produk: $e'));
    }
  }

  // ======================
  // DELETE PRODUCT
  // ======================
  Future<void> deleteProduct(
    String productId,
    String? imageUrl,
    String productName,
  ) async {
    try {
      // Delete stok first (foreign key constraint)
      await supabase.from('stok').delete().eq('produktid', productId);

      // Delete image if exists
      if (imageUrl != null) {
        await deleteImageFromStorage(imageUrl);
      }

      // Delete product
      await supabase.from('produk').delete().eq('produkid', productId);

      print('✅ Product and stock deleted');

      // ✅ Emit state sukses delete dengan nama produk
      emit(PurchaseDeleted(productName));

      // Realtime akan auto-reload
    } catch (e) {
      print('❌ Error deleting product: $e');
      emit(PurchaseError('Gagal menghapus produk: $e'));
    }
  }

  // ======================
  // SEARCH PRODUCT
  // ======================
  Future<void> searchProducts(String query, {String? category}) async {
    try {
      // 🔥 Stop realtime saat search
      _realtimeChannel?.unsubscribe();

      emit(PurchaseLoading());

      final role = getUserRole();

      var q = supabase
          .from('produk')
          .select('''
        produkid,
        namaproduk,
        harga,
        kategori,
        gambar_url,
        created_at,
        stok(jumlah)
      ''')
          .ilike('namaproduk', '%$query%');

      if (category != null && category != 'All') {
        q = q.eq('kategori', category);
      }

      final response = await q.order('namaproduk');

      // Parse response
      List<dynamic> dataList;
      if (response is List) {
        dataList = response;
      } else if (response is Map) {
        dataList = [response];
      } else {
        dataList = [];
      }

      final transformed = dataList.map((item) {
        int stock = 0;
        if (item['stok'] != null &&
            item['stok'] is List &&
            (item['stok'] as List).isNotEmpty) {
          stock = item['stok'][0]['jumlah'] ?? 0;
        }

        return {
          'id': item['produkid'],
          'name': item['namaproduk'],
          'price': item['harga'],
          'stock': stock,
          'category': item['kategori'],
          'image_url': item['gambar_url'],
          'created_at': item['created_at'],
        };
      }).toList();

      emit(PurchaseLoaded(products: transformed, userRole: role));
    } catch (e) {
      print('❌ Error searching products: $e');
      emit(PurchaseError('Gagal mencari produk: $e'));
    }
  }
}
