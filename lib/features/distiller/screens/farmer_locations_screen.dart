import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasaratsiri_app/features/distiller/models/farmer_location_model.dart';
import 'package:pasaratsiri_app/features/distiller/widgets/farmer_search_delegate.dart';

class FarmerLocationsScreen extends StatefulWidget {
  const FarmerLocationsScreen({super.key});

  @override
  State<FarmerLocationsScreen> createState() => _FarmerLocationsScreenState();
}

class _FarmerLocationsScreenState extends State<FarmerLocationsScreen> {
  List<FarmerLocationModel> _allFarmers = [];
  bool _isLoading = true;

  // Warna dari distiller dashboard
  static const Color themeColor = Color(0xFFEA580C);

  @override
  void initState() {
    super.initState();
    _loadFarmerLocations();
  }

  Future<void> _loadFarmerLocations() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/farmer_locations.json',
    );
    final jsonResponse = json.decode(jsonString) as List;
    if (mounted) {
      setState(() {
        _allFarmers = jsonResponse
            .map((data) => FarmerLocationModel.fromJson(data))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _openSearch() async {
    await showSearch<FarmerLocationModel?>(
      context: context,
      delegate: FarmerSearchDelegate(allFarmers: _allFarmers),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5), // Latar belakang oranye muda
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Peta Lokasi Petani Terdekat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMapView(),
              const SizedBox(height: 16),
              const Text(
                'Cari Petani Terdaftar',
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 10),
            Text(
              _isLoading ? 'Memuat data petani...' : 'Ketik nama petani...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
