// lib/features/farmer/services/product_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasaratsiri_app/features/farmer/models/product_model.dart';

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<String?> addProduct({
    required String name,
    required double price,
    required String description,
    required String weight,
    required String imageUrl,
    required String category, // <-- TAMBAHKAN INI
  }) async {
    try {
      User? currentUser = getCurrentUser();
      if (currentUser == null) {
        return "Anda harus login untuk menambah produk.";
      }

      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'weight': weight,
        'category': category, // <-- TAMBAHKAN INI
        'sellerId': currentUser.uid,
        'sellerName': currentUser.displayName ?? 'Petani',
        'createdAt': Timestamp.now(),
      });

      return null; // Sukses
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan Firestore.";
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<Product>> getProductsByFarmer() {
    final user = getCurrentUser();
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
        });
  }

  Future<String?> updateProduct({
    required String productId,
    required String name,
    required double price,
    required String description,
    required String weight,
    required String imageUrl,
    required String category,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': name,
        'price': price,
        'description': description,
        'weight': weight,
        'imageUrl': imageUrl,
        'category': category,
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan saat update.";
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message ?? "Terjadi kesalahan saat menghapus.";
    }
  }
}
