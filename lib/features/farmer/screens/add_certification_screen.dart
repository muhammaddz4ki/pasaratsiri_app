import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class AddCertificationScreen extends StatefulWidget {
  const AddCertificationScreen({super.key});

  @override
  State<AddCertificationScreen> createState() => _AddCertificationScreenState();
}

class _AddCertificationScreenState extends State<AddCertificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerService = FarmerService();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _applicantTypeController = TextEditingController(text: 'Petani');
  final _certificationTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentsController = TextEditingController();

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _farmerService.applyForCertification(
          title: _titleController.text,
          description: _descriptionController.text,
          applicantType: _applicantTypeController.text,
          certificationType: _certificationTypeController.text,
          location: _locationController.text,
          phoneNumber: _phoneNumberController.text,
          email: _emailController.text,
          documents: _documentsController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan sertifikasi berhasil dikirim!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Sertifikasi Baru'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                _titleController,
                'Judul Sertifikasi',
                'Contoh: Sertifikasi Organik Atsiri',
              ),
              _buildTextField(
                _certificationTypeController,
                'Jenis Sertifikasi',
                'Contoh: Sertifikasi Organik',
              ),
              _buildTextField(
                _applicantTypeController,
                'Jenis Pemohon',
                'Petani / UMKM / Kelompok Tani',
              ),
              _buildTextField(
                _locationController,
                'Lokasi (Kecamatan)',
                'Contoh: Kec. Samarang',
              ),
              _buildTextField(
                _phoneNumberController,
                'Nomor Telepon Aktif',
                'Contoh: 08123...',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                _emailController,
                'Email',
                'Contoh: petani@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                _documentsController,
                'Dokumen Pendukung',
                'Contoh: KTP, Sertifikat Lahan, NPWP (pisahkan dengan koma)',
              ),
              _buildTextField(
                _descriptionController,
                'Deskripsi Singkat',
                'Contoh: Untuk panen periode Juli 2025',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitApplication,
                      icon: const Icon(Icons.send),
                      label: const Text('KIRIM PENGAJUAN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: (v) => v!.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _applicantTypeController.dispose();
    _certificationTypeController.dispose();
    _locationController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _documentsController.dispose();
    super.dispose();
  }
}
