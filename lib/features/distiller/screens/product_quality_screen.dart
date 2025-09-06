import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/distillation_batch_model.dart';
import '../services/distiller_service.dart';

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
    setState(() {
      _batchesFuture = _service.getDistillationBatches();
    });
  }

  Future<void> _uploadReport(String batchId) async {
    // Simulasi upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Simulasi upload laporan...'),
        backgroundColor: Colors.orange[700],
      ),
    );

    await Future.delayed(const Duration(seconds: 1));

    await _service.uploadQualityReport(batchId, 'simulated/path/report.pdf');

    setState(() {
      _loadBatches();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Laporan Terkirim & Menunggu Verifikasi'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manajemen Mutu Produk',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
      body: Container(
        color: Colors.white, // White background
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadBatches();
            });
          },
          color: const Color(0xFFEA580C),
          child: FutureBuilder<List<DistillationBatch>>(
            future: _batchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFEA580C),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBatches,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 64,
                        color: Colors.orange[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data penyulingan',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data batch penyulingan akan muncul di sini',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final batches = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: batches.length,
                itemBuilder: (context, index) {
                  final batch = batches[index];
                  return _buildQualityCard(batch);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQualityCard(DistillationBatch batch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFE4CC),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'ID: ${batch.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEA580C),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildStatusChip(batch.qualityStatus),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                batch.rawMaterial,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(batch.distillationDate),
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.producedOilVolume} ml',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (batch.qualityReportUrl != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        size: 20,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Terlampir',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Diupload pada ${DateFormat('dd/MM/yy HH:mm').format(DateTime.now())}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.visibility_rounded,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        onPressed: () {
                          // Action to view the report
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadReport(batch.id),
                  icon: Icon(
                    batch.qualityReportUrl == null
                        ? Icons.upload_rounded
                        : Icons.refresh_rounded,
                    size: 20,
                  ),
                  label: Text(
                    batch.qualityReportUrl == null
                        ? 'Upload Hasil Uji Lab'
                        : 'Upload Ulang Laporan',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shadowColor: Colors.orange.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(QualityStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case QualityStatus.verified:
        backgroundColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF065F46);
        label = 'Terverifikasi';
        icon = Icons.check_circle_rounded;
        break;
      case QualityStatus.rejected:
        backgroundColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFDC2626);
        label = 'Ditolak';
        icon = Icons.cancel_rounded;
        break;
      default:
        backgroundColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFF92400E);
        label = 'Menunggu';
        icon = Icons.access_time_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
