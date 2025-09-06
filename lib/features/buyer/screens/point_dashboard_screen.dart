// lib/features/buyer/screens/point_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/buyer/screens/point_history_screen.dart';
import 'package:pasaratsiri_app/features/buyer/services/point_service.dart';

// 1. DIUBAH MENJADI STATEFULWIDGET
class PointDashboardScreen extends StatefulWidget {
  const PointDashboardScreen({super.key});

  @override
  State<PointDashboardScreen> createState() => _PointDashboardScreenState();
}

class _PointDashboardScreenState extends State<PointDashboardScreen> {
  final PointService _pointService = PointService();
  bool _isLoading = false; // State untuk loading

  // Fungsi untuk menangani penukaran voucher
  void _handleRedeem(Map<String, dynamic> voucher) async {
    setState(() => _isLoading = true);

    final result = await _pointService.redeemVoucher(voucherData: voucher);

    setState(() => _isLoading = false);

    if (mounted) {
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher berhasil ditukar!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat pointFormat = NumberFormat.decimalPattern('id_ID');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Poin Saya'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IgnorePointer(
        ignoring: _isLoading, // Mencegah interaksi saat loading
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPointsHeader(context, _pointService, pointFormat),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tukarkan poinmu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'lebih banyak >',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVoucherSection(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Donasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDonationSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Tampilan loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 2. DATA VOUCHER DIPERLENGKAP
  Widget _buildVoucherSection() {
    final vouchers = [
      {
        'title': 'Voucher Discount 30%',
        'desc': 'Minimal belanja 3\$',
        'points': 10000,
        'discountValue': 30,
        'minSpend': 3,
      },
      {
        'title': 'Voucher Discount 50%',
        'desc': 'Minimal belanja 10\$',
        'points': 25000,
        'discountValue': 50,
        'minSpend': 10,
      },
      {
        'title': 'Voucher Discount 70%',
        'desc': 'Minimal belanja 20\$',
        'points': 50000,
        'discountValue': 70,
        'minSpend': 20,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vouchers.length,
      itemBuilder: (context, index) {
        final voucher = vouchers[index];
        return _buildRedeemableItem(
          title: voucher['title'] as String,
          description: voucher['desc'] as String,
          points: voucher['points'] as int,
          icon: Icons.card_giftcard,
          // 3. ONTAP MEMANGGIL FUNGSI _handleRedeem
          onTap: () => _handleRedeem(voucher),
        );
      },
    );
  }

  // Sisa kode di bawah ini tidak banyak berubah, hanya penyesuaian kecil
  Widget _buildDonationSection() {
    return _buildRedeemableItem(
      title: 'Yayasan Maju Sejahtera',
      description: 'Donasikan sebesar 2\$',
      points: 10000,
      icon: Icons.volunteer_activism,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur donasi belum tersedia')),
        );
      },
    );
  }

  Widget _buildRedeemableItem({
    required String title,
    required String description,
    required int points,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final NumberFormat pointFormat = NumberFormat.decimalPattern('id_ID');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  pointFormat.format(points),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFECFDF5),
              foregroundColor: const Color(0xFF047857),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHeader(
    BuildContext context,
    PointService pointService,
    NumberFormat formatter,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 30,
                color: Colors.white,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PointHistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'History >',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'My Points',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          StreamBuilder<int>(
            stream: pointService.getUserPointsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              final points = snapshot.data ?? 0;
              return Text(
                formatter.format(points),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            'Berlaku hingga 06 Sep 2026',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
