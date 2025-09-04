import 'package:flutter/material.dart';

class MarketPriceScreen extends StatelessWidget {
  const MarketPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy untuk harga pasar
    final List<Map<String, String>> marketPrices = [
      {'commodity': 'Minyak Nilam', 'price': 'Rp 450.000 / kg', 'trend': 'up'},
      {
        'commodity': 'Minyak Sereh Wangi',
        'price': 'Rp 220.000 / kg',
        'trend': 'stable',
      },
      {
        'commodity': 'Minyak Cengkeh',
        'price': 'Rp 180.000 / kg',
        'trend': 'down',
      },
      {'commodity': 'Minyak Pala', 'price': 'Rp 500.000 / kg', 'trend': 'up'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Harga Pasar'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: marketPrices.length,
        itemBuilder: (context, index) {
          final item = marketPrices[index];
          final trendIcon = item['trend'] == 'up'
              ? const Icon(Icons.arrow_upward, color: Colors.green)
              : item['trend'] == 'down'
              ? const Icon(Icons.arrow_downward, color: Colors.red)
              : const Icon(Icons.remove, color: Colors.grey);

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
                item['commodity']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                item['price']!,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: trendIcon,
            ),
          );
        },
      ),
    );
  }
}
