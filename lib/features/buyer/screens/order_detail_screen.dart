import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/buyer/services/order_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  // Warna konsisten dari dashboard
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);

  @override
  Widget build(BuildContext context) {
    final OrderService orderService = OrderService();
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Detail Pesanan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 1,
        centerTitle: true,
      ),
      // Menggunakan StreamBuilder agar status pesanan bisa update real-time
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
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

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildStatusCard(orderId, formattedDate, status),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Info Pengiriman',
                      icon: Icons.local_shipping_outlined,
                      child: Text(
                        data['shippingAddress'],
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentDetailsCard(data, currencyFormat),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      title: 'Produk Dipesan',
                      icon: Icons.inventory_2_outlined,
                      child: Column(
                        children: items
                            .map((item) => _buildItemRow(item, currencyFormat))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomActionBar(status, context, orderService, orderId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(String orderId, String date, String status) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan #${orderId.substring(0, 8)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: darkColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(
    Map<String, dynamic> data,
    NumberFormat format,
  ) {
    double subtotal = 0;
    List<dynamic> items = data['items'];
    for (var item in items) {
      subtotal += (item['price'] * item['quantity']);
    }

    final discountDetails = data['discountDetails'] as Map<String, dynamic>?;
    final double discountAmount = discountDetails?['discountAmount'] ?? 0.0;

    return _buildInfoCard(
      title: 'Rincian Pembayaran',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _summaryRow('Subtotal', format.format(subtotal)),
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Diskon',
              '- ${format.format(discountAmount)}',
              isDiscount: true,
            ),
          ],
          const Divider(height: 24),
          _summaryRow(
            'Total Pembayaran',
            format.format(data['totalPrice']),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? Colors.red
                : (isTotal ? darkColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, NumberFormat format) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(item['productId'])
            .get(),
        builder: (context, productSnapshot) {
          String imageUrl = 'https://via.placeholder.com/150';
          if (productSnapshot.hasData && productSnapshot.data!.exists) {
            final productData =
                productSnapshot.data!.data() as Map<String, dynamic>?;
            imageUrl = productData?['imageUrl'] ?? imageUrl;
          }
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
                      item['productName'] ?? 'Nama Produk',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item['quantity']} x ${format.format(item['price'])}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomActionBar(
    String status,
    BuildContext context,
    OrderService orderService,
    String orderId,
  ) {
    Widget actionButton;

    if (status == 'Menunggu Pembayaran') {
      actionButton = Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Batalkan Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () =>
                  _showCancelConfirmationDialog(context, orderService, orderId),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Saya Sudah Bayar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await orderService.updateOrderStatus(
                  orderId: orderId,
                  newStatus: 'Diproses',
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
        ],
      );
    } else if (status == 'Dikirim') {
      actionButton = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Pesanan Sudah Diterima',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          await orderService.updateOrderStatus(
            orderId: orderId,
            newStatus: 'Selesai',
          );
          if (context.mounted) Navigator.pop(context);
        },
      );
    } else {
      return const SizedBox.shrink(); // Tidak menampilkan apa-apa jika status lain
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: actionButton,
    );
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    OrderService orderService,
    String orderId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batalkan Pesanan?'),
          content: const Text(
            'Apakah Anda yakin ingin membatalkan pesanan ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Batalkan'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                await orderService.updateOrderStatus(
                  orderId: orderId,
                  newStatus: 'Dibatalkan',
                );
                if (context.mounted)
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
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
}
