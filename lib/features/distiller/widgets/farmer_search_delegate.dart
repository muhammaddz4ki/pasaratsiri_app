import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/distiller/models/farmer_location_model.dart';

class FarmerSearchDelegate extends SearchDelegate<FarmerLocationModel?> {
  final List<FarmerLocationModel> allFarmers;

  FarmerSearchDelegate({required this.allFarmers});

  // Warna dari distiller dashboard
  static const Color themeColor = Color(0xFFEA580C);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final filteredFarmers = allFarmers.where((farmer) {
      return farmer.nama.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredFarmers.length,
      itemBuilder: (context, index) {
        final farmer = filteredFarmers[index];
        return ListTile(
          leading: const Icon(
            Icons.person_pin_circle_outlined,
            color: themeColor,
          ),
          title: Text(farmer.nama),
          subtitle: Text(farmer.jenis),
          onTap: () => close(context, farmer),
        );
      },
    );
  }
}
