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

      final result = await _farmerService.createPost(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
      );

      setState(() {
        _isLoading = false;
      });

      if (result == null) {
        // Jika sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Postingan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
      } else {
        // Jika gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat postingan: $result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan Baru'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Kirim di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _isLoading ? null : _submitPost,
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
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Postingan',
                  hintText: 'Contoh: Bagaimana cara mengatasi hama kutu putih?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
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
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
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
                maxLines: 10,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi postingan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
