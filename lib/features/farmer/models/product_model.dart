// product_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String weight;
  final String category; // <-- TAMBAHKAN INI
  final String sellerId;
  final String sellerName;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.weight,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      weight: data['weight'] ?? '',
      category: data['category'] ?? 'Lainnya',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
