class LocationModel {
  final String nama;
  final String jenis;

  LocationModel({required this.nama, required this.jenis});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
    );
  }
}
