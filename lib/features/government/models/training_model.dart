// lib/models/training_model.dart (atau sesuaikan path Anda)
import 'package:cloud_firestore/cloud_firestore.dart';

class Training {
  final String id;
  final String title;
  final String category;
  final String organizer;
  final Timestamp date;
  final String time;
  final String location;
  final int maxParticipants;
  final String description;
  final String imageUrl;
  final String status;
  final int currentParticipants;

  Training({
    required this.id,
    required this.title,
    required this.category,
    required this.organizer,
    required this.date,
    required this.time,
    required this.location,
    required this.maxParticipants,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.currentParticipants,
  });

  factory Training.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Training(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      organizer: data['organizer'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      time: data['time'] ?? '',
      location: data['location'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'Selesai',
      currentParticipants: data['currentParticipants'] ?? 0,
    );
  }
}
