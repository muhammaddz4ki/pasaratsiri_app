// Enum untuk status distribusi produk
enum ProductStatus { inProcess, readyForSale }

// Enum untuk status verifikasi mutu
enum QualityStatus { pending, verified, rejected }

class DistillationBatch {
  final String id;
  final String rawMaterial; // Bahan baku (e.g., Daun Sereh)
  final double rawMaterialWeight; // Berat bahan baku (kg)
  final double producedOilVolume; // Hasil minyak (ml)
  final DateTime distillationDate;
  final String qualityNotes; // Catatan kualitas dari penyuling
  ProductStatus productStatus;
  QualityStatus qualityStatus;
  String? qualityReportUrl; // URL file hasil uji lab

  DistillationBatch({
    required this.id,
    required this.rawMaterial,
    required this.rawMaterialWeight,
    required this.producedOilVolume,
    required this.distillationDate,
    this.qualityNotes = '',
    this.productStatus = ProductStatus.inProcess,
    this.qualityStatus = QualityStatus.pending,
    this.qualityReportUrl,
  });

  // Nanti bisa ditambahkan factory constructor untuk konversi dari/ke Firebase
  // factory DistillationBatch.fromFirestore(DocumentSnapshot doc) { ... }
  // Map<String, dynamic> toFirestore() { ... }
}
