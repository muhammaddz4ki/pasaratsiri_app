import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- BARIS INI DITAMBAHKAN
import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/shared/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      // Salin teks dan bersihkan field input secepatnya untuk responsivitas UI
      String messageText = _messageController.text;
      _messageController.clear();

      // Kirim pesan menggunakan service
      await _chatService.sendMessage(widget.receiverId, messageText);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        // Memberi warna latar belakang yang lembut
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // Expanded akan membuat daftar pesan memenuhi sisa ruang
            Expanded(child: _buildMessageList()),

            // Input untuk mengetik pesan
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Widget untuk membangun daftar pesan dari Firestore
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      // Mendengarkan pesan secara real-time dari ChatService
      stream: _chatService.getMessages(widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Gagal memuat pesan. Silakan coba lagi."),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Belum ada pesan.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const Text(
                  "Mulai percakapan dengan mengirim pesan pertama.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Fungsi ini akan otomatis scroll ke bawah setiap kali ada pesan baru
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  // Widget untuk membangun satu gelembung pesan (chat bubble)
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Cek apakah pengirim pesan adalah pengguna saat ini
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    return Align(
      // Atur posisi bubble: kanan untuk 'saya', kiri untuk 'orang lain'
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // Atur warna bubble
          color: isMe ? Colors.green.shade600 : Colors.white,
          // Atur sudut bubble agar terlihat seperti aplikasi chat pada umumnya
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          data['text'],
          style: TextStyle(
            fontSize: 16,
            color: isMe ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  // Widget untuk membangun field input dan tombol kirim
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _sendMessage,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
