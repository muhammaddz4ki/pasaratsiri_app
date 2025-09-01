import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart'; // <-- SESUAIKAN PATH INI

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
              title: const Text("Dashboard Penyulingan"),
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
        selectedItemColor: Colors.green,
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
      // Tambahkan SingleChildScrollView agar bisa di-scroll
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Unit Penyulingan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Selamat datang, ${widget.userData['name'] ?? ''}'),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Tambahkan navigasi ke halaman stok
              },
              icon: Icon(Icons.inventory_2_outlined),
              label: Text('Lihat Stok Bahan Baku'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Tambahkan navigasi ke halaman produksi
              },
              icon: Icon(Icons.science_outlined),
              label: Text('Kelola Proses Produksi'),
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
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
        crossAxisAlignment: CrossAxisAlignment.stretch, // Lebarkan tombol
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
              foregroundColor: Colors.white, // warna teks dan ikon
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
                Navigator.of(ctx).pop(); // Tutup dialog
                _logout(); // Panggil fungsi logout yang benar
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
    // Ini akan menghapus sesi login dari Firebase
    await AuthService().signOut();
    // AuthWrapper akan otomatis mengarahkan ke halaman login setelah ini
  }
}
