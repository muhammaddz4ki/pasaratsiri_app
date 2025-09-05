import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/buyer/services/order_service.dart';

class FarmerOrderListScreen extends StatefulWidget {
  const FarmerOrderListScreen({super.key});

  @override
  State<FarmerOrderListScreen> createState() => _FarmerOrderListScreenState();
}

class _FarmerOrderListScreenState extends State<FarmerOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();

  final List<String> _tabs = ['Baru', 'Dikirim', 'Selesai', 'Dibatalkan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusForTab(String tab) {
    switch (tab) {
      case 'Baru':
        return 'Diproses';
      case 'Dikirim':
        return 'Dikirim';
      case 'Selesai':
        return 'Selesai';
      case 'Dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Diproses';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Masuk'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((String tab) {
          final status = _getStatusForTab(tab);
          return _buildOrderList(status);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _orderService.getOrdersForFarmer(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('Tidak ada pesanan dengan status "$status".'),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            return _buildOrderCard(doc);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'N/A';
    final createdAt = (data['createdAt'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesanan dari: ${data['userName'] ?? 'Pembeli'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Text('Total: Rp ${data['totalPrice']}'),
            Text('Tanggal: $formattedDate'),
            const SizedBox(height: 12),

            // Tampilkan tombol aksi HANYA jika status 'Diproses' (di tab 'Baru')
            if (status == 'Diproses')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      _orderService.updateOrderStatus(
                        orderId: doc.id,
                        newStatus: 'Dibatalkan',
                      );
                    },
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _orderService.updateOrderStatus(
                        orderId: doc.id,
                        newStatus: 'Dikirim',
                      );
                    },
                    child: const Text('Terima & Kirim'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
