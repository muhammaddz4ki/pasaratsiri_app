// lib/features/farmer/screens/farmer_analytics_screen.dart

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart';
import '../services/analytics_service.dart';
import '../services/pdf_service.dart';

class FarmerAnalyticsScreen extends StatefulWidget {
  const FarmerAnalyticsScreen({super.key});

  @override
  State<FarmerAnalyticsScreen> createState() => _FarmerAnalyticsScreenState();
}

class _FarmerAnalyticsScreenState extends State<FarmerAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final PdfService _pdfService = PdfService();
  final GlobalKey _chartKey = GlobalKey();

  late Future<List<dynamic>> _analyticsData;

  String? _selectedCommodityId;
  final Map<String, String> _commodities = {
    'akar_wangi': 'Akar Wangi',
    'cengkeh': 'Cengkeh',
    'pala': 'Pala',
    'kayu_putih': 'Kayu Putih',
    'sereh_wangi': 'Sereh Wangi',
    'minyak_nilam': 'Minyak Nilam',
  };

  @override
  void initState() {
    super.initState();
    _analyticsData = Future.wait([
      _analyticsService.getMonthlyIncomeData(),
      _analyticsService.getAnalyticsSummary(),
    ]);
    if (_commodities.isNotEmpty) {
      _selectedCommodityId = _commodities.keys.first;
    }
  }

  Future<void> _exportToPdf(
    Map<String, double> incomeData,
    Map<String, dynamic> summaryData,
  ) async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List chartImageBytes = byteData!.buffer.asUint8List();

      final userData = await AuthService().getCurrentUserData();
      final farmerName = userData?['name'] ?? 'Petani';

      await _pdfService.generateAnalyticsPdf(
        farmerName: farmerName,
        period: DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
        totalIncome: incomeData.isNotEmpty
            ? incomeData.values.reduce((a, b) => a + b)
            : 0.0,
        summaryData: summaryData,
        chartImageBytes: chartImageBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat PDF: $e')));
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analitik'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<List<dynamic>>(
            future: _analyticsData,
            builder: (context, snapshot) {
              if (snapshot.hasData && (snapshot.data![0] as Map).isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () =>
                      _exportToPdf(snapshot.data![0], snapshot.data![1]),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<dynamic>>(
        future: _analyticsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat data.'));
          }

          final Map<String, double> incomeData = snapshot.data![0];
          final Map<String, dynamic> summaryData = snapshot.data![1];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (incomeData.isNotEmpty) ...[
                _buildSummaryCard(
                  'Total Pendapatan - $currentMonth',
                  incomeData.values.reduce((a, b) => a + b),
                ),
                const SizedBox(height: 16),
                _buildSummaryGrid(summaryData),
                const SizedBox(height: 24),
                RepaintBoundary(
                  key: _chartKey,
                  child: _buildBarChartCard(incomeData),
                ),
              ] else ...[
                _buildEmptyStateCard(),
              ],
              const SizedBox(height: 24),
              _buildPriceTrendCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Belum ada pendapatan di bulan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(Map<String, dynamic> summaryData) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1, // Ubah rasio agar lebih kotak
      children: [
        _miniSummaryCard(
          'Pesanan Selesai',
          summaryData['totalOrders'].toString(),
          Icons.receipt_long_outlined,
          Colors.blue.shade600,
        ),
        _miniSummaryCard(
          'Produk Terlaris',
          summaryData['topProduct'],
          Icons.star_border_outlined,
          Colors.amber.shade700,
        ),
        _miniSummaryCard(
          'Rata-rata/Order',
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp\n',
            decimalDigits: 0,
          ).format(summaryData['averageOrderValue']),
          Icons.monetization_on_outlined,
          Colors.purple.shade600,
        ),
      ],
    );
  }

  // --- PERBAIKAN DI WIDGET INI ---
  Widget _miniSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            // Gunakan Expanded dan FittedBox agar teks menyesuaikan
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2, // Izinkan hingga 2 baris jika perlu
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- AKHIR PERBAIKAN ---

  Widget _buildSummaryCard(String title, double value) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(value),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(Map<String, double> data) {
    List<BarChartGroupData> barGroups = [];
    List<String> weekTitles = data.keys.toList();
    for (int i = 0; i < weekTitles.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[weekTitles[i]]!,
              color: Colors.green.shade600,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Grafik Pendapatan Mingguan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              weekTitles[value.toInt()].replaceAll(' ', '\n'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) =>
                          Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String week = weekTitles[group.x.toInt()];
                        String formattedAmount = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(rod.toY);
                        return BarTooltipItem(
                          '$week\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: formattedAmount,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTrendCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Analisis Tren Harga",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildCommodityDropdown(),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<FlSpot>>(
                key: ValueKey(_selectedCommodityId),
                future: _analyticsService.getPriceTrendData(
                  _selectedCommodityId!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("Data tren tidak tersedia."),
                    );
                  }
                  return LineChart(_buildLineChartData(snapshot.data!));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommodityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCommodityId,
          items: _commodities.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCommodityId = newValue;
            });
          },
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: const Duration(days: 30).inMilliseconds.toDouble(),
            getTitlesWidget: (value, meta) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(
                value.toInt(),
              );
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('d MMM').format(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.orange.shade700,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.orange.shade200.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
