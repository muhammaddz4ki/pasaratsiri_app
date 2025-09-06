import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasaratsiri_app/features/distiller/models/farmer_location_model.dart';
import 'package:pasaratsiri_app/features/distiller/widgets/farmer_search_delegate.dart';
import 'farmer_detail_screen.dart';

class FarmerLocationsScreen extends StatefulWidget {
  const FarmerLocationsScreen({super.key});

  @override
  State<FarmerLocationsScreen> createState() => _FarmerLocationsScreenState();
}

class _FarmerLocationsScreenState extends State<FarmerLocationsScreen> {
  List<FarmerLocationModel> _allFarmers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Warna dari distiller dashboard
  static const Color themeColor = Color(0xFFEA580C);
  static const Color ultraLightOrange = Color(0xFFFFFAF5);

  @override
  void initState() {
    super.initState();
    _loadFarmerLocations();
  }

  Future<void> _loadFarmerLocations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Loading farmer data...'); // Debug log

      // Coba load dari assets, jika gagal gunakan data sample
      String jsonString;
      try {
        jsonString = await rootBundle.loadString(
          'assets/data/farmer_locations.json',
        );
        print('JSON loaded from assets successfully'); // Debug log
      } catch (e) {
        print('Failed to load from assets, using sample data: $e');
        // Jika file tidak ada, langsung gunakan data sample
        _createSampleDataSilent();
        return;
      }

      print('JSON length: ${jsonString.length} characters'); // Debug log

      if (jsonString.isEmpty) {
        print('JSON file is empty, using sample data');
        _createSampleDataSilent();
        return;
      }

      final dynamic jsonData = json.decode(jsonString);
      print('JSON decoded successfully'); // Debug log
      print('JSON type: ${jsonData.runtimeType}'); // Debug log

      List<dynamic> jsonResponse;

      // Handle berbagai struktur JSON
      if (jsonData is List) {
        jsonResponse = jsonData;
      } else if (jsonData is Map<String, dynamic>) {
        // Jika JSON dalam format {"farmers": [...]} atau {"data": [...]}
        if (jsonData.containsKey('farmers')) {
          jsonResponse = jsonData['farmers'] as List;
        } else if (jsonData.containsKey('data')) {
          jsonResponse = jsonData['data'] as List;
        } else {
          // Jika hanya satu objek, bungkus dalam list
          jsonResponse = [jsonData];
        }
      } else {
        print('Unsupported JSON format, using sample data');
        _createSampleDataSilent();
        return;
      }

      print(
        'JSON parsed successfully, items: ${jsonResponse.length}',
      ); // Debug log

      if (mounted) {
        final List<FarmerLocationModel> farmers = [];

        for (int i = 0; i < jsonResponse.length; i++) {
          try {
            final farmerData = jsonResponse[i];
            print(
              'Processing farmer $i: ${farmerData['nama'] ?? farmerData['name'] ?? 'Unknown'}',
            ); // Debug log
            print(
              'Raw farmer data: $farmerData',
            ); // Debug tambahan untuk melihat struktur data

            // Convert format JSON lama ke format yang diharapkan model
            final convertedData = _convertOldJsonFormat(farmerData);

            final farmer = FarmerLocationModel.fromJson(convertedData);
            farmers.add(farmer);
          } catch (e) {
            print('Error parsing farmer at index $i: $e');
            print('Farmer data: ${jsonResponse[i]}'); // Debug log
            // Lanjutkan ke data berikutnya, jangan crash
          }
        }

        setState(() {
          _allFarmers = farmers;
          _isLoading = false;
        });

        print(
          'Farmers loaded successfully: ${_allFarmers.length}',
        ); // Debug log

        // Jika tidak ada data valid atau parsing gagal, gunakan sample data
        if (_allFarmers.isEmpty) {
          print('No valid farmers found, using sample data');
          _createSampleDataSilent();
        } else if (_allFarmers.first.name == 'Data Error' ||
            _allFarmers.first.name == 'Nama tidak tersedia' ||
            _allFarmers.every(
              (farmer) => farmer.name == 'Nama tidak tersedia',
            )) {
          print('All farmers have parsing errors, using sample data');
          _createSampleDataSilent();
        } else {
          // Debug: Print first farmer if available
          print('First farmer: ${_allFarmers.first.name}');
        }
      }
    } catch (e) {
      print('Error loading farmers: $e'); // Debug log
      print('Error type: ${e.runtimeType}'); // Debug log

      if (mounted) {
        // Jika ada error apapun, gunakan data sample
        _createSampleDataSilent();
      }
    }
  }

  void _openSearch() async {
    if (_allFarmers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data petani untuk dicari'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showSearch<FarmerLocationModel?>(
      context: context,
      delegate: FarmerSearchDelegate(allFarmers: _allFarmers),
    );

    // Handle hasil pencarian jika perlu
    if (result != null) {
      _navigateToFarmerDetail(result);
    }
  }

  void _navigateToFarmerDetail(FarmerLocationModel farmer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerDetailScreen(farmer: farmer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ultraLightOrange,
      body: RefreshIndicator(
        onRefresh: _loadFarmerLocations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KARTU LOKASI PENGGUNA
                _buildUserLocationCard(),
                const SizedBox(height: 32),

                // SECTION PETA
                _buildMapSection(),
                const SizedBox(height: 32),

                // SECTION PENCARIAN
                _buildSearchSection(),
                const SizedBox(height: 32),

                // DAFTAR PETANI TERDAFTAR
                _buildFarmersList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET KARTU LOKASI PENGGUNA
  Widget _buildUserLocationCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor.withOpacity(0.1), ultraLightOrange],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kp.Sukadana, Blubur Limbangan, Garut',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(Icons.gps_fixed, color: Colors.green[600], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_outlined, color: themeColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Peta Lokasi Petani Terdekat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/peta_dummy.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_allFarmers.length} Petani',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
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
        Row(
          children: [
            Icon(Icons.search, color: themeColor, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Cari Petani Terdaftar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _isLoading ? null : _openSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: _isLoading ? Colors.grey[400] : themeColor,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isLoading
                        ? 'Memuat data petani...'
                        : 'Ketik nama petani atau lokasi...',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET DAFTAR PETANI TERDAFTAR
  Widget _buildFarmersList() {
    if (_isLoading) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Memuat data petani...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Filter out error data jika ada (data dengan id = 0)
    final validFarmers = _allFarmers.where((farmer) => farmer.id != 0).toList();

    if (validFarmers.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.agriculture_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sedang memuat data petani...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFarmerLocations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Coba Lagi', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline, color: themeColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Daftar Petani Terdaftar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${validFarmers.length}',
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: validFarmers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final farmer = validFarmers[index];
            return _buildFarmerCard(farmer);
          },
        ),
      ],
    );
  }

  // Fungsi untuk convert format JSON lama ke format baru
  Map<String, dynamic> _convertOldJsonFormat(Map<String, dynamic> oldData) {
    // Mapping dari format lama ke format baru
    return {
      'id':
          oldData['id'] ??
          (_allFarmers.length + 1), // Generate ID jika tidak ada
      'name': oldData['nama'] ?? oldData['name'] ?? 'Nama tidak tersedia',
      'owner':
          oldData['pemilik'] ?? oldData['owner'] ?? 'Pemilik tidak diketahui',
      'address':
          oldData['alamat'] ?? oldData['address'] ?? 'Alamat tidak tersedia',
      'district':
          oldData['kecamatan'] ??
          oldData['district'] ??
          'Kecamatan tidak tersedia',
      'subDistrict': oldData['kelurahan'] ?? oldData['subDistrict'],
      'village': oldData['desa'] ?? oldData['village'],
      'phone': oldData['telepon'] ?? oldData['phone'],
      'whatsapp': oldData['wa'] ?? oldData['whatsapp'],
      'email': oldData['email'],
      'farmSize':
          oldData['luasLahan'] ?? oldData['farmSize'] ?? 'Tidak diketahui',
      'crops': oldData['tanaman'] ?? oldData['crops'],
      'products': oldData['produk'] ?? oldData['products'],
      'certification': oldData['sertifikat'] ?? oldData['certification'],
      'farmingExperience':
          oldData['pengalaman'] ?? oldData['farmingExperience'] ?? 5,
      'harvestSeason': oldData['musimPanen'] ?? oldData['harvestSeason'],
      'productionCapacity':
          oldData['kapasitasProduksi'] ?? oldData['productionCapacity'],
      'rating': (oldData['rating'] as num?)?.toDouble() ?? 4.0,
      'latitude': oldData['lat'] ?? oldData['latitude'],
      'longitude': oldData['lng'] ?? oldData['longitude'],
      'status': oldData['status'] ?? 'Aktif',
      'pricePerKg': oldData['hargaPerKg'] ?? oldData['pricePerKg'],
      'minOrder': oldData['minOrder'],
      'paymentMethods':
          oldData['metodePembayaran'] ?? oldData['paymentMethods'],
      'deliveryRadius': oldData['radiusKirim'] ?? oldData['deliveryRadius'],
      'website': oldData['website'],
      'socialMedia': oldData['medsos'] ?? oldData['socialMedia'],
      'facilities': oldData['fasilitas'] ?? oldData['facilities'],
      'languages': oldData['bahasa'] ?? oldData['languages'],
      'farmingMethods': oldData['metodeBertani'] ?? oldData['farmingMethods'],
      'irrigationSystem':
          oldData['sistemIrigasi'] ?? oldData['irrigationSystem'],
      'soilType': oldData['jenisLahan'] ?? oldData['soilType'],
      'description':
          oldData['deskripsi'] ??
          oldData['description'] ??
          'Petani ${oldData['jenis'] ?? 'lokal'} yang terpercaya dengan produk berkualitas.',
      'images': oldData['gambar'] ?? oldData['images'],
      'lastUpdated': oldData['terakhirUpdate'] ?? oldData['lastUpdated'],
    };
  }

  // Fungsi untuk membuat data sample secara silent (tanpa notifikasi)
  void _createSampleDataSilent() {
    final sampleFarmers = [
      FarmerLocationModel(
        id: 1,
        name: 'Kebun Padi Sukamaju',
        owner: 'Bapak Suharto',
        address: 'Jl. Raya Sukamaju No. 123',
        district: 'Sukamaju',
        village: 'Sukamaju Utara',
        phone: '08123456789',
        whatsapp: '08123456789',
        email: 'suharto@email.com',
        farmSize: '2.5 Ha',
        crops: ['Padi', 'Jagung'],
        products: ['Beras', 'Jagung Pipil'],
        rating: 4.5,
        status: 'Aktif',
        pricePerKg: 7500,
        farmingExperience: 15,
        harvestSeason: 'Maret - April',
        productionCapacity: '10 Ton/Panen',
        description:
            'Petani berpengalaman dengan hasil panen berkualitas tinggi.',
      ),
      FarmerLocationModel(
        id: 2,
        name: 'Kebun Organik Harapan',
        owner: 'Ibu Siti Aminah',
        address: 'Kampung Babakan RT 02/05',
        district: 'Babakan Madang',
        village: 'Babakan',
        phone: '08987654321',
        whatsapp: '08987654321',
        farmSize: '1.8 Ha',
        crops: ['Sayuran Organik', 'Cabai'],
        products: ['Kangkung', 'Bayam', 'Cabai Rawit'],
        certification: ['Organik Indonesia'],
        rating: 4.8,
        status: 'Aktif',
        pricePerKg: 15000,
        farmingExperience: 8,
        harvestSeason: 'Sepanjang Tahun',
        productionCapacity: '500 Kg/Bulan',
        description: 'Spesialis sayuran organik dengan sertifikat resmi.',
      ),
      FarmerLocationModel(
        id: 3,
        name: 'Perkebunan Cengkeh Makmur',
        owner: 'Bapak Ahmad Yani',
        address: 'Dusun Cengkeh Raya',
        district: 'Gunung Sindur',
        village: 'Cengkeh',
        phone: '08111222333',
        farmSize: '5.0 Ha',
        crops: ['Cengkeh', 'Kopi'],
        products: ['Cengkeh Kering', 'Biji Kopi'],
        rating: 4.2,
        status: 'Aktif',
        pricePerKg: 120000,
        farmingExperience: 25,
        harvestSeason: 'September - November',
        productionCapacity: '2 Ton/Panen',
        description: 'Perkebunan cengkeh tradisional dengan kualitas ekspor.',
      ),
      FarmerLocationModel(
        id: 4,
        name: 'Kebun Sayur Hidroponik Modern',
        owner: 'Bapak Joko Susanto',
        address: 'Kompleks Agro Modern Blok A-15',
        district: 'Cileungsi',
        village: 'Cileungsi Kidul',
        phone: '08567890123',
        whatsapp: '08567890123',
        email: 'joko.hidroponik@email.com',
        farmSize: '0.5 Ha',
        crops: ['Selada', 'Tomat Cherry', 'Sawi'],
        products: ['Selada Hidroponik', 'Tomat Cherry', 'Sawi Hijau'],
        certification: ['Good Agricultural Practices'],
        rating: 4.7,
        status: 'Aktif',
        pricePerKg: 25000,
        farmingExperience: 5,
        harvestSeason: 'Sepanjang Tahun',
        productionCapacity: '200 Kg/Bulan',
        description: 'Kebun sayur modern dengan teknologi hidroponik terkini.',
      ),
      FarmerLocationModel(
        id: 5,
        name: 'Perkebunan Buah Naga Sejahtera',
        owner: 'Ibu Ratna Dewi',
        address: 'Kp. Buah Naga RT 03/07',
        district: 'Parung',
        village: 'Cogreg',
        phone: '08765432109',
        whatsapp: '08765432109',
        farmSize: '3.0 Ha',
        crops: ['Buah Naga Merah', 'Buah Naga Putih'],
        products: ['Buah Naga Segar', 'Sirup Buah Naga'],
        rating: 4.6,
        status: 'Aktif',
        pricePerKg: 35000,
        farmingExperience: 12,
        harvestSeason: 'Mei - Agustus',
        productionCapacity: '1.5 Ton/Panen',
        description:
            'Perkebunan buah naga dengan varietas unggul dan rasa manis.',
      ),
    ];

    setState(() {
      _allFarmers = sampleFarmers;
      _isLoading = false;
      _errorMessage = '';
    });

    print('Sample data loaded successfully: ${_allFarmers.length} farmers');
  }

  // WIDGET KARTU PETANI INDIVIDUAL
  Widget _buildFarmerCard(FarmerLocationModel farmer) {
    return GestureDetector(
      onTap: () => _navigateToFarmerDetail(farmer),
      child: Container(
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
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      farmer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: themeColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Owner info
              Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    farmer.owner,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location info
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${farmer.address}, ${farmer.district}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bottom info row
              Row(
                children: [
                  // Farm size
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          farmer.farmSize,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${farmer.rating}',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: farmer.status == 'Aktif'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      farmer.status,
                      style: TextStyle(
                        color: farmer.status == 'Aktif'
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
