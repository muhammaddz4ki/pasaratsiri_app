import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/buyer/models/combined_location_model.dart';

class LocationSearchDelegate extends SearchDelegate<CombinedLocationModel?> {
  final List<CombinedLocationModel> allLocations;

  LocationSearchDelegate({required this.allLocations});

  // Warna konsisten dari tema Buyer
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.1),
        iconTheme: const IconThemeData(color: darkColor),
        titleTextStyle: TextStyle(color: Colors.grey[800], fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        border: InputBorder.none,
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Cari petani atau penyuling...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: darkColor),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: darkColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptySearch();
    }

    final filteredLocations = allLocations.where((location) {
      return location.nama.toLowerCase().contains(query.toLowerCase()) ||
          location.jenis.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredLocations.isEmpty) {
      return _buildNoResults();
    }

    return Container(
      color: const Color(0xFFFAFAFA),
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredLocations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final location = filteredLocations[index];
          return _buildLocationCard(context, location);
        },
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    CombinedLocationModel location,
  ) {
    bool isPetani = location.jenis == 'Petani';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => close(context, location),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPetani
                          ? [primaryColor, const Color(0xFF34D399)]
                          : [darkColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPetani ? Icons.grass_rounded : Icons.science_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: _buildHighlightedText(
                          location.nama,
                          query,
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPetani
                              ? primaryColor.withOpacity(0.1)
                              : darkColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          location.jenis,
                          style: TextStyle(
                            color: isPetani ? primaryColor : darkColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Cari Lokasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Temukan lokasi petani atau penyulingan\ndi sekitar Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Tidak Ada Hasil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ditemukan lokasi untuk "$query".\nCoba kata kunci lain.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(String text, String query, TextStyle style) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return TextSpan(text: text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final startIndex = lowerText.indexOf(lowerQuery);

    if (startIndex == -1) {
      return TextSpan(text: text, style: style);
    }

    return TextSpan(
      style: style,
      children: [
        TextSpan(text: text.substring(0, startIndex)),
        TextSpan(
          text: text.substring(startIndex, startIndex + query.length),
          style: style.copyWith(
            backgroundColor: primaryColor.withOpacity(0.2),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: text.substring(startIndex + query.length)),
      ],
    );
  }
}
