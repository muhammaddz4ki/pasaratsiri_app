import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/buyer/models/location_model.dart';

class LocationSearchDelegate extends SearchDelegate<LocationModel?> {
  final List<LocationModel> allLocations;

  LocationSearchDelegate({required this.allLocations});

  static const Color darkColor = Color(0xFF047857);

  // Aksi di sebelah kanan (misal: tombol hapus teks)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Menghapus teks di search bar
        },
      ),
    ];
  }

  // Aksi di sebelah kiri (misal: tombol kembali)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Menutup halaman search
      },
    );
  }

  // Tampilan hasil setelah user menekan 'enter' atau 'search'
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  // Tampilan saran yang muncul saat user mengetik
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  // Widget helper untuk membangun daftar hasil pencarian
  Widget _buildSearchResults() {
    final List<LocationModel> filteredLocations = allLocations.where((
      location,
    ) {
      return location.nama.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        final location = filteredLocations[index];
        return ListTile(
          leading: Icon(
            Icons.location_on,
            color: location.jenis == 'Petani'
                ? darkColor
                : Colors.blue.shade700,
          ),
          title: Text(location.nama),
          subtitle: Text(location.jenis),
          onTap: () {
            // Saat salah satu hasil di-tap, tutup halaman search dan kirim datanya
            close(context, location);
          },
        );
      },
    );
  }
}
