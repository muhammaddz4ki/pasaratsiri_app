class DistillerLocationModel {
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
  final String capacity;
  final List<String>? products;
  final List<String>? certification;
  final String operatingHours;
  final int? establishedYear;
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
  final String? description;
  final List<String>? images;
  final String? lastUpdated;

  DistillerLocationModel({
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
    required this.capacity,
    this.products,
    this.certification,
    required this.operatingHours,
    this.establishedYear,
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
    this.description,
    this.images,
    this.lastUpdated,
  });

  factory DistillerLocationModel.fromJson(Map<String, dynamic> json) {
    return DistillerLocationModel(
      id: json['id'],
      name: json['name'],
      owner: json['owner'],
      address: json['address'],
      district: json['district'],
      subDistrict: json['subDistrict'],
      village: json['village'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      capacity: json['capacity'],
      products: json['products'] != null
          ? List<String>.from(json['products'])
          : null,
      certification: json['certification'] != null
          ? List<String>.from(json['certification'])
          : null,
      operatingHours: json['operatingHours'],
      establishedYear: json['establishedYear'],
      rating: json['rating']?.toDouble() ?? 0.0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'],
      pricePerKg: json['pricePerKg']?.toDouble(),
      minOrder: json['minOrder'],
      paymentMethods: json['paymentMethods'] != null
          ? List<String>.from(json['paymentMethods'])
          : null,
      deliveryRadius: json['deliveryRadius'],
      website: json['website'],
      socialMedia: json['socialMedia'] != null
          ? Map<String, dynamic>.from(json['socialMedia'])
          : null,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      lastUpdated: json['lastUpdated'],
    );
  }
}
