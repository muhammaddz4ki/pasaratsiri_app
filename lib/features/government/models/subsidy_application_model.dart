// lib/features/government/models/subsidy_application_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class SubsidyApplication {
  final String id;
  final String applicantName;
  final String title;
  final String status;
  final Timestamp submissionDate;

  // --- FIELD BARU YANG DITAMBAHKAN SESUAI KEBUTUHAN UI ---
  final String applicantType;
  final String subsidyType;
  final int subsidyAmount; // Kita gunakan int untuk jumlah uang
  final String location;
  final String farmArea;
  final String phoneNumber;
  final String bankAccount;
  final String description;

  SubsidyApplication({
    required this.id,
    required this.applicantName,
    required this.title,
    required this.status,
    required this.submissionDate,
    // Tambahkan di constructor
    required this.applicantType,
    required this.subsidyType,
    required this.subsidyAmount,
    required this.location,
    required this.farmArea,
    required this.phoneNumber,
    required this.bankAccount,
    required this.description,
  });

  factory SubsidyApplication.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SubsidyApplication(
      id: doc.id,
      applicantName: data['userName'] ?? 'Tanpa Nama',
      title: data['title'] ?? 'Tanpa Judul',
      status: data['status'] ?? 'Pending',
      submissionDate: data['submittedDate'] ?? Timestamp.now(),

      // Ambil data baru dari Firestore
      applicantType: data['applicantType'] ?? 'Petani',
      subsidyType: data['subsidyType'] ?? 'Tidak diketahui',
      subsidyAmount: (data['subsidyAmount'] ?? 0).toInt(), // Konversi ke int
      location: data['location'] ?? 'Tidak ada lokasi',
      farmArea: data['farmArea'] ?? '-',
      phoneNumber: data['phoneNumber'] ?? '-',
      bankAccount: data['bankAccount'] ?? '-',
      description: data['description'] ?? 'Tidak ada deskripsi.',
    );
  }
}
