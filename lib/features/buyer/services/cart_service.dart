import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan referensi ke koleksi keranjang pengguna saat ini
  CollectionReference? _getCartCollection() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('cart');
  }

  // Fungsi untuk menambahkan produk ke keranjang
  Future<String?> addToCart(
    String productId,
    String productName,
    double price,
  ) async {
    try {
      final cartCollection = _getCartCollection();
      if (cartCollection == null) return "Anda harus login.";

      final existingProduct = await cartCollection.doc(productId).get();

      if (existingProduct.exists) {
        await cartCollection.doc(productId).update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        await cartCollection.doc(productId).set({
          'productName': productName,
          'price': price,
          'quantity': 1,
          'addedAt': Timestamp.now(),
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --- FUNGSI BARU: Mengubah kuantitas item ---
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    final cartCollection = _getCartCollection();
    if (cartCollection != null) {
      if (newQuantity > 0) {
        await cartCollection.doc(productId).update({'quantity': newQuantity});
      } else {
        // Jika kuantitas 0 atau kurang, hapus item
        await cartCollection.doc(productId).delete();
      }
    }
  }

  // --- FUNGSI BARU: Menghapus item dari keranjang ---
  Future<void> removeItem(String productId) async {
    final cartCollection = _getCartCollection();
    if (cartCollection != null) {
      await cartCollection.doc(productId).delete();
    }
  }
}
