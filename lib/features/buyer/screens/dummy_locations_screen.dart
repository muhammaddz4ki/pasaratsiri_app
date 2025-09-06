import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasaratsiri_app/features/buyer/models/combined_location_model.dart';
import 'package:pasaratsiri_app/features/buyer/screens/location_detail_screen.dart';
import 'package:pasaratsiri_app/features/buyer/widgets/location_search_delegate.dart';

class DummyLocationsScreen extends StatefulWidget {
  const DummyLocationsScreen({super.key});

  @override
  State<DummyLocationsScreen> createState() => _DummyLocationsScreenState();
}

class _DummyLocationsScreenState extends State<DummyLocationsScreen> {
  List<CombinedLocationModel> _allLocations = [];
  bool _isLoading = true;

  // Warna konsisten dari tema Buyer
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);
  static const Color lightGrey = Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/combined_locations.json',
      );
      final jsonResponse = json.decode(jsonString) as List;
      if (mounted) {
        setState(() {
          _allLocations = jsonResponse
              .map((data) => CombinedLocationModel.fromJson(data))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading location data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openSearch() async {
    final selectedLocation = await showSearch<CombinedLocationModel?>(
      context: context,
      delegate: LocationSearchDelegate(allLocations: _allLocations),
    );

    if (mounted && selectedLocation != null) {
      _navigateToDetail(selectedLocation);
    }
  }

  void _navigateToDetail(CombinedLocationModel location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailScreen(location: location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserLocationCard(),
              const SizedBox(height: 24),
              _buildMapSection(),
              const SizedBox(height: 24),
              _buildSearchSection(),
              const SizedBox(height: 24),
              _buildLocationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.my_location, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lokasi Anda',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Kp.Sukadana, Blubur Limbangan, Garut',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasi Terdekat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/peta_dummy.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cari Lokasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _isLoading ? null : _openSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: _isLoading ? Colors.grey[400] : darkColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoading
                        ? 'Memuat data...'
                        : 'Cari petani atau penyuling...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semua Lokasi Terdaftar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: primaryColor))
        else if (_allLocations.isEmpty)
          const Center(child: Text('Tidak ada lokasi yang ditemukan.'))
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _allLocations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildLocationCard(_allLocations[index]);
            },
          ),
      ],
    );
  }

  Widget _buildLocationCard(CombinedLocationModel location) {
    bool isPetani = location.jenis == 'Petani';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(location),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPetani
                          ? [primaryColor, const Color(0xFF34D399)]
                          : [darkColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPetani ? Icons.grass_rounded : Icons.science_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPetani
                              ? primaryColor.withOpacity(0.1)
                              : darkColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          location.jenis,
                          style: TextStyle(
                            color: isPetani ? primaryColor : darkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
