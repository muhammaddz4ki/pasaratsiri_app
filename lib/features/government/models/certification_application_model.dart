// lib/features/government/models/certification_application_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CertificationApplication {
  final String id;
  final String applicantName;
  final String title;
  final String status;
  final Timestamp submissionDate;
  
  // --- FIELD BARU YANG DITAMBAHKAN SESUAI KEBUTUHAN UI ---
  final String applicantType;
  final String certificationType;
  final String location;
  final String phoneNumber;
  final String email;
  final List<dynamic> documents; // Tipe data list untuk dokumen

  CertificationApplication({
    required this.id,
    required this.applicantName,
    required this.title,
    required this.status,
    required this.submissionDate,
    // Tambahkan di constructor
    required this.applicantType,
    required this.certificationType,
    required this.location,
    required this.phoneNumber,
    required this.email,
    required this.documents,
  });

  factory CertificationApplication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CertificationApplication(
      id: doc.id,
      applicantName: data['userName'] ?? 'Tanpa Nama', // Asumsi nama pemohon ada di 'userName'
      title: data['title'] ?? 'Tanpa Judul',
      status: data['status'] ?? 'Pending',
      submissionDate: data['submittedDate'] ?? Timestamp.now(),

      // Ambil data baru dari Firestore, berikan nilai default jika tidak ada
      applicantType: data['applicantType'] ?? 'Petani',
      certificationType: data['certificationType'] ?? 'Tidak Diketahui',
      location: data['location'] ?? 'Tidak ada lokasi',
      phoneNumber: data['phoneNumber'] ?? '-',
      email: data['email'] ?? '-',
      documents: data['documents'] as List<dynamic>? ?? [], // Ambil sebagai list
    );
  }
}