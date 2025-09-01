import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Kita belum butuh firebase_storage di sini untuk sementara

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi placeholder untuk menambah produk
  Future<String?> addProduct({
    required String name,
    required double price,
    required String description,
    required String weight,
    required File imageFile,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return "Anda harus login untuk menambah produk.";
      }

      // --- LOGIKA UPLOAD DUMMY ---
      // Di sini seharusnya ada logika untuk upload gambar ke Firebase Storage.
      // Untuk sekarang, kita anggap upload berhasil dan pakai URL placeholder.
      print('--- Simulasi Upload ---');
      print('Gambar yang dipilih: ${imageFile.path}');
      print('Ukuran: ${(imageFile.lengthSync() / 1024).toStringAsFixed(2)} KB');

      String dummyImageUrl =
          "https://firebasestorage.googleapis.com/v0/b/pasarabidin.appspot.com/o/sayur.png?alt=media&token=e8557b7b-9e32-498c-87d3-35f922784013"; // Contoh URL gambar

      // Simpan data produk ke Firestore dengan URL dummy
      await _firestore.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': dummyImageUrl,
        'weight': weight,
        'sellerId': currentUser.uid,
        'sellerName': currentUser.displayName ?? 'Petani',
        'createdAt': Timestamp.now(),
      });

      return null; // Anggap sukses
    } catch (e) {
      return e.toString();
    }
  }
}
