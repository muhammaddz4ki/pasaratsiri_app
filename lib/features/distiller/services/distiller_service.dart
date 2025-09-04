import '../models/distillation_batch_model.dart';

class DistillerService {
  // --- Data Dummy ---
  // Ini adalah data sementara untuk simulasi.
  // Nantinya, data ini akan diambil dari Firebase/Firestore.
  final List<DistillationBatch> _dummyBatches = [
    DistillationBatch(
      id: 'B001',
      rawMaterial: 'Daun Sereh Wangi',
      rawMaterialWeight: 150.5,
      producedOilVolume: 1200,
      distillationDate: DateTime.now().subtract(const Duration(days: 5)),
      qualityNotes: 'Warna kuning jernih, aroma kuat.',
      productStatus: ProductStatus.readyForSale,
      qualityStatus: QualityStatus.verified,
      qualityReportUrl: 'path/to/dummy_report.pdf',
    ),
    DistillationBatch(
      id: 'B002',
      rawMaterial: 'Akar Wangi',
      rawMaterialWeight: 200.0,
      producedOilVolume: 950,
      distillationDate: DateTime.now().subtract(const Duration(days: 2)),
      qualityNotes: 'Cukup baik, perlu penyaringan ulang.',
      productStatus: ProductStatus.inProcess,
      qualityStatus: QualityStatus.pending,
    ),
    DistillationBatch(
      id: 'B003',
      rawMaterial: 'Daun Cengkeh',
      rawMaterialWeight: 120.0,
      producedOilVolume: 1500,
      distillationDate: DateTime.now().subtract(const Duration(days: 1)),
      qualityNotes: 'Kualitas ekspor.',
      productStatus: ProductStatus.readyForSale,
      qualityStatus: QualityStatus.pending,
    ),
  ];

  // --- Fungsi-fungsi ---

  // Mengambil semua batch penyulingan
  Future<List<DistillationBatch>> getDistillationBatches() async {
    // Simulasi penundaan jaringan (network delay)
    await Future.delayed(const Duration(seconds: 1));
    return _dummyBatches;
  }

  // Menambah batch penyulingan baru
  Future<void> addDistillationBatch(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newBatch = DistillationBatch(
      id: 'B00${_dummyBatches.length + 1}', // ID sementara
      rawMaterial: data['rawMaterial'],
      rawMaterialWeight: data['rawMaterialWeight'],
      producedOilVolume: data['producedOilVolume'],
      distillationDate: DateTime.now(),
      qualityNotes: data['qualityNotes'],
    );
    _dummyBatches.insert(0, newBatch); // Tambahkan di awal daftar
  }

  // Mengupdate status produk (siap jual / dalam proses)
  Future<void> updateProductStatus(
    String batchId,
    ProductStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _dummyBatches.indexWhere((batch) => batch.id == batchId);
    if (index != -1) {
      _dummyBatches[index].productStatus = newStatus;
    }
  }

  // Mengupload laporan mutu (simulasi)
  Future<void> uploadQualityReport(String batchId, String filePath) async {
    await Future.delayed(const Duration(seconds: 2)); // simulasi upload
    final index = _dummyBatches.indexWhere((batch) => batch.id == batchId);
    if (index != -1) {
      _dummyBatches[index].qualityReportUrl = filePath;
      _dummyBatches[index].qualityStatus = QualityStatus
          .pending; // Status kembali ke pending untuk diverifikasi pemerintah
    }
  }
}
