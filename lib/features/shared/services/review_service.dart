// lib/features/shared/services/review_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Sesuaikan path import ini jika berbeda di struktur folder kamu
import 'package:pasaratsiri_app/features/buyer/services/point_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 1. Buat instance dari PointService
  final PointService _pointService = PointService();

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

      // Menggunakan orderId sebagai ID dokumen review untuk mencegah duplikasi
      final reviewRef = productRef.collection('reviews').doc(orderId);

      // --- TRANSAKSI UNTUK MENYIMPAN ULASAN DAN UPDATE PRODUK ---
      await _firestore.runTransaction((transaction) async {
        final existingReview = await transaction.get(reviewRef);
        if (existingReview.exists) {
          // Jika ulasan sudah ada, lempar error agar transaksi berhenti
          throw Exception('Anda sudah memberikan ulasan untuk pesanan ini.');
        }

        final productSnapshot = await transaction.get(productRef);
        if (!productSnapshot.exists) {
          throw Exception("Produk tidak ditemukan!");
        }

        final productData = productSnapshot.data() as Map<String, dynamic>;

        final double currentRatingTotal = (productData['ratingTotal'] ?? 0.0)
            .toDouble();
        final int currentReviewCount = productData['reviewCount'] ?? 0;

        final double newRatingTotal = currentRatingTotal + rating;
        final int newReviewCount = currentReviewCount + 1;
        final double newAverageRating = newRatingTotal / newReviewCount;

        // A. Simpan dokumen ulasan yang baru di dalam transaksi
        transaction.set(reviewRef, {
          'productId': productId,
          'userId': currentUser.uid,
          'userName': currentUser.displayName ?? 'Pembeli',
          'rating': rating,
          'comment': comment,
          'createdAt': Timestamp.now(),
        });

        // B. Update dokumen produk di dalam transaksi
        transaction.update(productRef, {
          'averageRating': newAverageRating,
          'reviewCount': newReviewCount,
          'ratingTotal': newRatingTotal,
        });
      });

      // --- LOGIKA PENAMBAHAN POIN ---
      // 2. Kode ini hanya akan berjalan jika transaksi di atas SUKSES
      await _pointService.addPoints(
        userId: currentUser.uid,
        pointsToAdd: 50, // Kamu bisa ubah jumlah poinnya di sini
        reason: 'Memberi Ulasan',
      );

      return null; // Sukses
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan Firestore.";
    } catch (e) {
      // Menangkap error dari dalam transaksi (misal: ulasan sudah ada)
      return e.toString().replaceFirst("Exception: ", "");
    }
  }
}
