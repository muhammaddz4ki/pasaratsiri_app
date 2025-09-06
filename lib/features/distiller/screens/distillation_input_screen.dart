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

  // Orange color palette
  final Color _primaryOrange = const Color(0xFFEA580C);
  final Color _secondaryOrange = const Color(0xFFF97316);
  final Color _lightOrange = const Color(0xFFFFEDD5);
  final Color _darkOrange = const Color(0xFF9A3412);
  final Color _background = const Color(0xFFFFF7ED);

  @override
  void dispose() {
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
          SnackBar(
            content: const Text('Data penyulingan berhasil disimpan!'),
            backgroundColor: _primaryOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Input Data Penyulingan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryOrange, _secondaryOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, _lightOrange],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _primaryOrange.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.science_outlined, size: 48, color: _primaryOrange),
                  const SizedBox(height: 10),
                  Text(
                    'Form Input Penyulingan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _darkOrange,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Isi data hasil penyulingan dengan lengkap',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextFormField(
                    controller: _rawMaterialController,
                    labelText: 'Bahan Baku',
                    hintText: 'Contoh: Daun Nilam Kering',
                    icon: Icons.grass,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _weightController,
                    labelText: 'Berat Bahan Baku (kg)',
                    hintText: 'Contoh: 150.5',
                    icon: Icons.scale,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _volumeController,
                    labelText: 'Hasil Minyak (ml)',
                    hintText: 'Contoh: 1200',
                    icon: Icons.water_drop_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _notesController,
                    labelText: 'Catatan Kualitas',
                    hintText: 'Contoh: Warna jernih, aroma kuat',
                    icon: Icons.note_alt_outlined,
                    maxLines: 3,
                    isRequired: false,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(_primaryOrange),
                            strokeWidth: 3,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: _primaryOrange,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: _primaryOrange.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save, size: 20),
                              const SizedBox(width: 10),
                              const Text('Simpan Data'),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(color: Colors.grey[800]),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: _primaryOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _primaryOrange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          labelStyle: TextStyle(
            color: _darkOrange,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$labelText tidak boleh kosong';
          }
          if (keyboardType == TextInputType.number &&
              value != null &&
              value.isNotEmpty) {
            final numValue = double.tryParse(value);
            if (numValue == null || numValue <= 0) {
              return 'Masukkan angka yang valid';
            }
          }
          return null;
        },
      ),
    );
  }
}
