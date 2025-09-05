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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFF59E0B); // Amber-500
      case 'Dikirim':
        return const Color(0xFF10B981); // Emerald-500
      case 'Selesai':
        return const Color(0xFF059669); // Emerald-600
      case 'Dibatalkan':
        return const Color(0xFFEF4444); // Red-500
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF047857), // Emerald-700
                Color(0xFF10B981), // Emerald-500
                Color(0xFF14B8A6), // Teal-500
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.1),
                        const Color(0xFF14B8A6).withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memuat pesanan...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pesanan $status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua pesanan dengan status "$status" akan muncul di sini',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gagal memuat data pesanan',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
    final totalPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(data['totalPrice'] ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF0FDF4), // Emerald-50
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD1FAE5).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pesanan dari: ${data['userName'] ?? 'Pembeli'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    totalPrice,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tampilkan tombol aksi HANYA jika status 'Diproses' (di tab 'Baru')
              if (status == 'Diproses')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            // Changed from onPressed to onTap
                            _orderService.updateOrderStatus(
                              orderId: doc.id,
                              newStatus: 'Dibatalkan',
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text(
                              'Tolak',
                              style: TextStyle(
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            // Changed from onPressed to onTap
                            _orderService.updateOrderStatus(
                              orderId: doc.id,
                              newStatus: 'Dikirim',
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Text(
                              'Terima & Kirim',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
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
