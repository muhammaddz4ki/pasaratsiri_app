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
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
        ),
      ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Laporan berhasil diekspor ke PDF'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Dashboard Analitik',
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
      body: FutureBuilder<List<dynamic>>(
        future: _analyticsData,
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
                    'Memuat data analitik...',
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
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF14B8A6).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: const Color(0xFF10B981).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Data Tidak Tersedia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Tidak ada data analitik yang tersedia saat ini',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
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
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
      ),
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
      childAspectRatio: 1,
      children: [
        _miniSummaryCard(
          'Pesanan Selesai',
          summaryData['totalOrders'].toString(),
          Icons.receipt_long_outlined,
          const Color(0xFF10B981),
        ),
        _miniSummaryCard(
          'Produk Terlaris',
          summaryData['topProduct'],
          Icons.star_border_outlined,
          const Color(0xFFF59E0B),
        ),
        _miniSummaryCard(
          'Rata-rata/Order',
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp\n',
            decimalDigits: 0,
          ).format(summaryData['averageOrderValue']),
          Icons.monetization_on_outlined,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _miniSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
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
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
            const SizedBox(height: 12),
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(value),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
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
              color: const Color(0xFF10B981),
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

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
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
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Grafik Pendapatan Mingguan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
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
                          const Color(0xFF374151),
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
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
        border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
      ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
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
                    return Center(
                      child: Container(
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
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Data tren tidak tersedia.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCommodityId,
          items: _commodities.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCommodityId = newValue;
            });
          },
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
          style: const TextStyle(color: Color(0xFF374151)),
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
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
          color: const Color(0xFF10B981),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: const Color(0xFF10B981).withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
