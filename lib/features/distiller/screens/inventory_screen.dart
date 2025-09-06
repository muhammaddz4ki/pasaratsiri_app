import 'package:flutter/material.dart';

enum InventoryStatus { good, low, critical }

class InventoryItem {
  final String id;
  final String name;
  final int currentStock;
  final int minStock;
  final String unit;
  final DateTime lastUpdated;
  final InventoryStatus status;

  InventoryItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.lastUpdated,
    required this.status,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<InventoryItem> rawMaterials = [
    InventoryItem(
      id: '1',
      name: 'Daun Nilam Kering',
      currentStock: 45,
      minStock: 50,
      unit: 'kg',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      status: InventoryStatus.low,
    ),
    InventoryItem(
      id: '2',
      name: 'Daun Nilam Basah',
      currentStock: 120,
      minStock: 100,
      unit: 'kg',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      status: InventoryStatus.good,
    ),
    InventoryItem(
      id: '3',
      name: 'Air Destilasi',
      currentStock: 500,
      minStock: 200,
      unit: 'L',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      status: InventoryStatus.good,
    ),
  ];

  final List<InventoryItem> finishedProducts = [
    InventoryItem(
      id: '4',
      name: 'Minyak Nilam Grade A',
      currentStock: 85,
      minStock: 50,
      unit: 'L',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      status: InventoryStatus.good,
    ),
    InventoryItem(
      id: '5',
      name: 'Minyak Nilam Grade B',
      currentStock: 25,
      minStock: 30,
      unit: 'L',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 3)),
      status: InventoryStatus.low,
    ),
    InventoryItem(
      id: '6',
      name: 'Minyak Nilam Grade C',
      currentStock: 15,
      minStock: 20,
      unit: 'L',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 6)),
      status: InventoryStatus.critical,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildQuickStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.good:
        return Colors.green;
      case InventoryStatus.low:
        return Colors.orange;
      case InventoryStatus.critical:
        return Colors.red;
    }
  }

  String _getStatusText(InventoryStatus status) {
    switch (status) {
      case InventoryStatus.good:
        return 'Baik';
      case InventoryStatus.low:
        return 'Rendah';
      case InventoryStatus.critical:
        return 'Kritis';
    }
  }

  Widget _buildInventoryItem(InventoryItem item) {
    final statusColor = _getStatusColor(item.status);
    final statusText = _getStatusText(item.status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok: ${item.currentStock} ${item.unit} / Min: ${item.minStock} ${item.unit}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terakhir update: ${_formatDateTime(item.lastUpdated)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  int get criticalItemsCount {
    return rawMaterials
            .where((item) => item.status == InventoryStatus.critical)
            .length +
        finishedProducts
            .where((item) => item.status == InventoryStatus.critical)
            .length;
  }

  int get lowItemsCount {
    return rawMaterials
            .where((item) => item.status == InventoryStatus.low)
            .length +
        finishedProducts
            .where((item) => item.status == InventoryStatus.low)
            .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        title: const Text(
          'Manajemen Stok',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF97316)],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Bahan Baku'),
            Tab(text: 'Produk Jadi'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Stats
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFFED7AA)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildQuickStat(
                  'Total Item',
                  '${rawMaterials.length + finishedProducts.length}',
                  Icons.inventory_2,
                  const Color(0xFF10B981),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildQuickStat(
                  'Stok Rendah',
                  lowItemsCount.toString(),
                  Icons.warning_amber,
                  Colors.orange,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildQuickStat(
                  'Stok Kritis',
                  criticalItemsCount.toString(),
                  Icons.error,
                  Colors.red,
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Raw Materials Tab
                ListView.builder(
                  itemCount: rawMaterials.length,
                  itemBuilder: (context, index) {
                    return _buildInventoryItem(rawMaterials[index]);
                  },
                ),

                // Finished Products Tab
                ListView.builder(
                  itemCount: finishedProducts.length,
                  itemBuilder: (context, index) {
                    return _buildInventoryItem(finishedProducts[index]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new inventory item functionality
        },
        backgroundColor: const Color(0xFFEA580C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
