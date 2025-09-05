import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan stream pesan antara 2 user (Tidak ada perubahan)
  Stream<QuerySnapshot> getMessages(String receiverId) {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Mendapatkan daftar ruang chat untuk user saat ini (Tidak ada perubahan)
  Stream<QuerySnapshot> getChatRooms() {
    final String currentUserId = _auth.currentUser!.uid;
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // Mengirim pesan baru (LOGIKA DIPERBAIKI)
  Future<void> sendMessage(String receiverId, String text) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // Buat objek pesan baru
    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
    );

    // Buat ID ruang chat
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // --- PERUBAHAN LOGIKA DIMULAI DI SINI ---

    // 1. BUAT DOKUMEN CHAT ROOM DULU untuk memastikan permission-nya lolos
    DocumentSnapshot receiverDoc = await _firestore
        .collection('users')
        .doc(receiverId)
        .get();
    String receiverName =
        (receiverDoc.data() as Map<String, dynamic>)['name'] ?? 'User';

    DocumentSnapshot senderDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    String senderName =
        (senderDoc.data() as Map<String, dynamic>)['name'] ?? 'User';

    // Perintah .set() dengan merge:true akan membuat dokumen jika belum ada,
    // atau memperbarui jika sudah ada.
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'participants': ids,
      'participantNames': {currentUserId: senderName, receiverId: receiverName},
      'lastMessage': text,
      'lastMessageSenderId': currentUserId,
      'lastMessageTimestamp': timestamp,
    }, SetOptions(merge: true));

    // 2. BARU SIMPAN PESAN ke dalam sub-koleksi
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Untuk mendapatkan data user berdasarkan ID (Tidak ada perubahan)
  Future<DocumentSnapshot> getUserDetails(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
