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

    // Create channel baru
    _realtimeChannel = supabase.channel('produk-changes');

    // Listen ke semua perubahan di tabel produk
    _realtimeChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'produk',
          callback: (payload) {
            print('🔥 Realtime Event: ${payload.eventType}');
            print('📦 Data: ${payload.newRecord}');

            // Reload products setiap ada perubahan
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
      final role = getUserRole();
      if (role != 'admin') {
        emit(PurchaseError('Hanya admin yang bisa upload gambar'));
        return null;
      }

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
  // 🔥 LOAD PRODUCTS (with silent mode for realtime)
  // ======================
  Future<void> loadProducts({String? category, bool silent = false}) async {
    try {
      if (!silent) {
        emit(PurchaseLoading());
      }

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

      // 🔥 Setup realtime listener setelah load pertama kali
      if (!silent) {
        setupRealtimeListener(category: category);
      }
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

      // ✅ Realtime akan auto-reload, tapi bisa manual juga
      // await loadProducts(category: _currentCategory, silent: true);
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
        if (oldImageUrl != null && oldImageUrl != imageUrl) {
          await deleteImageFromStorage(oldImageUrl);
        }
      }

      await supabase
          .from('produk')
          .update(updateData)
          .eq('produkid', productId);

      // ✅ Realtime akan auto-reload
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

      if (imageUrl != null) {
        await deleteImageFromStorage(imageUrl);
      }

      await supabase.from('produk').delete().eq('produkid', productId);

      // ✅ Realtime akan auto-reload
    } catch (e) {
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
