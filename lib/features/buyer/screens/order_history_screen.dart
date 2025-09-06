import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/buyer/screens/add_review_screen.dart';
import 'package:pasaratsiri_app/features/shared/services/review_service.dart'; // <-- Pastikan import ini ada
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();
  final ReviewService _reviewService =
      ReviewService(); // <-- Tambahkan instance ReviewService
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedStatus = 'Semua';
  final List<String> _statuses = [
    'Semua',
    'Menunggu Pembayaran',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderService.getOrders(status: _selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyOrderView();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    return _buildOrderItemCard(doc);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.white,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _statuses.length,
          itemBuilder: (context, index) {
            final status = _statuses[index];
            bool isSelected = status == _selectedStatus;
            return _buildFilterChip(status, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String status, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
    String formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(createdAt);
    String status = data['status'] ?? 'Diproses';
    List<dynamic> items = data['items'] ?? [];

    int totalItems = 0;
    for (var item in items) {
      totalItems += (item['quantity'] as int);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: doc.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan #${doc.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            Text(
              formattedDate,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const Divider(height: 24),
            if (items.isNotEmpty) _buildProductPreview(items.first, totalItems),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Belanja',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(data['totalPrice']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
                // --- INI BAGIAN YANG DIPERBARUI ---
                if (status == 'Selesai' && items.isNotEmpty)
                  FutureBuilder<bool>(
                    future: _reviewService.hasUserReviewedOrder(doc.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      final bool hasReviewed = snapshot.data ?? false;

                      if (hasReviewed) {
                        // Jika sudah direview, tampilkan Chip non-aktif
                        return Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                          label: Text(
                            'Ulasan Dikirim',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          backgroundColor: Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        );
                      } else {
                        // Jika belum, tampilkan tombol "Beri Ulasan"
                        return OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReviewScreen(
                                  productId: items.first['productId'],
                                  orderId: doc.id,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Beri Ulasan'),
                        );
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPreview(Map<String, dynamic> item, int totalItems) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(item['productId'])
          .get(),
      builder: (context, productSnapshot) {
        if (!productSnapshot.hasData) {
          return const SizedBox(
            height: 60,
            child: Center(child: Text('Memuat produk...')),
          );
        }
        final productData =
            productSnapshot.data!.data() as Map<String, dynamic>?;
        final imageUrl =
            productData?['imageUrl'] ?? 'https://via.placeholder.com/150';

        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['productName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Total $totalItems Barang',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color foregroundColor;
    IconData iconData;

    switch (status) {
      case 'Selesai':
        backgroundColor = Colors.green.shade50;
        foregroundColor = Colors.green.shade800;
        iconData = Icons.check_circle;
        break;
      case 'Dibatalkan':
        backgroundColor = Colors.red.shade50;
        foregroundColor = Colors.red.shade800;
        iconData = Icons.cancel;
        break;
      case 'Dikirim':
        backgroundColor = Colors.blue.shade50;
        foregroundColor = Colors.blue.shade800;
        iconData = Icons.local_shipping;
        break;
      case 'Diproses':
        backgroundColor = Colors.orange.shade50;
        foregroundColor = Colors.orange.shade800;
        iconData = Icons.sync;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        foregroundColor = Colors.grey.shade800;
        iconData = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: foregroundColor, size: 14),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat pesanan Anda akan muncul di sini.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
