import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/distiller_service.dart'; // Sesuaikan path jika perlu

class DistillationInputScreen extends StatefulWidget {
  const DistillationInputScreen({super.key});

  @override
  State<DistillationInputScreen> createState() =>
      _DistillationInputScreenState();
}

class _DistillationInputScreenState extends State<DistillationInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distillerService = DistillerService();
  bool _isLoading = false;

  // Controllers untuk setiap input field
  final _rawMaterialController = TextEditingController();
  final _weightController = TextEditingController();
  final _volumeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    // Selalu dispose controller setelah tidak digunakan
    _rawMaterialController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final data = {
          'rawMaterial': _rawMaterialController.text,
          'rawMaterialWeight': double.parse(_weightController.text),
          'producedOilVolume': double.parse(_volumeController.text),
          'qualityNotes': _notesController.text,
        };

        await _distillerService.addDistillationBatch(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data penyulingan berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Penyulingan'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _rawMaterialController,
                labelText: 'Bahan Baku',
                hintText: 'Contoh: Daun Sereh Wangi',
                icon: Icons.grass,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _weightController,
                labelText: 'Berat Bahan Baku (kg)',
                hintText: 'Contoh: 150.5',
                icon: Icons.scale,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _volumeController,
                labelText: 'Hasil Minyak (ml)',
                hintText: 'Contoh: 1200',
                icon: Icons.science_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _notesController,
                labelText: 'Catatan Kualitas',
                hintText: 'Contoh: Warna jernih, aroma kuat',
                icon: Icons.note_alt_outlined,
                maxLines: 3,
                isRequired: false, // Catatan tidak wajib
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk membuat TextFormField yang seragam
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$labelText tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
