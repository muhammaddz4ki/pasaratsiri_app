import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a single message
class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  // Method to convert a Message object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
