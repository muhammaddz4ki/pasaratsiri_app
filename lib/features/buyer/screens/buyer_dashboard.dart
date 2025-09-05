import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasaratsiri_app/features/buyer/screens/buyer_chat_list_screen.dart';
import 'package:pasaratsiri_app/features/buyer/screens/order_history_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import '../services/cart_service.dart';

class PembeliDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int initialPageIndex;

  const PembeliDashboard({
    super.key,
    required this.userData,
    this.initialPageIndex = 2, // Default to Home tab (index 2)
  });

  @override
  State<PembeliDashboard> createState() => _PembeliDashboardState();
}

class _PembeliDashboardState extends State<PembeliDashboard> {
  int _selectedIndex = 2; // Default to Home tab
  final CartService _cartService = CartService();
  late final List<Widget> _pages;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFF10B981);
  static const Color secondaryColor = Color(0xFF14B8A6);
  static const Color darkColor = Color(0xFF047857);
  static const Color ultraLightColor = Color(0xFFECFDF5);

  @override
  void initState() {
    super.initState();
    // Set _selectedIndex to widget.initialPageIndex, but default is already 2
    _selectedIndex = widget.initialPageIndex;

    _pages = <Widget>[
      const BuyerChatListScreen(), // Chat tab
      const OrderHistoryScreen(), // Riwayat tab
      _buildHomeScreen(), // Home tab (center)
      _buildFavoritesScreen(), // Favorites tab
      ProfileScreen(userData: widget.userData), // Profile tab
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex != 4 ? _buildAppBar() : null,
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: _buildEnhancedBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          color: darkColor,
        ),
      ),
      title: Image.asset('assets/images/logo.png', height: 40),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: darkColor.withOpacity(0.2),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
            color: darkColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, -2),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100, Colors.white],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Colors.grey.shade600,
              letterSpacing: -0.2,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 0
                        ? const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          )
                        : null,
                    boxShadow: _selectedIndex == 0
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 0 ? Icons.chat : Icons.chat_outlined,
                    size: 26,
                    color: _selectedIndex == 0
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 1
                        ? const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          )
                        : null,
                    boxShadow: _selectedIndex == 1
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 1
                        ? Icons.history
                        : Icons.history_outlined,
                    size: 26,
                    color: _selectedIndex == 1
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(14), // Increased padding
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 2
                        ? const LinearGradient(
                            colors: [primaryColor, secondaryColor, Colors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Colors.grey, Colors.grey],
                          ),
                    boxShadow: _selectedIndex == 2
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: secondaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Icon(
                    _selectedIndex == 2 ? Icons.home : Icons.home_outlined,
                    size: 36, // Larger size for prominence
                    color: _selectedIndex == 2
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 3
                        ? const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          )
                        : null,
                    boxShadow: _selectedIndex == 3
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 3
                        ? Icons.star
                        : Icons.star_border_outlined,
                    size: 26,
                    color: _selectedIndex == 3
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _selectedIndex == 4
                        ? const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          )
                        : null,
                    boxShadow: _selectedIndex == 4
                        ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 4 ? Icons.person : Icons.person_outlined,
                    size: 26,
                    color: _selectedIndex == 4
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    final Stream<QuerySnapshot> productsStream = FirebaseFirestore.instance
        .collection('products')
        .snapshots();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/background3.png',
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Special Offer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Get 20% discount on\nessential oils",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: darkColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list, color: darkColor),
                  onPressed: () {},
                ),
                filled: true,
                fillColor: ultraLightColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildCategoryItem('Minyak Atsiri', Icons.spa),
                _buildCategoryItem('Herbal', Icons.local_florist),
                _buildCategoryItem('Aromaterapi', Icons.air),
                _buildCategoryItem('Skincare', Icons.face),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Popular Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: productsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Tidak ada produk.'));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(snapshot.data!.docs[index]);
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: ultraLightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: darkColor, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: darkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Nama Produk',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Minyak Atsiri',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${data['price'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: darkColor,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final String productId = document.id;
                          final String productName =
                              data['name'] ?? 'Produk Tanpa Nama';
                          final double price = (data['price'] as num)
                              .toDouble();

                          final String? errorMessage = await _cartService
                              .addToCart(productId, productName, price);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage == null
                                      ? '$productName ditambahkan ke keranjang!'
                                      : 'Gagal: $errorMessage',
                                ),
                                backgroundColor: errorMessage == null
                                    ? primaryColor
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesScreen() {
    return const Center(
      child: Text(
        'Your Favorites',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
