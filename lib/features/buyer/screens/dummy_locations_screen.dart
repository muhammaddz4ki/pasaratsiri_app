import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasaratsiri_app/features/buyer/models/location_model.dart';
import 'package:pasaratsiri_app/features/buyer/widgets/location_search_delegate.dart';

class DummyLocationsScreen extends StatefulWidget {
  const DummyLocationsScreen({super.key});

  @override
  State<DummyLocationsScreen> createState() => _DummyLocationsScreenState();
}

class _DummyLocationsScreenState extends State<DummyLocationsScreen> {
  List<LocationModel> _allLocations = [];
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations.json',
    );
    final jsonResponse = json.decode(jsonString) as List;
    if (mounted) {
      setState(() {
        _allLocations = jsonResponse
            .map((data) => LocationModel.fromJson(data))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _openSearch() async {
    final selectedLocation = await showSearch<LocationModel?>(
      context: context,
      delegate: LocationSearchDelegate(allLocations: _allLocations),
    );

    if (mounted && selectedLocation != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Anda memilih: ${selectedLocation.nama}'),
            backgroundColor: darkColor,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserLocationCard(),
              const SizedBox(height: 24),
              const Text(
                'Lokasi petani dan penyuling terdekat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMapView(),
              const SizedBox(height: 16),
              const Text(
                'Cari Lokasi petani dan penyuling',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Search Bar yang sudah interaktif
              _buildSearchTrigger(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk kartu lokasi pengguna
  Widget _buildUserLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor.withAlpha(128)),
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

  // Widget untuk menampilkan peta
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

  // Widget untuk memicu pencarian (bukan TextField biasa)
  Widget _buildSearchTrigger() {
    return GestureDetector(
      onTap: _isLoading ? null : _openSearch,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Text(
              _isLoading ? 'Sedang memuat data...' : 'Search',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
