class FarmerLocationModel {
  final String nama;
  final String jenis;

  FarmerLocationModel({required this.nama, required this.jenis});

  factory FarmerLocationModel.fromJson(Map<String, dynamic> json) {
    return FarmerLocationModel(
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
    );
  }
}
