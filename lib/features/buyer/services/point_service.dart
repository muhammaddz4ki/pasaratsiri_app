// lib/features/buyer/services/point_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi utama untuk menambah poin dan mencatat riwayatnya
  Future<void> addPoints({
    required String userId,
    required int pointsToAdd,
    required String reason,
  }) async {
    try {
      // Dapatkan referensi dokumen user
      final userRef = _firestore.collection('users').doc(userId);

      // Dapatkan referensi sub-koleksi riwayat poin
      final historyRef = userRef.collection('pointHistory');

      // Gunakan FieldValue.increment untuk penambahan yang aman
      await userRef.update({'points': FieldValue.increment(pointsToAdd)});

      // Tambahkan catatan ke riwayat
      await historyRef.add({
        'amount': pointsToAdd,
        'reason': reason,
        'createdAt': Timestamp.now(),
      });

      print(
        'Berhasil menambahkan $pointsToAdd poin untuk user $userId karena $reason',
      );
    } catch (e) {
      print('Gagal menambahkan poin: $e');
      // Mungkin bisa ditambahkan error handling yang lebih baik di sini
    }
  }

  // Stream untuk mendapatkan total poin user secara real-time
  Stream<int> getUserPointsStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0); // Kembalikan 0 jika user tidak login
    }
    return _firestore.collection('users').doc(currentUser.uid).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data()!.containsKey('points')) {
        return (snapshot.data()!['points'] as num).toInt();
      } else {
        return 0; // Kembalikan 0 jika field poin tidak ada
      }
    });
  }

  // Stream untuk mendapatkan riwayat poin
  Stream<QuerySnapshot<Map<String, dynamic>>> getPointHistoryStream() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('pointHistory')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String?> redeemVoucher({
    required Map<String, dynamic> voucherData,
  }) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return "Anda harus login untuk menukar poin.";
    }

    final userRef = _firestore.collection('users').doc(currentUser.uid);
    final int pointsCost = voucherData['points'] as int;

    try {
      await _firestore.runTransaction((transaction) async {
        // 1. Dapatkan data user saat ini di dalam transaksi
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("User tidak ditemukan.");
        }

        // 2. Cek apakah poin cukup
        final currentPoints = (userSnapshot.get('points') as num? ?? 0).toInt();
        if (currentPoints < pointsCost) {
          throw Exception("Poin Anda tidak cukup.");
        }

        // 3. Kurangi poin user
        transaction.update(userRef, {
          'points': FieldValue.increment(-pointsCost),
        });

        // 4. Buat dokumen voucher baru untuk user
        final newVoucherRef = userRef.collection('myVouchers').doc();
        transaction.set(newVoucherRef, {
          'title': voucherData['title'],
          'pointsCost': pointsCost,
          'discountType': 'percentage',
          'discountValue': voucherData['discountValue'],
          'minSpend': voucherData['minSpend'],
          'redeemedAt': Timestamp.now(),
          'isUsed': false,
        });

        // 5. (Opsional) Tambahkan catatan ke riwayat poin
        final historyRef = userRef.collection('pointHistory').doc();
        transaction.set(historyRef, {
          'amount': -pointsCost,
          'reason': 'Tukar Voucher: ${voucherData['title']}',
          'createdAt': Timestamp.now(),
        });
      });

      return null; // Sukses
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan Firestore.";
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }
}
