import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // --- PERUBAHAN DI SINI ---
      // Kita ambil dan simpan sellerId untuk setiap item
      for (var doc in cartSnapshot.docs) {
        DocumentSnapshot productDoc = await _firestore
            .collection('products')
            .doc(doc.id)
            .get();

        String? sellerId; // Variabel untuk menyimpan sellerId per item
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
          'sellerId': sellerId, // <-- FIELD PENTING DITAMBAHKAN
        });
      }
      // --- AKHIR PERUBAHAN ---

      DocumentReference orderDoc = await _firestore.collection('orders').add({
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'N/A',
        'shippingAddress': address,
        'items': orderItems, // list items sekarang sudah berisi sellerId
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

  // --- PERUBAHAN DI SINI ---
  Future<String?> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {'status': newStatus};

      // Kunci untuk analitik: tambahkan timestamp saat pesanan selesai
      if (newStatus == 'Selesai') {
        dataToUpdate['completedAt'] = Timestamp.now();
      }

      await _firestore.collection('orders').doc(orderId).update(dataToUpdate);
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Gagal memperbarui status pesanan.";
    }
  }
}
