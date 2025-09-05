import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/shared/screens/chat_screen.dart';
import 'package:pasaratsiri_app/features/shared/services/chat_service.dart';

class FarmerChatListScreen extends StatelessWidget {
  const FarmerChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Gagal memuat daftar pesan."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Belum Ada Pesan",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Saat pembeli menghubungi Anda,\npesan akan muncul di sini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        var chatDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            var chatData = chatDocs[index].data() as Map<String, dynamic>;
            List<dynamic> participants = chatData['participants'];
            String otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
            );

            Map<String, dynamic> participantNames =
                chatData['participantNames'];
            String otherUserName = participantNames[otherUserId] ?? 'Pembeli';

            String lastMessage = chatData['lastMessage'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : 'P',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
                title: Text(
                  otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: otherUserId,
                        receiverName: otherUserName,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
