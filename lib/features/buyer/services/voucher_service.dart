// lib/features/buyer/services/voucher_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasaratsiri_app/features/buyer/models/voucher_model.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk mengambil semua voucher yang dimiliki & belum dipakai
  Future<List<Voucher>> getAvailableVouchers() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('myVouchers')
          .where('isUsed', isEqualTo: false) // Hanya ambil yg belum dipakai
          .get();

      return querySnapshot.docs
          .map((doc) => Voucher.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Gagal mengambil voucher: $e");
      return [];
    }
  }
}
