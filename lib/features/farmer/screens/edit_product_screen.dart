// lib/features/farmer/screens/edit_product_screen.dart

import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/farmer/models/product_model.dart';
import 'package:pasaratsiri_app/features/farmer/services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _weightController;
  late TextEditingController _imageUrlController;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers dengan data produk yang ada
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _weightController = TextEditingController(text: widget.product.weight);
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memperbarui produk...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final String? error = await _productService.updateProduct(
        productId: widget.product.id,
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descriptionController.text,
        weight: _weightController.text,
        imageUrl: _imageUrlController.text,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context); // Close loading dialog
      }

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Produk berhasil diperbarui!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF047857), // Emerald-700
                Color(0xFF10B981), // Emerald-500
                Color(0xFF14B8A6), // Teal-500
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Edit Produk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with gradient
            Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF047857),
                    Color(0xFF10B981),
                    Color(0xFF14B8A6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: 60,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  // Header content
                  Positioned(
                    bottom: 20,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Produk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Perbarui informasi produk Anda',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Transform.translate(
              offset: const Offset(0, -20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image URL field
                            _buildEnhancedFormField(
                              controller: _imageUrlController,
                              label: 'Link Gambar Produk',
                              icon: Icons.image_outlined,
                              validator: (v) =>
                                  v!.isEmpty ? 'Link tidak boleh kosong' : null,
                              accentColor: const Color(0xFF10B981),
                            ),

                            const SizedBox(height: 20),

                            // Name field
                            _buildEnhancedFormField(
                              controller: _nameController,
                              label: 'Nama Produk',
                              icon: Icons.shopping_bag_outlined,
                              validator: (v) =>
                                  v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                              accentColor: const Color(0xFF14B8A6),
                            ),

                            const SizedBox(height: 20),

                            // Price field
                            _buildEnhancedFormField(
                              controller: _priceController,
                              label: 'Harga',
                              icon: Icons.attach_money_outlined,
                              keyboardType: TextInputType.number,
                              prefixText: 'Rp ',
                              validator: (v) => v!.isEmpty
                                  ? 'Harga tidak boleh kosong'
                                  : null,
                              accentColor: const Color(0xFF10B981),
                            ),

                            const SizedBox(height: 20),

                            // Weight field
                            _buildEnhancedFormField(
                              controller: _weightController,
                              label: 'Berat',
                              icon: Icons.scale_outlined,
                              validator: (v) => v!.isEmpty
                                  ? 'Berat tidak boleh kosong'
                                  : null,
                              accentColor: const Color(0xFF14B8A6),
                            ),

                            const SizedBox(height: 20),

                            // Description field
                            _buildEnhancedFormField(
                              controller: _descriptionController,
                              label: 'Deskripsi Produk',
                              icon: Icons.description_outlined,
                              maxLines: 4,
                              validator: (v) => v!.isEmpty
                                  ? 'Deskripsi tidak boleh kosong'
                                  : null,
                              accentColor: const Color(0xFF10B981),
                            ),

                            const SizedBox(height: 32),

                            // Update button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF047857),
                                    Color(0xFF10B981),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading ? null : _updateProduct,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: _isLoading
                                        ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Menyimpan...',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save_outlined,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'SIMPAN PERUBAHAN',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accentColor,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
