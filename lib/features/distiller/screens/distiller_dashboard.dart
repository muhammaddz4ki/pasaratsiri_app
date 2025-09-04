import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart'; // <-- SESUAIKAN PATH INI
import 'package:pasaratsiri_app/features/distiller/screens/distillation_input_screen.dart'; // <-- IMPORT
import 'package:pasaratsiri_app/features/distiller/screens/product_distribution_screen.dart'; // <-- IMPORT
import 'package:pasaratsiri_app/features/distiller/screens/product_quality_screen.dart'; // <-- IMPORT

class UnitPenyulinganDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UnitPenyulinganDashboard({super.key, required this.userData});

  @override
  State<UnitPenyulinganDashboard> createState() =>
      _UnitPenyulinganDashboardState();
}

class _UnitPenyulinganDashboardState extends State<UnitPenyulinganDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomeScreen(context), // Halaman Home (Indeks 0)
      _buildProfileScreen(context), // Halaman Profil (Indeks 1)
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Sembunyikan AppBar jika sedang di halaman profil
      appBar: _selectedIndex != 1
          ? AppBar(
              title: const Text("Dashboard Penyulingan"),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
              elevation: 2,
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN HALAMAN HOME (VERSI BARU) ---
  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang,',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            Text(
              widget.userData['name'] ?? 'Pengguna',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu Utama',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context: context,
              icon: Icons.add_chart,
              title: 'Input Penyulingan',
              subtitle: 'Catat proses & hasil penyulingan baru.',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DistillationInputScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.verified_user_outlined,
              title: 'Manajemen Mutu Produk',
              subtitle: 'Upload hasil uji lab & lihat status verifikasi.',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductQualityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.local_shipping_outlined,
              title: 'Distribusi Produk',
              subtitle: 'Atur batch minyak yang siap untuk dijual.',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductDistributionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat kartu fitur yang modern
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN HALAMAN PROFIL (TETAP SAMA) ---
  Widget _buildProfileScreen(BuildContext context) {
    // Anda bisa menggunakan kode _buildProfileScreen dari file lama Anda.
    // Kode di bawah ini adalah salinannya.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Icon(Icons.business_outlined, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userData['name'] ?? 'Unit Penyulingan',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.userData['email'] ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI DIALOG LOGOUT (TETAP SAMA) ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- FUNGSI LOGOUT (TETAP SAMA) ---
  Future<void> _logout() async {
    await AuthService().signOut();
  }
}
