import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/buyer/services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${orderId.substring(0, 6)}...'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Pesanan tidak ditemukan.'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic> items = data['items'] ?? [];
          DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
          String formattedDate = DateFormat(
            'dd MMMM yyyy, HH:mm',
          ).format(createdAt);
          String status = data['status'] ?? '';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal Pesan: $formattedDate'),
                      const SizedBox(height: 8),
                      Text('Alamat: ${data['shippingAddress']}'),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${data['status']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: Rp ${data['totalPrice'].toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Item yang Dipesan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...items.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(item['productName'] ?? ''),
                    subtitle: Text('Rp ${item['price']}'),
                    trailing: Text('x ${item['quantity']}'),
                  ),
                );
              }).toList(),
              const SizedBox(height: 32),
              if (status == 'Menunggu Pembayaran')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Saya Sudah Bayar (Dummy)'),
                      onPressed: () async {
                        await orderService.updateOrderStatus(
                          orderId: orderId,
                          newStatus: 'Diproses',
                        );
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Batalkan Pesanan'),
                      onPressed: () async {
                        await orderService.updateOrderStatus(
                          orderId: orderId,
                          newStatus: 'Dibatalkan',
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              if (status == 'Dikirim')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Pesanan Sudah Diterima'),
                  onPressed: () async {
                    await orderService.updateOrderStatus(
                      orderId: orderId,
                      newStatus: 'Selesai',
                    );
                    Navigator.pop(context);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
