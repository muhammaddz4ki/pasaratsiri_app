import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/buyer/models/combined_location_model.dart';

class LocationDetailScreen extends StatelessWidget {
  final CombinedLocationModel location;

  const LocationDetailScreen({super.key, required this.location});

  // Warna konsisten dari tema Buyer
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);
  static const Color lightGrey = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;

  @override
  Widget build(BuildContext context) {
    bool isPetani = location.jenis == 'Petani';

    return Scaffold(
      backgroundColor: lightGrey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: primaryColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // --- PERUBAHAN BAGIAN HEADER ---
            flexibleSpace: FlexibleSpaceBar(
              // title sengaja dikosongkan untuk layout custom di background
              title: Text(''),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, darkColor],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Efek overlay gelap agar teks lebih terbaca
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    // Posisi untuk semua teks header
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            location.nama,
                            style: const TextStyle(
                              fontSize: 22, // Ukuran diperbesar sedikit
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 2, color: Colors.black54),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isPetani
                                    ? Icons.grass_rounded
                                    : Icons.science_outlined,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.address,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOwnerCard(),
                const SizedBox(height: 20),
                _buildContactCard(),
                const SizedBox(height: 20),
                if (isPetani) _buildFarmingInfoCard(),
                if (!isPetani) _buildOperationalCard(),
                const SizedBox(height: 20),
                _buildProductsCard(),
                const SizedBox(height: 20),
                if (location.description != null) _buildDescriptionCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    return _buildInfoCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: primaryColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pemilik',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  location.owner,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  location.rating.toString(),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return _buildInfoCard(
      title: 'Informasi Kontak',
      icon: Icons.contact_phone_outlined,
      child: Column(
        children: [
          // --- PERUBAHAN BAGIAN ALAMAT ---
          _buildInfoRow(
            Icons.location_on,
            'Alamat',
            location.address, // Hanya gunakan location.address
          ),
          if (location.phone != null)
            _buildInfoRow(Icons.phone, 'Telepon', location.phone!),
          if (location.whatsapp != null)
            _buildInfoRow(Icons.message, 'WhatsApp', location.whatsapp!),
          if (location.email != null)
            _buildInfoRow(Icons.email, 'Email', location.email!),
        ],
      ),
    );
  }

  Widget _buildFarmingInfoCard() {
    return _buildInfoCard(
      title: 'Informasi Pertanian',
      icon: Icons.agriculture_outlined,
      child: Column(
        children: [
          if (location.farmSize != null)
            _buildInfoRow(Icons.eco, 'Luas Lahan', location.farmSize!),
          if (location.farmingExperience != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Pengalaman',
              '${location.farmingExperience} tahun',
            ),
          if (location.harvestSeason != null)
            _buildInfoRow(
              Icons.schedule,
              'Musim Panen',
              location.harvestSeason!,
            ),
        ],
      ),
    );
  }

  Widget _buildOperationalCard() {
    return _buildInfoCard(
      title: 'Informasi Operasional',
      icon: Icons.factory_outlined,
      child: Column(
        children: [
          if (location.operatingHours != null)
            _buildInfoRow(
              Icons.schedule,
              'Jam Operasi',
              location.operatingHours!,
            ),
          if (location.capacity != null)
            _buildInfoRow(Icons.inventory_2, 'Kapasitas', location.capacity!),
          if (location.establishedYear != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Tahun Berdiri',
              location.establishedYear.toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsCard() {
    bool isPetani = location.jenis == 'Petani';
    List<String>? primaryList = isPetani ? location.crops : location.products;
    List<String>? secondaryList = isPetani
        ? location.products
        : location.certification;

    return _buildInfoCard(
      title: isPetani ? 'Tanaman & Produk' : 'Produk & Sertifikasi',
      icon: Icons.local_florist_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (primaryList != null && primaryList.isNotEmpty)
            _buildChipSection(
              isPetani ? 'Tanaman Utama' : 'Produk Utama',
              primaryList,
              primaryColor,
            ),
          if (secondaryList != null && secondaryList.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildChipSection(
              isPetani ? 'Produk Hasil' : 'Sertifikasi',
              secondaryList,
              darkColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildInfoCard(
      title: 'Deskripsi',
      icon: Icons.description_outlined,
      child: Text(
        location.description!,
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoCard({
    String? title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: darkColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Chip(
                  label: Text(item),
                  backgroundColor: color.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: color.withOpacity(0.2)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
