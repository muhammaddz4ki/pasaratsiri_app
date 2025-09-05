// lib/features/farmer/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int commentCount;
  final String category;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.commentCount,
    required this.category,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      commentCount: data['commentCount'] ?? 0,
      category: data['category'] ?? 'Lainnya',
    );
  }
}
