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
            SnackBar(
              content: const Text('Pengajuan bantuan berhasil dikirim!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pengajuan Bantuan Baru',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.attach_money_rounded,
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
                            'Formulir Pengajuan Bantuan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Lengkapi data berikut untuk mengajukan bantuan',
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

              _buildTextField(
                _titleController,
                'Judul Pengajuan',
                'Contoh: Bantuan Modal Usaha',
                icon: Icons.title_rounded,
              ),
              _buildTextField(
                _subsidyTypeController,
                'Jenis Subsidi',
                'Contoh: Bantuan Modal, Subsidi Pupuk, dll.',
                icon: Icons.category_rounded,
              ),
              _buildTextField(
                _subsidyAmountController,
                'Jumlah Pengajuan (Rp)',
                'Contoh: 5000000',
                keyboardType: TextInputType.number,
                icon: Icons.money_rounded,
              ),
              _buildTextField(
                _applicantTypeController,
                'Jenis Pemohon',
                'Petani / UMKM / Kelompok Tani',
                icon: Icons.person_outline_rounded,
              ),
              _buildTextField(
                _locationController,
                'Lokasi (Kecamatan)',
                'Contoh: Kec. Samarang',
                icon: Icons.location_on_outlined,
              ),
              _buildTextField(
                _farmAreaController,
                'Luas Lahan',
                'Contoh: 2 Ha',
                icon: Icons.agriculture_rounded,
              ),
              _buildTextField(
                _phoneNumberController,
                'Nomor Telepon Aktif',
                'Contoh: 08123...',
                keyboardType: TextInputType.phone,
                icon: Icons.phone_rounded,
              ),
              _buildTextField(
                _bankAccountController,
                'Rekening Bank',
                'Contoh: BRI - 123456789',
                icon: Icons.account_balance_rounded,
              ),
              _buildTextField(
                _descriptionController,
                'Deskripsi Kebutuhan',
                'Jelaskan kebutuhan Anda secara detail',
                maxLines: 4,
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.1),
                              const Color(0xFF14B8A6).withOpacity(0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
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
                      child: ElevatedButton.icon(
                        onPressed: _submitApplication,
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text(
                          'KIRIM PENGAJUAN',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int? maxLines,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xFF6B7280), size: 20)
              : null,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
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
