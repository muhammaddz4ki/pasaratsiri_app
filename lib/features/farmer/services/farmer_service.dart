// lib/features/farmer/services/farmer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/request_model.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FUNGSI BARU UNTUK MENYIMPAN DATA PENGAJUAN SERTIFIKASI
  Future<void> applyForCertification({
    required String title,
    required String description,
    // --- TAMBAHAN FIELD BARU ---
    required String applicantType,
    required String certificationType,
    required String location,
    required String phoneNumber,
    required String email,
    required List<String> documents,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User tidak login.');
    final userData = await _firestore.collection('users').doc(user.uid).get();
    final userName = userData.data()?['name'] ?? 'Petani Anonim';

    await _firestore.collection('certifications').add({
      'title': title,
      'description': description,
      'status': 'Pending',
      'submittedDate': Timestamp.now(),
      'userId': user.uid,
      'userName': userName, // Simpan juga nama user
      // --- SIMPAN FIELD BARU ---
      'applicantType': applicantType,
      'certificationType': certificationType,
      'location': location,
      'phoneNumber': phoneNumber,
      'email': email,
      'documents': documents,
    });
  }

  Stream<List<RequestModel>> getMyCertifications() {
    final user = _auth.currentUser;
    if (user == null) {
      // Return stream kosong jika user tidak login
      return Stream.value([]);
    }

    return _firestore
        .collection('certifications')
        .where('userId', isEqualTo: user.uid) // Filter hanya milik user ini
        .orderBy('submittedDate', descending: true) // Urutkan
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Konversi status dari String ke enum RequestStatus
            RequestStatus status;
            switch (data['status']) {
              case 'Disetujui':
                status = RequestStatus.Approved;
                break;
              case 'Ditolak':
                status = RequestStatus.Rejected;
                break;
              default:
                status = RequestStatus.Pending;
            }
            return RequestModel(
              id: doc.id,
              title: data['title'] ?? 'Tanpa Judul',
              description: data['description'] ?? '',
              status: status,
              submittedDate: (data['submittedDate'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }

  Stream<List<RequestModel>> getMySubsidies() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('subsidies')
        .where('userId', isEqualTo: user.uid)
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            RequestStatus status;
            switch (data['status']) {
              case 'Disetujui':
              case 'Disalurkan': // Anggap 'Disalurkan' sama dengan 'Disetujui' di sisi petani
                status = RequestStatus.Approved;
                break;
              case 'Ditolak':
                status = RequestStatus.Rejected;
                break;
              default:
                status = RequestStatus.Pending;
            }
            return RequestModel(
              id: doc.id,
              title: data['title'] ?? 'Tanpa Judul',
              description: data['description'] ?? '',
              status: status,
              submittedDate: (data['submittedDate'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }

  Future<void> applyForSubsidy({
    required String title,
    required String description,
    // --- TAMBAHAN FIELD BARU ---
    required String applicantType,
    required String subsidyType,
    required int subsidyAmount,
    required String location,
    required String farmArea,
    required String phoneNumber,
    required String bankAccount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User tidak login.');
    final userData = await _firestore.collection('users').doc(user.uid).get();
    final userName = userData.data()?['name'] ?? 'Petani Anonim';

    await _firestore.collection('subsidies').add({
      'title': title,
      'description': description,
      'status': 'Pending',
      'submittedDate': Timestamp.now(),
      'userId': user.uid,
      'userName': userName,
      // --- SIMPAN FIELD BARU ---
      'applicantType': applicantType,
      'subsidyType': subsidyType,
      'subsidyAmount': subsidyAmount,
      'location': location,
      'farmArea': farmArea,
      'phoneNumber': phoneNumber,
      'bankAccount': bankAccount,
    });
  }

  Stream<List<Training>> getAvailableTrainings() {
    return _firestore
        .collection('trainings')
        .where('status', isEqualTo: 'Aktif') // Hanya tampilkan yang aktif
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Training.fromFirestore(doc))
              .toList();
        });
  }

  /// Mengecek status pendaftaran seorang user pada sebuah pelatihan.
  Stream<DocumentSnapshot> getRegistrationStatus({
    required String trainingId,
    required String userId,
  }) {
    return _firestore
        .collection('trainings')
        .doc(trainingId)
        .collection('registrants')
        .doc(userId)
        .snapshots();
  }

  Future<String?> registerForTraining({
    required String trainingId,
    required String userId,
    required String userName,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection("trainings")
          .doc(trainingId)
          .collection("registrants")
          .doc(userId); // docId harus sama dengan UID

      await docRef.set({
        "userId": userId,
        "userName": userName,
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
