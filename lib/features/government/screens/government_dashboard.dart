import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart'; // <-- SESUAIKAN PATH INI

class PemerintahDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PemerintahDashboard({super.key, required this.userData});

  @override
  State<PemerintahDashboard> createState() => _PemerintahDashboardState();
}

class _PemerintahDashboardState extends State<PemerintahDashboard> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman yang akan ditampilkan
    _pages = <Widget>[
      _buildHomeScreen(), // Halaman Home (Indeks 0)
      _buildProfileScreen(), // Halaman Profil (Indeks 1)
    ];
  }

  // Fungsi untuk mengubah halaman saat item di navigasi bawah diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sembunyikan AppBar jika sedang di halaman profil
      appBar: _selectedIndex != 1
          ? AppBar(
              title: const Text("Dashboard Pemerintah"),
              centerTitle: true,
              automaticallyImplyLeading: false,
            )
          : null,
      // Tampilkan halaman sesuai dengan indeks yang dipilih
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[800], // Sesuaikan warna tema pemerintah
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN HALAMAN HOME ---
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Pemerintah',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Login sebagai ${widget.userData['name'] ?? ''}'),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Tambahkan navigasi ke halaman laporan
              },
              icon: Icon(Icons.bar_chart_outlined),
              label: Text('Lihat Laporan & Statistik'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Tambahkan navigasi ke halaman manajemen pengguna
              },
              icon: Icon(Icons.verified_user_outlined),
              label: Text('Manajemen Pengguna'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN HALAMAN PROFIL (DENGAN LOGOUT) ---
  Widget _buildProfileScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue[800], // Sesuaikan warna
            child: Icon(Icons.policy_outlined, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            widget.userData['name'] ?? 'Akun Pemerintah',
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

  // --- FUNGSI UNTUK MENAMPILKAN DIALOG KONFIRMASI LOGOUT ---
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

  // --- FUNGSI LOGOUT YANG BENAR (MEMANGGIL AUTHSERVICE) ---
  Future<void> _logout() async {
    await AuthService().signOut();
    // AuthWrapper akan otomatis mengarahkan ke halaman login setelah ini
  }
}
