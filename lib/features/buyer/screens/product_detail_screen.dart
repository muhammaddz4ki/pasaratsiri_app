import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // <-- TAMBAHAN: Import package rating
import 'package:intl/intl.dart'; // <-- TAMBAHAN: Import untuk format tanggal
import 'package:pasaratsiri_app/features/shared/models/review_model.dart'; // <-- TAMBAHAN: Import model
import 'package:pasaratsiri_app/features/shared/screens/chat_screen.dart';
import 'package:pasaratsiri_app/features/shared/services/review_service.dart'; // <-- TAMBAHAN: Import service
import '../services/cart_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final CartService cartService = CartService();
    // <-- TAMBAHAN: Inisialisasi ReviewService
    final ReviewService reviewService = ReviewService();
    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(productId);

    return Scaffold(
      backgroundColor: Colors.white, // Ganti background agar lebih bersih
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: productRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Produk tidak ditemukan.",
                style: TextStyle(color: Color(0xFF047857), fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String productName = data['name'] ?? 'Nama Produk';
          final String imageUrl =
              data['imageUrl'] ?? 'https://via.placeholder.com/400';
          final double price = (data['price'] ?? 0.0).toDouble();
          final String weight = data['weight'] ?? 'N/A';
          final String description =
              data['description'] ?? 'Tidak ada deskripsi.';
          final String sellerId = data['sellerId'] ?? '';
          final String sellerName = data['sellerName'] ?? 'Penjual';
          // <-- TAMBAHAN: Ambil data rating dari produk
          final double averageRating = (data['averageRating'] ?? 0.0)
              .toDouble();
          final int reviewCount = data['reviewCount'] ?? 0;

          return Stack(
            children: [
              // Product Image
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Hero(
                  tag: productId,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Draggable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.55,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: ListView(
                      // <-- GANTI DARI SingleChildScrollView ke ListView
                      controller: scrollController,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Text(
                          productName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // --- TAMBAHAN: WIDGET UNTUK MENAMPILKAN RATING ---
                        _buildRatingSummary(averageRating, reviewCount),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Chip(
                              backgroundColor: const Color(0xFFD1FAE5),
                              label: Text(
                                "Rp ${price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Chip(
                              backgroundColor: const Color(0xFFF0FDFA),
                              label: Text(
                                weight,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0D9488),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Tentang Produk",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        // --- TAMBAHAN: WIDGET UNTUK MENAMPILKAN DAFTAR ULASAN ---
                        const Text(
                          "Ulasan Pembeli",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildReviewList(reviewService, productId),
                        const SizedBox(height: 100), // Padding untuk tombol
                      ],
                    ),
                  );
                },
              ),

              // Floating Action Buttons
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: sellerId,
                              receiverName: sellerName,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Chat"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          final error = await cartService.addToCart(
                            productId,
                            productName,
                            price,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: error == null
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                content: Row(
                                  children: [
                                    Icon(
                                      error == null
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      error ??
                                          'Produk ditambahkan ke keranjang!',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        child: const Text(
                          "Tambah ke Keranjang",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- TAMBAHAN: WIDGET UNTUK RATING SUMMARY ---
  Widget _buildRatingSummary(double averageRating, int reviewCount) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: averageRating,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: Colors.amber),
          itemCount: 5,
          itemSize: 20.0,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 8),
        Text(
          '${averageRating.toStringAsFixed(1)} (${reviewCount} ulasan)',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  // --- TAMBAHAN: WIDGET UNTUK DAFTAR ULASAN ---
  Widget _buildReviewList(ReviewService reviewService, String productId) {
    return StreamBuilder<QuerySnapshot>(
      stream: reviewService.getReviewsForProduct(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: Text('Belum ada ulasan untuk produk ini.')),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final review = Review.fromFirestore(doc);
            return _buildReviewItem(review);
          }).toList(),
        );
      },
    );
  }

  // --- TAMBAHAN: WIDGET UNTUK SATU ITEM ULASAN ---
  Widget _buildReviewItem(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                      ).format(review.createdAt.toDate()),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 16.0,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(color: Colors.grey.shade800, height: 1.4),
          ),
        ],
      ),
    );
  }
}
