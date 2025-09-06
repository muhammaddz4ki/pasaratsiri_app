class FarmerLocationModel {
  final int id;
  final String name;
  final String owner;
  final String address;
  final String district;
  final String? subDistrict;
  final String? village;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String farmSize;
  final List<String>? crops;
  final List<String>? products;
  final List<String>? certification;
  final int? farmingExperience;
  final String? harvestSeason;
  final String? productionCapacity;
  final double rating;
  final double? latitude;
  final double? longitude;
  final String status;
  final double? pricePerKg;
  final int? minOrder;
  final List<String>? paymentMethods;
  final String? deliveryRadius;
  final String? website;
  final Map<String, dynamic>? socialMedia;
  final List<String>? facilities;
  final List<String>? languages;
  final List<String>? farmingMethods;
  final String? irrigationSystem;
  final String? soilType;
  final String? description;
  final List<String>? images;
  final String? lastUpdated;

  FarmerLocationModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.address,
    required this.district,
    this.subDistrict,
    this.village,
    this.phone,
    this.whatsapp,
    this.email,
    required this.farmSize,
    this.crops,
    this.products,
    this.certification,
    this.farmingExperience,
    this.harvestSeason,
    this.productionCapacity,
    required this.rating,
    this.latitude,
    this.longitude,
    required this.status,
    this.pricePerKg,
    this.minOrder,
    this.paymentMethods,
    this.deliveryRadius,
    this.website,
    this.socialMedia,
    this.facilities,
    this.languages,
    this.farmingMethods,
    this.irrigationSystem,
    this.soilType,
    this.description,
    this.images,
    this.lastUpdated,
  });

  factory FarmerLocationModel.fromJson(Map<String, dynamic> json) {
    return FarmerLocationModel(
      id: json['id'] as int? ?? 0, // Handle null dengan default value
      name: json['name'] as String? ?? 'Nama tidak tersedia',
      owner: json['owner'] as String? ?? 'Pemilik tidak tersedia',
      address: json['address'] as String? ?? 'Alamat tidak tersedia',
      district: json['district'] as String? ?? 'Kecamatan tidak tersedia',
      subDistrict: json['subDistrict'] as String?,
      village: json['village'] as String?,
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      email: json['email'] as String?,
      farmSize: json['farmSize'] as String? ?? 'Luas tidak tersedia',
      crops: json['crops'] != null ? List<String>.from(json['crops']) : [],
      products: json['products'] != null
          ? List<String>.from(json['products'])
          : [],
      certification: json['certification'] != null
          ? List<String>.from(json['certification'])
          : [],
      farmingExperience: json['farmingExperience'] as int? ?? 0, // Handle null
      harvestSeason: json['harvestSeason'] as String?,
      productionCapacity: json['productionCapacity'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // Handle null
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      status: json['status'] as String? ?? 'Tidak diketahui',
      pricePerKg: json['pricePerKg'] != null
          ? (json['pricePerKg'] as num).toDouble()
          : null,
      minOrder: json['minOrder'] as int? ?? 0, // Handle null
      paymentMethods: json['paymentMethods'] != null
          ? List<String>.from(json['paymentMethods'])
          : [],
      deliveryRadius: json['deliveryRadius'] as String?,
      website: json['website'] as String?,
      socialMedia: json['socialMedia'] != null
          ? Map<String, dynamic>.from(json['socialMedia'])
          : {},
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      farmingMethods: json['farmingMethods'] != null
          ? List<String>.from(json['farmingMethods'])
          : [],
      irrigationSystem: json['irrigationSystem'] as String?,
      soilType: json['soilType'] as String?,
      description: json['description'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      lastUpdated: json['lastUpdated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'address': address,
      'district': district,
      'subDistrict': subDistrict,
      'village': village,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'farmSize': farmSize,
      'crops': crops,
      'products': products,
      'certification': certification,
      'farmingExperience': farmingExperience,
      'harvestSeason': harvestSeason,
      'productionCapacity': productionCapacity,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'pricePerKg': pricePerKg,
      'minOrder': minOrder,
      'paymentMethods': paymentMethods,
      'deliveryRadius': deliveryRadius,
      'website': website,
      'socialMedia': socialMedia,
      'facilities': facilities,
      'languages': languages,
      'farmingMethods': farmingMethods,
      'irrigationSystem': irrigationSystem,
      'soilType': soilType,
      'description': description,
      'images': images,
      'lastUpdated': lastUpdated,
    };
  }
}
