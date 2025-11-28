  import 'dart:typed_data';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:skynet_internet_cafe/core/utils/image_picker_helper.dart';
  import 'package:skynet_internet_cafe/presentation/logic/purchase_cubit.dart';
  import 'package:skynet_internet_cafe/presentation/widgets/appbar_widget.dart';
  import 'package:skynet_internet_cafe/presentation/widgets/navbar_widget.dart';

  class PurchasePage extends StatefulWidget {
    const PurchasePage({super.key});

    @override
    State<PurchasePage> createState() => _PurchasePageState();
  }

  class _PurchasePageState extends State<PurchasePage> {
    String selectedCategory = 'All';
    final List<String> categories = ['All', 'Drinks', 'Snacks'];
    final TextEditingController _searchController = TextEditingController();

    @override
    void initState() {
      super.initState();
      context.read<PurchaseCubit>().loadProducts();
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return BlocConsumer<PurchaseCubit, PurchaseState>(
        listener: (context, state) {
          if (state is PurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          String userRole = 'kasir';
          bool isAdmin = false;
          List<Map<String, dynamic>> products = [];
          bool isLoading = state is PurchaseLoading || state is ImageUploading;

          if (state is PurchaseLoaded) {
            userRole = state.userRole;
            isAdmin = state.isAdmin;
            products = state.products;
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              toolbarHeight: 70,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purchase Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Logged in as: $userRole',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              actions: const [AppbarWidget(), SizedBox(width: 8)],
            ),
            bottomNavigationBar: NavbarWidget(),
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              icon: Icon(Icons.search, color: Colors.grey),
                              hintText: 'Search products...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                context.read<PurchaseCubit>().loadProducts(
                                  category: selectedCategory,
                                );
                              } else {
                                context.read<PurchaseCubit>().searchProducts(
                                  value,
                                  category: selectedCategory,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedCategory = category;
                                      _searchController.clear();
                                    });
                                    context.read<PurchaseCubit>().loadProducts(
                                      category: category,
                                    );
                                  },
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  selectedColor: Colors.cyan,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  side: BorderSide.none,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.cyan),
                          )
                        : products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada produk',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _buildProductCard(product, isAdmin);
                            },
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    onPressed: () {
                      _showAddProductDialog();
                    },
                    backgroundColor: const Color(0xFF2E2E2E),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                : null,
          );
        },
      );
    }

    Widget _buildProductCard(Map<String, dynamic> product, bool isAdmin) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E2E2E)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: product['image_url'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product['image_url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unnamed Product',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${(product['price'] ?? 0).toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product['stock'] ?? 0}',
                    style: TextStyle(
                      color: (product['stock'] ?? 0) < 10
                          ? Colors.orange
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                if (isAdmin) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showEditProductDialog(product);
                      },
                      icon: const Icon(Icons.edit, color: Colors.black),
                      iconSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product['name']} ditambahkan ke keranjang',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.black,
                    ),
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildImagePlaceholder() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, color: Colors.grey[600], size: 28),
            const SizedBox(height: 2),
            Text(
              'Photo',
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      );
    }

    // ========================================
    // PICK IMAGE - Support Web & Mobile
    // ========================================
    Future<Map<String, dynamic>?> _pickImage() async {
      try {
        final result = await ImagePickerHelper.pickImage();
        return result;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    }

    // ========================================
    // ADD PRODUCT DIALOG
    // ========================================
    void _showAddProductDialog() {
      final formKey = GlobalKey<FormState>();
      final nameController = TextEditingController();
      final priceController = TextEditingController();
      final stockController = TextEditingController(text: '0');
      String selectedCategoryDialog = 'Drinks';
      Uint8List? selectedImageBytes;
      String? selectedImageName;
      String? uploadedImageUrl;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Tambah Produk Baru',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE PICKER
                    GestureDetector(
                      onTap: () async {
                        final result = await _pickImage();
                        if (result != null) {
                          setDialogState(() {
                            selectedImageBytes = result['bytes'];
                            selectedImageName = result['name'];
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk pilih gambar',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryDialog,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      items: ['Drinks', 'Snacks'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryDialog = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Upload image first if selected
                    if (selectedImageBytes != null && selectedImageName != null) {
                      final imageUrl = await this.context
                          .read<PurchaseCubit>()
                          .uploadImageBytes(
                            selectedImageBytes!,
                            selectedImageName!,
                          );

                      if (imageUrl != null) {
                        uploadedImageUrl = imageUrl;
                      }
                    }

                    // Add product
                    await this.context.read<PurchaseCubit>().addProduct(
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      category: selectedCategoryDialog,
                      imageUrl: uploadedImageUrl,
                    );

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================
    // EDIT PRODUCT DIALOG
    // ========================================
    void _showEditProductDialog(Map<String, dynamic> product) {
      final formKey = GlobalKey<FormState>();
      final nameController = TextEditingController(text: product['name']);
      final priceController = TextEditingController(
        text: product['price'].toString(),
      );
      final stockController = TextEditingController(
        text: product['stock'].toString(),
      );
      String selectedCategoryDialog = product['category'] ?? 'Drinks';
      Uint8List? selectedImageBytes;
      String? selectedImageName;
      String? newImageUrl;
      String? currentImageUrl = product['image_url'];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Edit Produk',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE PICKER
                    GestureDetector(
                      onTap: () async {
                        final result = await _pickImage();
                        if (result != null) {
                          setDialogState(() {
                            selectedImageBytes = result['bytes'];
                            selectedImageName = result['name'];
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  selectedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : currentImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  currentImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap untuk ganti gambar',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap untuk pilih gambar',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama Produk',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        labelStyle: const TextStyle(color: Colors.grey),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryDialog,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                      ),
                      items: ['Drinks', 'Snacks'].map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategoryDialog = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Upload new image if selected
                    if (selectedImageBytes != null && selectedImageName != null) {
                      final imageUrl = await this.context
                          .read<PurchaseCubit>()
                          .uploadImageBytes(
                            selectedImageBytes!,
                            selectedImageName!,
                          );

                      if (imageUrl != null) {
                        newImageUrl = imageUrl;
                      }
                    }

                    // Update product
                    await this.context.read<PurchaseCubit>().updateProduct(
                      productId: product['id'],
                      name: nameController.text,
                      price: int.parse(priceController.text),
                      stock: int.parse(stockController.text),
                      category: selectedCategoryDialog,
                      imageUrl: newImageUrl,
                      oldImageUrl: currentImageUrl,
                    );

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      );
    }
  }
