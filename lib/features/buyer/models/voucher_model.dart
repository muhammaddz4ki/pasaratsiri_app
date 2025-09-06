// lib/features/buyer/models/voucher_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String title;
  final int discountValue;
  final int minSpend;

  Voucher({
    required this.id,
    required this.title,
    required this.discountValue,
    required this.minSpend,
  });

  factory Voucher.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Voucher(
      id: doc.id,
      title: data['title'] ?? 'Tanpa Judul',
      discountValue: (data['discountValue'] as num? ?? 0).toInt(),
      minSpend: (data['minSpend'] as num? ?? 0).toInt(),
    );
  }
}
