import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/farmer/models/distiller_location_model.dart';

class DistillerSearchDelegate extends SearchDelegate<DistillerLocationModel?> {
  final List<DistillerLocationModel> allDistillers;

  DistillerSearchDelegate({required this.allDistillers});

  // Warna dari farmer dashboard
  static const Color themeColor = Color(0xFF047857);

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
    final filteredDistillers = allDistillers.where((distiller) {
      return distiller.nama.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredDistillers.length,
      itemBuilder: (context, index) {
        final distiller = filteredDistillers[index];
        return ListTile(
          leading: const Icon(Icons.business, color: themeColor),
          title: Text(distiller.nama),
          subtitle: Text(distiller.jenis),
          onTap: () => close(context, distiller),
        );
      },
    );
  }
}
