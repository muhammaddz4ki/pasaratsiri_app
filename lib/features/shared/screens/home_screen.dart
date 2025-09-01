import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import '../../farmer/screens/farmer_dashboard.dart';
import '../../buyer/screens/buyer_dashboard.dart'; // Pastikan path import ini benar
import '../../distiller/screens/distiller_dashboard.dart';
import '../../government/screens/government_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final data = await _authService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  // Widget untuk memilih dashboard yang akan ditampilkan
  Widget _buildRoleBasedDashboard() {
    if (_userData == null) {
      // Menunggu atau jika terjadi error saat mengambil data
      return const Center(child: Text('Data pengguna tidak ditemukan.'));
    }

    final String role = _userData!['role'] ?? '';

    // Logika switch diperbarui untuk semua role
    switch (role) {
      case 'petani':
        return PetaniDashboard(userData: _userData!);
      case 'pembeli':
        return PembeliDashboard(userData: _userData!);
      case 'penyulingan':
        return UnitPenyulinganDashboard(userData: _userData!);
      case 'pemerintah':
        return PemerintahDashboard(userData: _userData!);
      default:
        // Tampilan default jika role tidak dikenali
        return Center(
          child: Text('Selamat Datang, ${(_userData!['name']) ?? ''}'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold di sini TIDAK LAGI memiliki AppBar
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildRoleBasedDashboard(),
    );
  }
}
