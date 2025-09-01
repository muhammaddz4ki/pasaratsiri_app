import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk membuat pesanan baru
  Future<String?> createOrder({
    required String address,
    required double totalPrice,
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

      final List<Map<String, dynamic>> orderItems = cartSnapshot.docs.map((
        doc,
      ) {
        return {
          'productId': doc.id,
          'productName': doc.data()['productName'],
          'price': doc.data()['price'],
          'quantity': doc.data()['quantity'],
        };
      }).toList();

      DocumentReference orderDoc = await _firestore.collection('orders').add({
        'userId': currentUser.uid,
        'userName': currentUser.displayName ?? 'N/A',
        'shippingAddress': address,
        'items': orderItems,
        'totalPrice': totalPrice,
        'status': 'pending',
        'createdAt': Timestamp.now(),
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

  // --- FUNGSI BARU ---
  // Mengambil riwayat pesanan pengguna
  Stream<QuerySnapshot> getOrders() {
    User? currentUser = _auth.currentUser;
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: currentUser?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
