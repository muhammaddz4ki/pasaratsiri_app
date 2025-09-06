// lib/features/buyer/models/combined_location_model.dart
class CombinedLocationModel {
  final int id;
  final String nama;
  final String jenis; // "Petani" atau "Penyuling"
  final String owner;
  final String address;
  final String district;
  final String? village;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final double rating;
  final String status;
  final String? description;
  final List<String>? images;

  // Atribut spesifik Petani
  final String? farmSize;
  final int? farmingExperience;
  final String? harvestSeason;
  final List<String>? crops;

  // Atribut spesifik Penyuling
  final String? operatingHours;
  final String? capacity;
  final int? establishedYear;
  final List<String>? certification;

  // Atribut yang bisa dimiliki keduanya
  final List<String>? products;

  CombinedLocationModel({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.owner,
    required this.address,
    required this.district,
    this.village,
    this.phone,
    this.whatsapp,
    this.email,
    required this.rating,
    required this.status,
    this.description,
    this.images,
    this.farmSize,
    this.farmingExperience,
    this.harvestSeason,
    this.crops,
    this.operatingHours,
    this.capacity,
    this.establishedYear,
    this.certification,
    this.products,
  });

  factory CombinedLocationModel.fromJson(Map<String, dynamic> json) {
    return CombinedLocationModel(
      id: json['id'] ?? 0,
      // --- PERUBAHAN DI SINI ---
      nama:
          json['name'] ??
          'Nama Tidak Tersedia', // Diubah dari 'nama' menjadi 'name'
      // -------------------------
      jenis: json['jenis'] ?? 'Jenis Tidak Diketahui',
      owner: json['owner'] ?? 'Pemilik Tidak Diketahui',
      address: json['address'] ?? 'Alamat Tidak Tersedia',
      district: json['district'] ?? 'Distrik Tidak Tersedia',
      village: json['village'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Tidak Aktif',
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      farmSize: json['farmSize'],
      farmingExperience: json['farmingExperience'],
      harvestSeason: json['harvestSeason'],
      crops: json['crops'] != null ? List<String>.from(json['crops']) : null,
      operatingHours: json['operatingHours'],
      capacity: json['capacity'],
      establishedYear: json['establishedYear'],
      certification: json['certification'] != null
          ? List<String>.from(json['certification'])
          : null,
      products: json['products'] != null
          ? List<String>.from(json['products'])
          : null,
    );
  }
}
