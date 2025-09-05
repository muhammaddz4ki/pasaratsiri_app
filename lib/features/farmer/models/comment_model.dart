// lib/features/farmer/models/comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
