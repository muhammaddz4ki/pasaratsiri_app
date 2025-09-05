// lib/features/government/services/government_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasaratsiri_app/features/government/models/certification_application_model.dart';
import 'package:pasaratsiri_app/features/government/models/subsidy_application_model.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';

class MarketPrice {
  final String id;
  final String commodityName;
  final int currentPrice;
  final int previousPrice;
  final Timestamp lastUpdate;

  MarketPrice({
    required this.id,
    required this.commodityName,
    required this.currentPrice,
    required this.previousPrice,
    required this.lastUpdate,
  });

  factory MarketPrice.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MarketPrice(
      id: doc.id,
      commodityName: data['commodityName'] ?? '',
      currentPrice: data['currentPrice'] ?? 0,
      previousPrice: data['previousPrice'] ?? 0,
      lastUpdate: data['lastUpdate'] ?? Timestamp.now(),
    );
  }
}

class GovernmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- FUNGSI UNTUK SERTIFIKASI ---

  Stream<List<CertificationApplication>> getCertificationApplications() {
    return _firestore
        .collection('certifications')
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CertificationApplication.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String?> updateCertificationStatus(
    String docId,
    String newStatus,
  ) async {
    try {
      await _firestore.collection('certifications').doc(docId).update({
        'status': newStatus,
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  // --- FUNGSI UNTUK SUBSIDI ---

  Stream<List<SubsidyApplication>> getSubsidyApplications() {
    return _firestore
        .collection('subsidies')
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubsidyApplication.fromFirestore(doc))
              .toList(),
        );
  }

  Future<String?> updateSubsidyStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('subsidies').doc(docId).update({
        'status': newStatus,
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Stream<List<Training>> getTrainings() {
    return _firestore
        .collection('trainings')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Training.fromFirestore(doc)).toList(),
        );
  }

  Future<String?> addTraining({
    required String title,
    required String category,
    required String organizer,
    required Timestamp date,
    required String time,
    required String location,
    required int maxParticipants,
    required String description,
    required String imageUrl,
  }) async {
    try {
      await _firestore.collection('trainings').add({
        'title': title,
        'category': category,
        'organizer': organizer,
        'date': date,
        'time': time,
        'location': location,
        'maxParticipants': maxParticipants,
        'description': description,
        'imageUrl': imageUrl,
        'status': 'Aktif', // Status default saat dibuat
        'currentParticipants': 0, // Peserta awal
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future<String?> deleteTraining(String trainingId) async {
    try {
      await _firestore.collection('trainings').doc(trainingId).delete();
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateMarketPrice({
    required String commodityId, // e.g., 'cengkeh'
    required String commodityName, // e.g., 'Cengkeh'
    required int newPrice,
    required String updatedBy,
  }) async {
    try {
      final docRef = _firestore.collection('market_prices').doc(commodityId);
      final docSnapshot = await docRef.get();

      int previousPrice = 0;
      if (docSnapshot.exists) {
        // Jika dokumen sudah ada, ambil harga saat ini sebagai harga sebelumnya
        previousPrice = docSnapshot.data()!['currentPrice'] as int;
      }

      await docRef.set(
        {
          'commodityName': commodityName,
          'currentPrice': newPrice,
          'previousPrice': previousPrice, // Simpan harga lama
          'lastUpdate': Timestamp.now(),
          'updatedBy': updatedBy,
        },
        SetOptions(merge: true),
      ); // Gunakan merge agar tidak menimpa field lain

      return null; // Sukses
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  // Fungsi untuk mendapatkan riwayat (opsional, jika Anda ingin menampilkan riwayat dari firestore)
  Stream<List<Map<String, dynamic>>> getPriceHistory() {
    return _firestore
        .collection(
          'market_prices',
        ) // Anda bisa buat collection history terpisah jika perlu
        .orderBy('lastUpdate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
