import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MultiStepRegisterScreen extends StatefulWidget {
  const MultiStepRegisterScreen({super.key});

  @override
  State<MultiStepRegisterScreen> createState() =>
      _MultiStepRegisterScreenState();
}

class _MultiStepRegisterScreenState extends State<MultiStepRegisterScreen> {
  // --- State dan Controller ---
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final AuthService _authService = AuthService();
  final Map<String, dynamic> _registrationData = {};

  // Controller khusus untuk validasi password
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // --- Fungsi Navigasi ---
  void _nextPage() {
    // Hanya pindah halaman jika semua input di halaman saat ini valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Simpan data form
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _submitRegistration() async {
    // 1. Validasi form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    // Simpan nilai dari form ke dalam map _registrationData
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final String? error = await _authService.registerWithEmail(
        name: _registrationData['name'] ?? '',
        email: _registrationData['email'] ?? '',
        phoneNumber: _registrationData['phone'] ?? '',
        password: _registrationData['password'] ?? '',
        role: _registrationData['role'] ?? 'pembeli',
        age: int.tryParse(_registrationData['age'] ?? '0') ?? 0,
      );

      if (!mounted) return;

      if (error == null) {
        // --- PERUBAHAN UTAMA DI SINI ---
        // Jika registrasi sukses, tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Registrasi Berhasil! Silakan Login.'),
          ),
        );

        // Kemudian, paksa pengguna untuk logout
        await _authService.signOut();

        // Terakhir, tutup semua halaman registrasi untuk kembali ke LoginScreen
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        // ------------------------------------
      } else {
        // Jika ada error, tampilkan pesan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(error)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _registrationData['role'] =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
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
      // Bungkus PageView dengan Form agar validasi bisa berjalan di semua halaman
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Halaman 1: Email & Password
            _buildFormPage(
              title: "Sign Up",
              formFields: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => _registrationData['email'] = value,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                      return 'Masukkan format email yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  onSaved: (value) => _registrationData['password'] = value,
                  validator: (value) {
                    if (value == null || value.length < 6)
                      return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text)
                      return 'Password tidak cocok';
                    return null;
                  },
                ),
              ],
              onNext: _nextPage,
              buttonText: 'SELANJUTNYA',
            ),

            // Halaman 2: Nama
            _buildFormPage(
              title: 'REGISTER',
              subtitle: "What's your name?",
              formFields: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Your Name'),
                  onSaved: (value) => _registrationData['name'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
              ],
              onNext: _nextPage,
              buttonText: 'SELANJUTNYA',
            ),

            // Halaman 3: Nomor Telepon
            _buildFormPage(
              title: 'REGISTER',
              subtitle: 'Please enter your phone number',
              formFields: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+62 | ',
                  ),
                  keyboardType: TextInputType.phone,
                  onSaved: (value) => _registrationData['phone'] = value,
                  validator: (value) => value!.isEmpty
                      ? 'Nomor telepon tidak boleh kosong'
                      : null,
                ),
              ],
              onNext: _nextPage,
              buttonText: 'SELANJUTNYA',
            ),

            // Halaman 4: Umur
            _buildFormPage(
              title: 'REGISTER',
              subtitle: "How old are you?",
              formFields: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Your Age'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _registrationData['age'] = value,
                  validator: (value) =>
                      value!.isEmpty ? 'Umur tidak boleh kosong' : null,
                ),
              ],
              onNext: _submitRegistration,
              buttonText: 'DAFTAR',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPage({
    required String title,
    String? subtitle,
    required List<Widget> formFields,
    required VoidCallback onNext,
    String buttonText = 'SUBMIT',
  }) {
    return SafeArea(
      minimum: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 48),
          ...formFields,
          const Spacer(),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
