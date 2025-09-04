import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class AddSubsidyScreen extends StatefulWidget {
  const AddSubsidyScreen({super.key});

  @override
  State<AddSubsidyScreen> createState() => _AddSubsidyScreenState();
}

class _AddSubsidyScreenState extends State<AddSubsidyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmerService = FarmerService();
  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _applicantTypeController = TextEditingController(text: 'Petani');
  final _subsidyTypeController = TextEditingController();
  final _subsidyAmountController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmAreaController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _farmerService.applyForSubsidy(
          title: _titleController.text,
          description: _descriptionController.text,
          applicantType: _applicantTypeController.text,
          subsidyType: _subsidyTypeController.text,
          subsidyAmount: int.tryParse(_subsidyAmountController.text) ?? 0,
          location: _locationController.text,
          farmArea: _farmAreaController.text,
          phoneNumber: _phoneNumberController.text,
          bankAccount: _bankAccountController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengajuan bantuan berhasil dikirim!'),
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
        title: const Text('Pengajuan Bantuan Baru'),
        backgroundColor: Colors.purple.shade700,
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
                'Judul Pengajuan',
                'Contoh: Bantuan Modal Usaha',
              ),
              _buildTextField(
                _subsidyTypeController,
                'Jenis Subsidi',
                'Contoh: Bantuan Modal',
              ),
              _buildTextField(
                _subsidyAmountController,
                'Jumlah Pengajuan (Rp)',
                'Contoh: 5000000',
                keyboardType: TextInputType.number,
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
                _farmAreaController,
                'Luas Lahan',
                'Contoh: 2 Ha',
              ),
              _buildTextField(
                _phoneNumberController,
                'Nomor Telepon Aktif',
                'Contoh: 08123...',
              ),
              _buildTextField(
                _bankAccountController,
                'Rekening Bank',
                'Contoh: BRI - 123456789',
              ),
              _buildTextField(
                _descriptionController,
                'Deskripsi Kebutuhan',
                'Jelaskan kebutuhan Anda',
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
                        backgroundColor: Colors.purple.shade700,
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
    _subsidyTypeController.dispose();
    _subsidyAmountController.dispose();
    _locationController.dispose();
    _farmAreaController.dispose();
    _phoneNumberController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }
}
