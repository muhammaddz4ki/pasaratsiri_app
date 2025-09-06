// lib/features/buyer/services/order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pasaratsiri_app/features/buyer/services/point_service.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PointService _pointService = PointService();

  Future<String?> createOrder({
    required String address,
    required double totalPrice, // Ini adalah harga FINAL setelah diskon
    required String paymentMethod,
    // Parameter baru untuk voucher
    String? appliedVoucherId,
    double? discountAmount,
    String? voucherTitle,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return "Anda harus login untuk membuat pesanan.";

      final cartCollection = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart');
      final cartSnapshot = await cartCollection.get();

      if (cartSnapshot.docs.isEmpty) return "Keranjang Anda kosong.";

      List<String> sellerIds = [];
      List<Map<String, dynamic>> orderItems = [];

      for (var doc in cartSnapshot.docs) {
        DocumentSnapshot productDoc = await _firestore
            .collection('products')
            .doc(doc.id)
            .get();
        String? sellerId;
        if (productDoc.exists) {
          sellerId = (productDoc.data() as Map<String, dynamic>)['sellerId'];
          if (sellerId != null && !sellerIds.contains(sellerId)) {
            sellerIds.add(sellerId);
          }
        }
        orderItems.add({
          'productId': doc.id,
          'productName': doc.data()['productName'],
          'price': doc.data()['price'],
          'quantity': doc.data()['quantity'],
          'sellerId': sellerId,
        });
      }

      DocumentReference orderDoc = await _firestore.collection('orders').add({
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'N/A',
        'shippingAddress': address,
        'items': orderItems,
        'totalPrice': totalPrice, // Simpan harga final
        'paymentMethod': paymentMethod,
        'createdAt': Timestamp.now(),
        'sellerIds': sellerIds,
        'status':
            'Menunggu Pembayaran', // <-- FUNGSI STATUS AWAL DITAMBAHKAN DI SINI
        // Simpan info diskon di pesanan
        'discountDetails': {
          'appliedVoucherId': appliedVoucherId,
          'discountAmount': discountAmount,
          'voucherTitle': voucherTitle,
        },
      });

      // Menandai voucher sebagai sudah digunakan
      if (appliedVoucherId != null) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('myVouchers')
            .doc(appliedVoucherId)
            .update({'isUsed': true, 'usedAt': Timestamp.now()});
      }

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Order berhasil dibuat dengan ID: ${orderDoc.id}');
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrders({String? status}) {
    return _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        Query<Map<String, dynamic>> query = _firestore
            .collection('orders')
            .where('userId', isEqualTo: user.uid);

        if (status != null && status != 'Semua') {
          query = query.where('status', isEqualTo: status);
        }

        return query.orderBy('createdAt', descending: true).snapshots();
      } else {
        return Stream.value(null);
      }
    }).cast<QuerySnapshot<Map<String, dynamic>>>();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersForFarmer({
    String? status,
  }) {
    return _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        Query<Map<String, dynamic>> query = _firestore
            .collection('orders')
            .where('sellerIds', arrayContains: user.uid);

        if (status != null) {
          query = query.where('status', isEqualTo: status);
        } else {
          query = query.where(
            'status',
            whereIn: ['Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'],
          );
        }

        return query.orderBy('createdAt', descending: true).snapshots();
      } else {
        return Stream.value(null);
      }
    }).cast<QuerySnapshot<Map<String, dynamic>>>();
  }

  Future<String?> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      DocumentReference orderRef = _firestore.collection('orders').doc(orderId);
      Map<String, dynamic> dataToUpdate = {'status': newStatus};

      if (newStatus == 'Selesai') {
        dataToUpdate['completedAt'] = Timestamp.now();

        DocumentSnapshot orderDoc = await orderRef.get();
        if (orderDoc.exists) {
          String userId = orderDoc.get('userId');
          await _pointService.addPoints(
            userId: userId,
            pointsToAdd: 100,
            reason: 'Pesanan Selesai (ID: ${orderRef.id.substring(0, 5)})',
          );
        }
      }
      await orderRef.update(dataToUpdate);
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Gagal memperbarui status pesanan.";
    }
  }
}
