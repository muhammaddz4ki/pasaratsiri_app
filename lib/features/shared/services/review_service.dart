import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk mengambil semua ulasan untuk produk tertentu
  Stream<QuerySnapshot> getReviewsForProduct(String productId) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Fungsi untuk menambahkan ulasan baru menggunakan Transaksi
  Future<String?> addReview({
    required String productId,
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "Anda harus login untuk memberikan ulasan.";
    }

    try {
      final productRef = _firestore.collection('products').doc(productId);
      final reviewRef = productRef.collection('reviews').doc(orderId);

      await _firestore.runTransaction((transaction) async {
        final existingReview = await transaction.get(reviewRef);
        if (existingReview.exists) {
          throw Exception('Anda sudah memberikan ulasan untuk pesanan ini.');
        }

        final productSnapshot = await transaction.get(productRef);
        if (!productSnapshot.exists) {
          throw Exception("Produk tidak ditemukan!");
        }

        final productData = productSnapshot.data() as Map<String, dynamic>;

        // --- LOGIKA KALKULASI YANG BENAR SESUAI RULES ---
        final double currentRatingTotal = (productData['ratingTotal'] ?? 0.0)
            .toDouble();
        final int currentReviewCount = productData['reviewCount'] ?? 0;

        final double newRatingTotal = currentRatingTotal + rating;
        final int newReviewCount = currentReviewCount + 1;
        final double newAverageRating = newRatingTotal / newReviewCount;

        // 1. Simpan dokumen ulasan yang baru
        transaction.set(reviewRef, {
          'productId': productId,
          'userId': currentUser.uid,
          'userName': currentUser.displayName ?? 'Pembeli',
          'rating': rating,
          'comment': comment,
          'createdAt': Timestamp.now(),
        });

        // 2. Update dokumen produk dengan 3 FIELD YANG SESUAI DENGAN RULES
        transaction.update(productRef, {
          'averageRating': newAverageRating,
          'reviewCount': newReviewCount,
          'ratingTotal': newRatingTotal, // <-- PASTIKAN FIELD INI DIKIRIM
        });
      });

      return null; // Sukses
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan Firestore.";
    } catch (e) {
      return e.toString();
    }
  }
}
