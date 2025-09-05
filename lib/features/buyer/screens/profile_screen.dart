// lib/buyer/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/services/auth_service.dart'; // Sesuaikan path import ini

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final AuthService _authService = AuthService();

  ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Mengambil inisial nama untuk ditampilkan jika tidak ada foto profil
    final String name = userData['name'] ?? 'Pengguna';
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      // Menggunakan warna background yang lebih lembut
      backgroundColor: Colors.grey[100],
      // Menghilangkan AppBar bawaan untuk header custom
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.blue.shade800,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, name, initial),
            const SizedBox(height: 20),
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildActionsCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat header profil
  Widget _buildProfileHeader(
    BuildContext context,
    String name,
    String initial,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            userData['email'] ?? 'Email tidak tersedia',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membuat kartu informasi pengguna
  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            _buildInfoTile(
              icon: Icons.person_outline,
              label: 'Nama Lengkap',
              value: userData['name'] ?? 'Tidak tersedia',
            ),
            _buildInfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: userData['email'] ?? 'Tidak tersedia',
            ),
            _buildInfoTile(
              icon: Icons.phone_outlined,
              label: 'Nomor Telepon',
              value: userData['phoneNumber'] ?? 'Belum ditambahkan',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk membuat kartu menu aksi
  Widget _buildActionsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            _buildActionTile(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              onTap: () {
                // TODO: Tambahkan navigasi ke halaman edit profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ini belum tersedia')),
                );
              },
            ),
            _buildActionTile(
              context: context,
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              onTap: () {
                // TODO: Tambahkan navigasi ke halaman pengaturan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ini belum tersedia')),
                );
              },
            ),
            _buildActionTile(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.red.shade700,
              onTap: () async {
                await _authService.signOut();
                // Kembali ke halaman login dan hapus semua rute sebelumnya
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk satu baris informasi (icon, label, value)
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget untuk satu baris aksi (icon, title, arrow)
  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              )
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color ?? Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: color ?? Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
