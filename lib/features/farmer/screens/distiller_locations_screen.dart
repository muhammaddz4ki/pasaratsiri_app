import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasaratsiri_app/features/farmer/models/distiller_location_model.dart';
import 'package:pasaratsiri_app/features/farmer/widgets/distiller_search_delegate.dart';

class DistillerLocationsScreen extends StatefulWidget {
  const DistillerLocationsScreen({super.key});

  @override
  State<DistillerLocationsScreen> createState() =>
      _DistillerLocationsScreenState();
}

class _DistillerLocationsScreenState extends State<DistillerLocationsScreen> {
  List<DistillerLocationModel> _allDistillers = [];
  bool _isLoading = true;

  // Warna dari farmer dashboard
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color ultraLightEmerald = Color(0xFFECFDF5);

  @override
  void initState() {
    super.initState();
    _loadDistillerLocations();
  }

  Future<void> _loadDistillerLocations() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/distiller_locations.json',
    );
    final jsonResponse = json.decode(jsonString) as List;
    if (mounted) {
      setState(() {
        _allDistillers = jsonResponse
            .map((data) => DistillerLocationModel.fromJson(data))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _openSearch() async {
    await showSearch<DistillerLocationModel?>(
      context: context,
      delegate: DistillerSearchDelegate(allDistillers: _allDistillers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            80,
            16,
            16,
          ), // Padding atas untuk AppBar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KARTU LOKASI PENGGUNA DITAMBAHKAN DI SINI
              _buildUserLocationCard(),
              const SizedBox(height: 24),

              const Text(
                'Peta Lokasi Penyuling Terdekat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMapView(),
              const SizedBox(height: 16),
              const Text(
                'Cari Penyuling Terdaftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSearchTrigger(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET KARTU LOKASI PENGGUNA (BARU DITAMBAHKAN)
  Widget _buildUserLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryEmerald.withAlpha(128)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi anda sesuai alamat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kp.Sukadana, Blubur Limbangan, ...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset('assets/images/peta_dummy.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildSearchTrigger() {
    return GestureDetector(
      onTap: _isLoading ? null : _openSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: ultraLightEmerald,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: primaryEmerald.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Text(
              _isLoading
                  ? 'Memuat data penyuling...'
                  : 'Ketik nama penyuling...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
