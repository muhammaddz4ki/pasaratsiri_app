// lib/buyer/screens/pembeli_dashboard.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart'; // <-- IMPORT HALAMAN PROFIL
import '../services/cart_service.dart'; // <-- IMPORT CART SERVICE

class PembeliDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const PembeliDashboard({super.key, required this.userData});

  @override
  State<PembeliDashboard> createState() => _PembeliDashboardState();
}

class _PembeliDashboardState extends State<PembeliDashboard> {
  int _selectedIndex = 0; // Untuk melacak tab yang aktif
  final CartService _cartService =
      CartService(); // <-- Inisialisasi CartService

  // Daftar halaman yang akan ditampilkan oleh BottomNavigationBar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomeScreen(), // Halaman Home (Indeks 0)
      const Center(
        child: Text('Halaman Favorit'),
      ), // Halaman Favorit (Indeks 1)
      const Center(child: Text('Halaman Tambah')), // Placeholder (Indeks 2)
      const Center(
        child: Text('Halaman Keranjang'),
      ), // Halaman Keranjang (Indeks 3)
      ProfileScreen(userData: widget.userData), // Halaman Profil (Indeks 4)
    ];
  }

  void _onItemTapped(int index) {
    // Abaikan tap pada item tengah yang besar
    if (index == 2) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar hanya ditampilkan jika bukan halaman profil
      appBar: _selectedIndex != 4
          ? AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined),
              ),
              title: Image.asset('assets/images/logo.png', height: 40),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              ],
            )
          : null, // Tidak ada AppBar di halaman profil
      body: _pages.elementAt(
        _selectedIndex,
      ), // Menampilkan halaman sesuai indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 40),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK KONTEN HALAMAN HOME ---
  Widget _buildHomeScreen() {
    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .snapshots();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian banner, search, dan judul
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/background3.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Minyak Atsiri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: productsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Tidak ada produk.'));
              }
              return Column(
                children: snapshot.data!.docs.map((document) {
                  return _buildProductCard(document);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU PRODUK DENGAN FUNGSI CART AKTIF ---
  Widget _buildProductCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: document.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                data['imageUrl'] ?? 'https://via.placeholder.com/100',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Nama Produk',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minyak Atsiri',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${data['price'] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // ## FUNGSI TAMBAH KE KERANJANG SEKARANG AKTIF ##
            IconButton(
              onPressed: () async {
                final String productId = document.id;
                final String productName = data['name'] ?? 'Produk Tanpa Nama';
                final double price = (data['price'] as num).toDouble();

                // Panggil fungsi addToCart dari CartService
                final String? errorMessage = await _cartService.addToCart(
                  productId,
                  productName,
                  price,
                );

                // Tampilkan notifikasi ke pengguna
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        errorMessage == null
                            ? '$productName ditambahkan ke keranjang!'
                            : 'Gagal: $errorMessage',
                      ),
                      backgroundColor: errorMessage == null
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
