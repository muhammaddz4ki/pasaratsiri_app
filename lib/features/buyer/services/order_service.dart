import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi createOrder tidak perlu diubah, sudah benar.
  Future<String?> createOrder({
    required String address,
    required double totalPrice,
    required String paymentMethod,
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
        if (productDoc.exists) {
          String sellerId =
              (productDoc.data() as Map<String, dynamic>)['sellerId'];
          if (!sellerIds.contains(sellerId)) {
            sellerIds.add(sellerId);
          }
        }

        orderItems.add({
          'productId': doc.id,
          'productName': doc.data()['productName'],
          'price': doc.data()['price'],
          'quantity': doc.data()['quantity'],
        });
      }

      DocumentReference orderDoc = await _firestore.collection('orders').add({
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'N/A',
        'shippingAddress': address,
        'items': orderItems,
        'totalPrice': totalPrice,
        'status': 'Menunggu Pembayaran',
        'paymentMethod': paymentMethod,
        'createdAt': Timestamp.now(),
        'sellerIds': sellerIds,
      });

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      print('Order berhasil dibuat dengan ID: ${orderDoc.id}');
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi getOrders untuk pembeli tidak perlu diubah.
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

  // --- PERBAIKAN DI FUNGSI INI ---
  // Tambahkan parameter 'status' agar bisa memfilter pesanan untuk petani
  Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersForFarmer({
    String? status,
  }) {
    return _auth.authStateChanges().switchMap((user) {
      if (user != null) {
        Query<Map<String, dynamic>> query = _firestore
            .collection('orders')
            .where('sellerIds', arrayContains: user.uid);

        // Tambahkan filter status jika diberikan
        if (status != null) {
          query = query.where('status', isEqualTo: status);
        } else {
          // Jika tidak ada status spesifik, tampilkan semua yang relevan
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

  // Fungsi updateOrderStatus tidak perlu diubah.
  Future<String?> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Gagal memperbarui status pesanan.";
    }
  }
}
