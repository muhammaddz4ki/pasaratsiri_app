import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> likes;
  final int likeCount;
  final String? parentCommentId;

  CommentModel({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.likes,
    required this.likeCount,
    this.parentCommentId,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonim',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      likeCount: data['likeCount'] ?? 0,
      parentCommentId: data['parentCommentId'],
    );
  }
}
