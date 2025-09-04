import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/distillation_batch_model.dart';
import '../services/distiller_service.dart';
// import 'package:file_picker/file_picker.dart'; // Uncomment jika sudah siap upload

class ProductQualityScreen extends StatefulWidget {
  const ProductQualityScreen({super.key});

  @override
  State<ProductQualityScreen> createState() => _ProductQualityScreenState();
}

class _ProductQualityScreenState extends State<ProductQualityScreen> {
  final DistillerService _service = DistillerService();
  late Future<List<DistillationBatch>> _batchesFuture;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  void _loadBatches() {
    _batchesFuture = _service.getDistillationBatches();
  }

  // Fungsi untuk memilih dan upload file (saat ini simulasi)
  Future<void> _uploadReport(String batchId) async {
    // // Implementasi nyata dengan file_picker:
    // FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
    // if (result != null) {
    //   String filePath = result.files.single.path!;
    //   // Tampilkan loading indicator
    //   await _service.uploadQualityReport(batchId, filePath);
    //   // Refresh data
    //   setState(() {
    //     _loadBatches();
    //   });
    // }

    // Simulasi:
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simulasi upload laporan...')));
    await _service.uploadQualityReport(batchId, 'simulated/path/report.pdf');
    setState(() {
      _loadBatches();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan Terkirim & Menunggu Verifikasi'),
          backgroundColor: Colors.blue,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Mutu Produk'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadBatches();
          });
        },
        child: FutureBuilder<List<DistillationBatch>>(
          future: _batchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada data penyulingan.'));
            }

            final batches = snapshot.data!;
            return ListView.builder(
              itemCount: batches.length,
              itemBuilder: (context, index) {
                final batch = batches[index];
                return _buildQualityCard(batch);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildQualityCard(DistillationBatch batch) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${batch.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(batch.qualityStatus),
              ],
            ),
            const Divider(height: 20),
            Text('Bahan Baku: ${batch.rawMaterial}'),
            Text(
              'Tanggal: ${DateFormat('d MMMM yyyy').format(batch.distillationDate)}',
            ),
            const SizedBox(height: 16),
            if (batch.qualityReportUrl != null)
              Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Laporan terlampir.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _uploadReport(batch.id),
                icon: const Icon(Icons.upload_file),
                label: Text(
                  batch.qualityReportUrl == null
                      ? 'Upload Hasil Uji Lab'
                      : 'Upload Ulang',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(QualityStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case QualityStatus.verified:
        color = Colors.green;
        label = 'Terverifikasi';
        icon = Icons.check_circle;
        break;
      case QualityStatus.rejected:
        color = Colors.red;
        label = 'Ditolak';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_top;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
