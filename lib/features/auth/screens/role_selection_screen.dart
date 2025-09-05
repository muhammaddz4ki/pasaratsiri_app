import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Sesuaikan path ini

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  User? googleUser;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    required String subtitle,
    required IconData icon,
    required String roleValue,
    required Color primaryColor,
    required Color accentColor,
    required int index,
  }) {
    final bool isSelected = _selectedRole == roleValue;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    0.1 + (index * 0.1),
                    0.5 + (index * 0.1),
                    curve: Curves.easeOut,
                  ),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.1 + (index * 0.1),
                  0.5 + (index * 0.1),
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRole = roleValue;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, accentColor],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Colors.grey.shade50],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected) ...[
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          icon,
                          size: 32,
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the emerald color palette
    const Color emeraldPrimary = Color(0xFF10B981); // Emerald-500
    const Color emeraldSecondary = Color(0xFF14B8A6); // Teal-500
    const Color emeraldDark = Color(0xFF047857); // Emerald-700
    const Color emeraldLight = Color(0xFFD1FAE5); // Emerald-100
    const Color emeraldUltraLight = Color(0xFFECFDF5); // Emerald-50

    // Define orange palette for Penyulingan
    const Color orangePrimary = Color(0xFFFF9800); // Orange-500
    const Color orangeSecondary = Color(0xFFF57C00); // Orange-700
    const Color orangeLight = Color(0xFFFFE0B2); // Orange-100

    // Define blue palette for Pemerintah
    const Color bluePrimary = Color(0xFF2196F3); // Blue-500
    const Color blueSecondary = Color(0xFF1976D2); // Blue-700
    const Color blueLight = Color(0xFFBBDEFB); // Blue-100

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [emeraldUltraLight, Colors.white, emeraldUltraLight],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [emeraldPrimary, emeraldSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: emeraldPrimary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'PasarAtsiri',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset('assets/images/logo.png', height: 24),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Enhanced Header
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [emeraldPrimary, emeraldSecondary],
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: emeraldPrimary.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.how_to_reg_outlined,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Pilih Peran Anda',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: emeraldDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bergabunglah dengan ekosistem minyak atsiri\nsesuai dengan peran Anda',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: emeraldDark.withOpacity(0.7),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Enhanced Role Cards
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    emeraldPrimary,
                                  ),
                                ),
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                                children: [
                                  _buildRoleCard(
                                    title: 'Petani/UMKM',
                                    subtitle: 'Jual produk langsung',
                                    icon: Icons.agriculture_outlined,
                                    roleValue: 'petani',
                                    primaryColor: emeraldPrimary,
                                    accentColor: emeraldSecondary,
                                    index: 0,
                                  ),
                                  _buildRoleCard(
                                    title: 'Pembeli',
                                    subtitle: 'Beli produk',
                                    icon: Icons.shopping_bag_outlined,
                                    roleValue: 'pembeli',
                                    primaryColor: emeraldPrimary,
                                    accentColor: emeraldSecondary,
                                    index: 1,
                                  ),
                                  _buildRoleCard(
                                    title: 'Penyulingan',
                                    subtitle: 'Distribusi',
                                    icon: Icons.science_outlined,
                                    roleValue: 'penyulingan',
                                    primaryColor: orangePrimary,
                                    accentColor: orangeSecondary,
                                    index: 2,
                                  ),
                                  _buildRoleCard(
                                    title: 'Pemerintah',
                                    subtitle: 'Monitor & regulasi',
                                    icon: Icons.account_balance_outlined,
                                    roleValue: 'pemerintah',
                                    primaryColor:
                                        bluePrimary, // Changed to blue
                                    accentColor:
                                        blueSecondary, // Changed to blue
                                    index: 3,
                                  ),
                                ],
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Enhanced Continue Button
                      if (!_isLoading)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _animationController,
                                      curve: const Interval(
                                        0.6,
                                        1.0,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                  ),
                              child: FadeTransition(
                                opacity: Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: const Interval(
                                          0.6,
                                          1.0,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _selectedRole != null
                                            ? emeraldPrimary.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_selectedRole != null) {
                                        _selectRole(_selectedRole!);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.orange.shade600,
                                            content: const Text(
                                              'Silakan pilih peran Anda terlebih dahulu.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      backgroundColor: _selectedRole != null
                                          ? emeraldPrimary
                                          : Colors.grey.shade400,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'LANJUTKAN',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
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
