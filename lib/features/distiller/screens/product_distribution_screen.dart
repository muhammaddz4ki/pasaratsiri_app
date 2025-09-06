import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/distillation_batch_model.dart';
import '../services/distiller_service.dart';

class ProductDistributionScreen extends StatefulWidget {
  const ProductDistributionScreen({super.key});

  @override
  State<ProductDistributionScreen> createState() =>
      _ProductDistributionScreenState();
}

class _ProductDistributionScreenState extends State<ProductDistributionScreen> {
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

  Future<void> _updateStatus(
    DistillationBatch batch,
    bool isReadyForSale,
  ) async {
    final newStatus = isReadyForSale
        ? ProductStatus.readyForSale
        : ProductStatus.inProcess;
    await _service.updateProductStatus(batch.id, newStatus);
    _loadBatches(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Distribusi Produk',
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED), Colors.white],
          ),
        ),
        child: FutureBuilder<List<DistillationBatch>>(
          future: _batchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEA580C)),
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
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.orange[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data batch produk',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Produk yang sudah dibuat akan muncul di sini',
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
                return _buildDistributionCard(batch);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDistributionCard(DistillationBatch batch) {
    bool isReady = batch.productStatus == ProductStatus.readyForSale;

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isReady
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isReady
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFFF3CD),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isReady ? 'Siap Jual' : 'Dalam Proses',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isReady
                            ? const Color(0xFF065F46)
                            : const Color(0xFF92400E),
                        fontSize: 12,
                      ),
                    ),
                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${batch.producedOilVolume} ml',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(batch.distillationDate),
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status Penjualan:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isReady ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isReady
                              ? const Color(0xFF065F46)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: isReady,
                          onChanged: (value) {
                            _updateStatus(batch, value);
                          },
                          activeColor: const Color(0xFF10B981),
                          activeTrackColor: const Color(0xFFA7F3D0),
                          inactiveThumbColor: const Color(0xFF9CA3AF),
                          inactiveTrackColor: const Color(0xFFE5E7EB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
