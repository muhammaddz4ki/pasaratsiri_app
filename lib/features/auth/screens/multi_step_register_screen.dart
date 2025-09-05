import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MultiStepRegisterScreen extends StatefulWidget {
  const MultiStepRegisterScreen({super.key});

  @override
  State<MultiStepRegisterScreen> createState() =>
      _MultiStepRegisterScreenState();
}

class _MultiStepRegisterScreenState extends State<MultiStepRegisterScreen>
    with TickerProviderStateMixin {
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
  int _currentPageIndex = 0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Define the emerald color palette
  final Color emeraldPrimary = const Color(0xFF10B981); // Emerald-500
  final Color emeraldSecondary = const Color(0xFF14B8A6); // Teal-500
  final Color emeraldDark = const Color(0xFF047857); // Emerald-700
  final Color emeraldLight = const Color(0xFFD1FAE5); // Emerald-100
  final Color emeraldUltraLight = const Color(0xFFECFDF5); // Emerald-50

  // Define orange palette for Penyulingan
  final Color orangePrimary = const Color(0xFFFF9800); // Orange-500
  final Color orangeSecondary = const Color(0xFFF57C00); // Orange-700
  final Color orangeLight = const Color(0xFFFFE0B2); // Orange-100

  // Define blue palette for Pemerintah
  final Color bluePrimary = const Color(0xFF2196F3); // Blue-500
  final Color blueSecondary = const Color(0xFF1976D2); // Blue-700
  final Color blueLight = const Color(0xFFBBDEFB); // Blue-100

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // --- Fungsi Navigasi ---
  void _nextPage() {
    // Hanya pindah halaman jika semua input di halaman saat ini valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Simpan data form
      setState(() {
        _currentPageIndex++;
      });
      _slideController.reset();
      _slideController.forward();
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
          SnackBar(
            backgroundColor: _getPrimaryColor(),
            content: const Text(
              'Registrasi Berhasil! Silakan Login.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          SnackBar(
            backgroundColor: Colors.red.shade600,
            content: Text(
              error,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi untuk mendapatkan warna utama berdasarkan role
  Color _getPrimaryColor() {
    final role = _registrationData['role'];
    if (role == 'penyulingan') return orangePrimary;
    if (role == 'pemerintah') return bluePrimary;
    return emeraldPrimary;
  }

  // Fungsi untuk mendapatkan warna sekunder berdasarkan role
  Color _getSecondaryColor() {
    final role = _registrationData['role'];
    if (role == 'penyulingan') return orangeSecondary;
    if (role == 'pemerintah') return blueSecondary;
    return emeraldSecondary;
  }

  Widget _buildProgressIndicator() {
    const steps = 4;
    final primaryColor = _getPrimaryColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(steps, (index) {
              final isActive = index <= _currentPageIndex;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < steps - 1 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: isActive ? primaryColor : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Langkah ${_currentPageIndex + 1} dari $steps',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _registrationData['role'] =
        ModalRoute.of(context)!.settings.arguments as String;

    // Tentukan warna utama berdasarkan role
    final Color primaryColor = _getPrimaryColor();
    final Color secondaryColor = _getSecondaryColor();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Enhanced App Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'PasarAtsiri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor, width: 1.5),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 24,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  // Halaman 1: Email & Password
                  _buildFormPage(
                    title: "Buat Akun",
                    subtitle: "Masukkan email dan password Anda",
                    icon: Icons.email_outlined,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    formFields: [
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          decoration: _buildInputDecoration(
                            'E-mail',
                            Icons.email_outlined,
                            primaryColor: primaryColor,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) =>
                              _registrationData['email'] = value,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Email tidak boleh kosong';
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value))
                              return 'Masukkan format email yang valid';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: _buildInputDecoration(
                            'Password',
                            Icons.lock_outline,
                            primaryColor: primaryColor,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: primaryColor,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                          onSaved: (value) =>
                              _registrationData['password'] = value,
                          validator: (value) {
                            if (value == null || value.length < 6)
                              return 'Password minimal 6 karakter';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: _buildInputDecoration(
                            'Konfirmasi Password',
                            Icons.lock_outline,
                            primaryColor: primaryColor,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: primaryColor,
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
                      ),
                    ],
                    onNext: _nextPage,
                    buttonText: 'SELANJUTNYA',
                  ),

                  // Halaman 2: Nama
                  _buildFormPage(
                    title: 'Identitas',
                    subtitle: "Siapa nama Anda?",
                    icon: Icons.person_outline,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    formFields: [
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          decoration: _buildInputDecoration(
                            'Nama Lengkap',
                            Icons.person_outline,
                            primaryColor: primaryColor,
                          ),
                          onSaved: (value) => _registrationData['name'] = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                        ),
                      ),
                    ],
                    onNext: _nextPage,
                    buttonText: 'SELANJUTNYA',
                  ),

                  // Halaman 3: Nomor Telepon
                  _buildFormPage(
                    title: 'Kontak',
                    subtitle: 'Masukkan nomor telepon Anda',
                    icon: Icons.phone_outlined,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    formFields: [
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          decoration: _buildInputDecoration(
                            'Nomor Telepon',
                            Icons.phone_outlined,
                            primaryColor: primaryColor,
                            prefixText: '+62 ',
                          ),
                          keyboardType: TextInputType.phone,
                          onSaved: (value) =>
                              _registrationData['phone'] = value,
                          validator: (value) => value!.isEmpty
                              ? 'Nomor telepon tidak boleh kosong'
                              : null,
                        ),
                      ),
                    ],
                    onNext: _nextPage,
                    buttonText: 'SELANJUTNYA',
                  ),

                  // Halaman 4: Umur
                  _buildFormPage(
                    title: 'Informasi Pribadi',
                    subtitle: "Berapa usia Anda?",
                    icon: Icons.cake_outlined,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    formFields: [
                      _buildInputField(
                        primaryColor: primaryColor,
                        child: TextFormField(
                          decoration: _buildInputDecoration(
                            'Usia',
                            Icons.cake_outlined,
                            primaryColor: primaryColor,
                            suffixText: 'tahun',
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _registrationData['age'] = value,
                          validator: (value) =>
                              value!.isEmpty ? 'Umur tidak boleh kosong' : null,
                        ),
                      ),
                    ],
                    onNext: _submitRegistration,
                    buttonText: 'DAFTAR',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    required Color primaryColor,
    Widget? suffixIcon,
    String? prefixText,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInputField({
    required Widget child,
    required Color primaryColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFormPage({
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> formFields,
    required VoidCallback onNext,
    required Color primaryColor,
    required Color secondaryColor,
    String buttonText = 'SUBMIT',
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          minimum: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Form Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(children: formFields),
              ),

              const Spacer(),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              buttonText == 'DAFTAR'
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
