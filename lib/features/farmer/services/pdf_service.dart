// lib/features/farmer/services/pdf_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<void> generateAnalyticsPdf({
    required String farmerName,
    required String period,
    required double totalIncome,
    required Map<String, dynamic> summaryData,
    required Uint8List chartImageBytes,
  }) async {
    final pdf = pw.Document();

    // --- PERUBAHAN DI SINI: Muat beberapa varian font ---
    final fontData = {
      'regular': await rootBundle.load("assets/fonts/OpenSans-Regular.ttf"),
      'bold': await rootBundle.load("assets/fonts/OpenSans-Bold.ttf"),
      'italic': await rootBundle.load("assets/fonts/OpenSans-Italic.ttf"),
    };

    final fonts = {
      'regular': pw.Font.ttf(fontData['regular']!),
      'bold': pw.Font.ttf(fontData['bold']!),
      'italic': pw.Font.ttf(fontData['italic']!),
    };
    // --- AKHIR PERUBAHAN ---

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(fonts, farmerName, period),
              pw.SizedBox(height: 30),
              _buildMainSummary(fonts, totalIncome),
              pw.SizedBox(height: 20),
              _buildStatsGrid(fonts, summaryData),
              pw.SizedBox(height: 30),
              pw.Text(
                'Grafik Pendapatan Mingguan',
                style: pw.TextStyle(
                  font: fonts['bold'],
                  fontSize: 18,
                ), // Menggunakan font bold
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Image(
                  pw.MemoryImage(chartImageBytes),
                  fit: pw.BoxFit.contain,
                  height: 250,
                ),
              ),
              pw.Spacer(),
              _buildFooter(fonts),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/laporan_analitik.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  // --- PERUBAHAN DI SINI: Terima Map fonts ---
  pw.Widget _buildHeader(
    Map<String, pw.Font> fonts,
    String farmerName,
    String period,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Laporan Analitik Pendapatan',
              style: pw.TextStyle(font: fonts['bold'], fontSize: 24),
            ),
            pw.Text(
              'Petani: $farmerName',
              style: pw.TextStyle(font: fonts['regular'], fontSize: 16),
            ),
            pw.Text(
              'Periode: $period',
              style: pw.TextStyle(
                font: fonts['regular'],
                fontSize: 14,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Container(width: 60, height: 60, color: PdfColors.green),
      ],
    );
  }

  pw.Widget _buildMainSummary(Map<String, pw.Font> fonts, double totalIncome) {
    final formattedIncome = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalIncome);
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Total Pendapatan',
            style: pw.TextStyle(
              font: fonts['regular'],
              fontSize: 16,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            formattedIncome,
            style: pw.TextStyle(
              font: fonts['bold'],
              fontSize: 32,
              color: PdfColors.green800,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatsGrid(
    Map<String, pw.Font> fonts,
    Map<String, dynamic> summaryData,
  ) {
    final formattedAvg = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(summaryData['averageOrderValue']);
    return pw.GridView(
      crossAxisCount: 3,
      childAspectRatio: 2.5,
      children: [
        _statBox(
          fonts,
          'Pesanan Selesai',
          summaryData['totalOrders'].toString(),
        ),
        _statBox(fonts, 'Produk Terlaris', summaryData['topProduct']),
        _statBox(fonts, 'Rata-rata/Order', formattedAvg),
      ],
    );
  }

  pw.Widget _statBox(Map<String, pw.Font> fonts, String title, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 10),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: fonts['regular'],
              color: PdfColors.grey600,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(font: fonts['bold'], fontSize: 14),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(Map<String, pw.Font> fonts) {
    final formattedDate = DateFormat(
      'd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.now());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 5),
        pw.Text(
          'Laporan ini dibuat secara otomatis oleh sistem Pasar Atsiri.',
          style: pw.TextStyle(
            font: fonts['italic'],
            color: PdfColors.grey500,
            fontSize: 10,
          ),
        ),
        pw.Text(
          'Dibuat pada: $formattedDate',
          style: pw.TextStyle(
            font: fonts['regular'],
            color: PdfColors.grey500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
