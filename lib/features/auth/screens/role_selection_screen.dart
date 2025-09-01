import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Sesuaikan path ini

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  User? googleUser;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is User) {
      googleUser = arguments;
    }
  }

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    if (googleUser != null) {
      // --- ALUR PENGGUNA BARU DARI GOOGLE ---
      final error = await _authService.createUserDocumentFromGoogleSignIn(
        user: googleUser!,
        role: role,
      );

      if (!mounted) return;

      if (error == null) {
        // PERUBAHAN UTAMA: signOut() DIHAPUS
        // Pengguna akan tetap login dan AuthWrapper akan mengarahkannya ke dashboard.
        if (mounted) {
          Navigator.pop(context); // Langsung kembali tanpa mengirim data
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(error)),
        );
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // --- ALUR REGISTRASI EMAIL/PASSWORD ---
      setState(() => _isLoading = false);
      Navigator.pushNamed(context, '/multi-step-register', arguments: role);
    }
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required String roleValue,
  }) {
    final bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = roleValue;
        });
      },
      child: Card(
        elevation: isSelected ? 8.0 : 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'PasarAtsiri',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/logo.png', height: 30),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Daftar Sebagai',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih peran Anda untuk melanjutkan pendaftaran',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildRoleCard(
                          title: 'Petani/UMKM',
                          icon: Icons.agriculture_outlined,
                          roleValue: 'petani',
                        ),
                        _buildRoleCard(
                          title: 'Pembeli',
                          icon: Icons.person_outline,
                          roleValue: 'pembeli',
                        ),
                        _buildRoleCard(
                          title: 'Unit Penyulingan',
                          icon: Icons.science_outlined,
                          roleValue: 'penyulingan',
                        ),
                        _buildRoleCard(
                          title: 'Pemerintah',
                          icon: Icons.corporate_fare,
                          roleValue: 'pemerintah',
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),
            if (!_isLoading)
              ElevatedButton(
                onPressed: () {
                  if (_selectedRole != null) {
                    _selectRole(_selectedRole!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.orange,
                        content: Text(
                          'Silakan pilih peran Anda terlebih dahulu.',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SELANJUTNYA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
