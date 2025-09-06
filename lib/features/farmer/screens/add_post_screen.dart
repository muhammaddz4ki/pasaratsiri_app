// lib/features/farmer/screens/add_post_screen.dart

import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final FarmerService _farmerService = FarmerService();
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap input
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController =
      TextEditingController(); // Controller untuk link gambar

  // State untuk dropdown kategori
  String _selectedCategory = 'Teknik Budidaya';
  final List<String> _categories = [
    'Teknik Budidaya',
    'Hama & Penyakit',
    'Pupuk & Nutrisi',
    'Jual Beli',
    'Lainnya',
  ];

  bool _isLoading = false;

  // Fungsi untuk mengirim postingan
  Future<void> _submitPost() async {
    // Validasi form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Ambil link gambar, jika kosong jadikan null
      String? imageUrl = _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim();

      final result = await _farmerService.createPost(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        imageUrl: imageUrl, // Kirim data gambar
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result == null) {
          // Jika sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Postingan berhasil dibuat!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
        } else {
          // Jika gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat postingan: $result'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Buat Postingan Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF047857), // Emerald-700
                Color(0xFF10B981), // Emerald-500
                Color(0xFF14B8A6), // Teal-500
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _isLoading ? null : _submitPost,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'KIRIM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info Card (tidak berubah)
              // ...

              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Postingan',
                  hintText: 'Contoh: Bagaimana cara mengatasi hama kutu putih?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Judul tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 20),

              // Input Link Gambar
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link Gambar (Opsional)',
                  hintText: 'https://contoh.com/gambar.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.startsWith('http')) {
                    return 'URL tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() => _selectedCategory = newValue!);
                },
              ),
              const SizedBox(height: 20),

              // Input Isi Postingan
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Postingan',
                  hintText:
                      'Jelaskan pertanyaan atau bagikan pengalaman Anda di sini...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Isi postingan tidak boleh kosong'
                    : null,
              ),

              const SizedBox(height: 32),
              // Tombol Kirim Bawah (opsional)
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
