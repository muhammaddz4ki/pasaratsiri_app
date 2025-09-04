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
        title: const Text('Distribusi Produk'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DistillationBatch>>(
        future: _batchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data batch produk.'));
          }

          final batches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];
              return _buildDistributionCard(batch);
            },
          );
        },
      ),
    );
  }

  Widget _buildDistributionCard(DistillationBatch batch) {
    bool isReady = batch.productStatus == ProductStatus.readyForSale;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${batch.id} - ${batch.rawMaterial}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Volume: ${batch.producedOilVolume} ml | Tgl: ${DateFormat('dd/MM/yy').format(batch.distillationDate)}',
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: TextStyle(color: Colors.grey[700])),
                Row(
                  children: [
                    Text(
                      isReady ? 'Siap Jual' : 'Dalam Proses',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isReady ? Colors.green : Colors.orange,
                      ),
                    ),
                    Switch(
                      value: isReady,
                      onChanged: (value) {
                        _updateStatus(batch, value);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
