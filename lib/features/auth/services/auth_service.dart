import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream untuk memantau perubahan status login pengguna
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi untuk registrasi menggunakan Email dan Password
  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
    required int age,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Simpan informasi tambahan pengguna ke Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': role,
        'age': age,
        'createdAt': Timestamp.now(),
      });
      return null; // Mengembalikan null jika sukses
    } on FirebaseAuthException catch (e) {
      return e.message; // Mengembalikan pesan error dari Firebase
    } catch (e) {
      return e.toString(); // Mengembalikan error umum
    }
  }

  // Fungsi untuk login menggunakan Email dan Password
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Email atau password yang Anda masukkan salah.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk login atau registrasi menggunakan Akun Google
  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Proses login dengan Google dibatalkan.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Jika pengguna benar-benar baru, kembalikan objek User
      // agar UI bisa mengarahkannya ke halaman pemilihan peran.
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        return userCredential.user;
      }

      // Jika pengguna sudah ada (login biasa), kembalikan null (sukses)
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk membuat dokumen pengguna di Firestore setelah daftar via Google
  Future<String?> createUserDocumentFromGoogleSignIn({
    required User user,
    required String role,
  }) async {
    try {
      String uid = user.uid;
      final userDocRef = _firestore.collection('users').doc(uid);

      // Set data pengguna baru
      await userDocRef.set({
        'uid': uid,
        'name': user.displayName ?? 'Pengguna Google',
        'email': user.email,
        'phoneNumber': user.phoneNumber ?? '',
        'role': role, // Ambil peran dari pilihan pengguna
        'createdAt': Timestamp.now(),
        'age': null, // Umur tidak didapat dari Google, bisa diisi nanti
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi untuk mengambil data user yang sedang login
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        return doc.data() as Map<String, dynamic>?;
      } catch (e) {
        debugPrint("Error fetching user data: $e");
        return null;
      }
    }
    return null;
  }

  // Fungsi untuk Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error saat signOut: $e");
    }
  }
}
