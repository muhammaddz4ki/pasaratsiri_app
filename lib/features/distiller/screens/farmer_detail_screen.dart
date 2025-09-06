import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/distiller/models/farmer_location_model.dart';

class FarmerDetailScreen extends StatelessWidget {
  final FarmerLocationModel farmer;

  const FarmerDetailScreen({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          farmer.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2.0,
                color: Color.fromRGBO(0, 0, 0, 0.2),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF7B00), Color(0xFFEA580C), Color(0xFFFF4800)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama dan rating
            _buildHeader(),
            const SizedBox(height: 24),

            // Informasi kontak
            _buildSection(
              title: 'Informasi Kontak',
              icon: Icons.contact_phone_rounded,
              child: _buildContactInfo(),
            ),
            const SizedBox(height: 24),

            // Informasi pertanian
            _buildSection(
              title: 'Informasi Pertanian',
              icon: Icons.agriculture_rounded,
              child: _buildFarmingInfo(),
            ),
            const SizedBox(height: 24),

            // Informasi produk dan tanaman
            _buildSection(
              title: 'Tanaman & Produk',
              icon: Icons.local_florist_rounded,
              child: _buildProductsAndCrops(),
            ),
            const SizedBox(height: 24),

            // Deskripsi
            if (farmer.description != null)
              _buildSection(
                title: 'Deskripsi',
                icon: Icons.description_rounded,
                child: _buildDescription(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFEA580C), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7ED), Color(0xFFFFF0E1)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farmer.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pemilik: ${farmer.owner}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA500), Color(0xFFEA580C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      farmer.rating.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: farmer.status == 'Aktif'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  farmer.status,
                  style: TextStyle(
                    color: farmer.status == 'Aktif' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.location_on_rounded,
          'Alamat',
          '${farmer.address}, ${farmer.district}',
        ),
        if (farmer.phone != null)
          _buildInfoRow(Icons.phone_rounded, 'Telepon', farmer.phone!),
        if (farmer.whatsapp != null)
          _buildInfoRow(Icons.message_rounded, 'WhatsApp', farmer.whatsapp!),
        if (farmer.email != null)
          _buildInfoRow(Icons.email_rounded, 'Email', farmer.email!),
      ],
    );
  }

  Widget _buildFarmingInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.eco_rounded, 'Luas Lahan', farmer.farmSize),
        if (farmer.farmingExperience != null)
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Pengalaman Bertani',
            '${farmer.farmingExperience} tahun',
          ),
        if (farmer.harvestSeason != null)
          _buildInfoRow(
            Icons.schedule_rounded,
            'Musim Panen',
            farmer.harvestSeason!,
          ),
        if (farmer.productionCapacity != null)
          _buildInfoRow(
            Icons.inventory_rounded,
            'Kapasitas Produksi',
            farmer.productionCapacity!,
          ),
        if (farmer.pricePerKg != null)
          _buildInfoRow(
            Icons.attach_money_rounded,
            'Harga per Kg',
            'Rp ${farmer.pricePerKg!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          ),
      ],
    );
  }

  Widget _buildProductsAndCrops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (farmer.crops != null && farmer.crops!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tanaman',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: farmer.crops!
                    .map(
                      (crop) => Chip(
                        label: Text(crop, style: const TextStyle(fontSize: 13)),
                        backgroundColor: const Color(0xFFECFDF5),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        if (farmer.products != null && farmer.products!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Produk',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: farmer.products!
                    .map(
                      (product) => Chip(
                        label: Text(
                          product,
                          style: const TextStyle(fontSize: 13),
                        ),
                        backgroundColor: const Color(0xFFFFF7ED),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        if (farmer.certification != null && farmer.certification!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sertifikasi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: farmer.certification!
                    .map(
                      (cert) => Chip(
                        label: Text(cert, style: const TextStyle(fontSize: 13)),
                        backgroundColor: const Color(0xFFEFF6FF),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      farmer.description!,
      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFEA580C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
