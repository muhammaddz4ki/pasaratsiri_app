// lib/buyer/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart'; // Sesuaikan path import ini

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final AuthService _authService = AuthService();

  ProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol kembali
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 24),
            Text('Nama', style: TextStyle(color: Colors.grey.shade600)),
            Text(
              userData['name'] ?? 'Nama tidak tersedia',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Email', style: TextStyle(color: Colors.grey.shade600)),
            Text(
              userData['email'] ?? 'Email tidak tersedia',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(), // Mendorong tombol ke bawah
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () async {
                  await _authService.signOut();
                  // Setelah logout, kembali ke halaman login dan hapus semua rute sebelumnya
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
