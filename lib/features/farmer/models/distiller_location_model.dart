class DistillerLocationModel {
  final String nama;
  final String jenis;

  DistillerLocationModel({required this.nama, required this.jenis});

  factory DistillerLocationModel.fromJson(Map<String, dynamic> json) {
    return DistillerLocationModel(
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
    );
  }
}
