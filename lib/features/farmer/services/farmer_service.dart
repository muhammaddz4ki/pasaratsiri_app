// lib/features/farmer/services/farmer_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/request_model.dart';

// Model untuk Harga Pasar (bisa Anda pindah ke file modelnya sendiri jika mau)
class MarketPriceModel {
  final String commodity;
  final int currentPrice;
  final int previousPrice;

  MarketPriceModel({
    required this.commodity,
    required this.currentPrice,
    required this.previousPrice,
  });

  factory MarketPriceModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MarketPriceModel(
      commodity: data['commodityName'] ?? 'N/A',
      currentPrice: data['currentPrice'] ?? 0,
      previousPrice: data['previousPrice'] ?? 0,
    );
  }
}

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- FUNGSI UNTUK FORUM ---

  Future<String?> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return "Pengguna harus login";

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final userName = userData.data()?['name'] ?? 'Petani Anonim';

      await _firestore.collection('posts').add({
        'title': title,
        'content': content,
        'category': category,
        'authorId': user.uid,
        'authorName': userName,
        'createdAt': Timestamp.now(),
        'commentCount': 0,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList(),
        );
  }

  Future<String?> addComment({
    required String postId,
    required String content,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return "Pengguna harus login";

    try {
      final userData = await _firestore.collection('users').doc(user.uid).get();
      final userName = userData.data()?['name'] ?? 'Petani Anonim';

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'content': content,
            'authorId': user.uid,
            'authorName': userName,
            'createdAt': Timestamp.now(),
          });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // --- FUNGSI UNTUK HARGA PASAR ---
  Stream<List<MarketPriceModel>> getMarketPricesStream() {
    return _firestore
        .collection('market_prices')
        .orderBy('commodityName', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MarketPriceModel.fromFirestore(doc))
              .toList();
        });
  }

  // --- FUNGSI LAINNYA YANG SUDAH ADA ---
  Future<void> applyForCertification({
    required String title,
    required String description,
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
      'userName': userName,
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
      return Stream.value([]);
    }

    return _firestore
        .collection('certifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('submittedDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
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
              case 'Disalurkan':
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
        .where('status', isEqualTo: 'Aktif')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Training.fromFirestore(doc))
              .toList();
        });
  }

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
          .doc(userId);

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
