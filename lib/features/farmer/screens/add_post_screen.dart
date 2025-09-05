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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
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
          // Tombol Kirim di AppBar
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
              // Header Info Card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFECFDF5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
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
                            'Buat Diskusi Baru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bagikan pengalaman atau ajukan pertanyaan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Postingan',
                  hintText: 'Contoh: Bagaimana cara mengatasi hama kutu putih?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.title_rounded,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
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
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.category_rounded,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(color: Color(0xFF374151)),
                    ),
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
                decoration: InputDecoration(
                  labelText: 'Isi Postingan',
                  hintText:
                      'Jelaskan pertanyaan atau bagikan pengalaman Anda di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  labelStyle: const TextStyle(color: Color(0xFF6B7280)),
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
              const SizedBox(height: 32),

              // Tombol Kirim di bawah
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoading ? null : _submitPost,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'KIRIM POSTINGAN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
