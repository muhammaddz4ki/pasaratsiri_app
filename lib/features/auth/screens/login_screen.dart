import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Sesuaikan path ini

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final List<String> _backgroundImages = [
    'assets/images/bg_1.png',
    'assets/images/background2.png',
    'assets/images/background3.png',
  ];
  int _currentImageIndex = 0;
  Timer? _timer;

  bool _isPasswordVisible = false;

  // Define the emerald color palette
  final Color emeraldPrimary = const Color(0xFF10B981); // Emerald-500
  final Color emeraldSecondary = const Color(0xFF14B8A6); // Teal-500
  final Color emeraldDark = const Color(0xFF047857); // Emerald-700
  final Color emeraldLight = const Color(0xFFD1FAE5); // Emerald-100
  final Color emeraldUltraLight = const Color(0xFFECFDF5); // Emerald-50

  @override
  void initState() {
    super.initState();
    _startImageTimer();
  }

  void _startImageTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex =
              (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final String? error = await _authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            content: Text(error),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            content: Text('Terjadi kesalahan: ${e.toString()}'),
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

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (!mounted) return;

      // Jika hasilnya adalah User, berarti ini pengguna baru.
      if (result is User) {
        // Kita navigasi ke halaman pemilihan peran. Setelah dari sana,
        // AuthWrapper akan otomatis menangani navigasi ke dashboard.
        await Navigator.pushNamed(
          context,
          '/register-role-selection',
          arguments: result,
        );
      } else if (result is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade600,
            content: Text(result),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      // Jika hasilnya null, AuthWrapper akan otomatis navigasi ke dashboard.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade600,
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      // Hentikan loading jika pengguna masih di halaman ini
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _backgroundImages[_currentImageIndex],
            key: ValueKey<int>(_currentImageIndex),
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.5),
            colorBlendMode: BlendMode.darken,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      (MediaQuery.of(context).padding.top +
                          MediaQuery.of(context).padding.bottom),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 28,
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          height: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              hintText: 'Email/Nomor HP',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(Icons.flag, color: Colors.white),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '+62',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field ini tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.white),
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Colors.white,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Tambahkan fungsi Lupa Kata Sandi
                              },
                              child: const Text(
                                'Lupa Kata Sandi?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      emeraldPrimary,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        backgroundColor: emeraldPrimary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 4,
                                        shadowColor: emeraldPrimary.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      child: const Text(
                                        'MASUK',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: _handleGoogleSignIn,
                                      icon: const Icon(
                                        Icons.g_mobiledata,
                                        color: Colors.white,
                                      ),
                                      label: const Text('Masuk dengan Google'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum punya akun?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/register-role-selection',
                                ),
                                child: Text(
                                  'Daftar di sini',
                                  style: TextStyle(
                                    color: emeraldLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PasarAtsiri',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/register-role-selection',
                              ),
                              child: Text(
                                'Daftar',
                                style: TextStyle(
                                  color: emeraldLight,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
