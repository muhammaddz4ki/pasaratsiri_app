// lib/features/farmer/screens/market_price_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> {
  final FarmerService _farmerService = FarmerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Harga Pasar'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: StreamBuilder<List<MarketPriceModel>>(
        stream: _farmerService.getMarketPricesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Data harga tidak tersedia saat ini.'),
            );
          }

          final marketPrices = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: marketPrices.length,
            itemBuilder: (context, index) {
              final item = marketPrices[index];
              final Icon trendIcon;
              if (item.currentPrice > item.previousPrice) {
                trendIcon = const Icon(Icons.arrow_upward, color: Colors.green);
              } else if (item.currentPrice < item.previousPrice) {
                trendIcon = const Icon(Icons.arrow_downward, color: Colors.red);
              } else {
                trendIcon = const Icon(Icons.remove, color: Colors.grey);
              }

              final formattedPrice = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(item.currentPrice);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  title: Text(
                    item.commodity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$formattedPrice / kg',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  trailing: trendIcon,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
