// lib/features/farmer/screens/forum_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/farmer/models/post_model.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';
import 'add_post_screen.dart';
import 'forum_detail_screen.dart';

class ForumListScreen extends StatefulWidget {
  const ForumListScreen({super.key});

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  final FarmerService _farmerService = FarmerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<PostModel>>(
        stream: _farmerService.getPostsStream(),
        builder: (context, snapshot) {
          // 1. Tampilan ketika data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Tampilan jika terjadi error
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          // 3. Tampilan jika tidak ada data sama sekali
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada postingan.\nJadilah yang pertama memulai diskusi!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. Tampilan utama jika data berhasil didapatkan
          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigasi ke halaman buat post baru')),
          );
        },
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Buat Postingan Baru',
      ),
    );
  }

  // Widget untuk menampilkan satu kartu postingan
  Widget _buildPostCard(PostModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ForumDetailScreen(post: post),
            ),
          );
          // --- AKHIR PERUBAHAN ---
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Kategori dan Jumlah Komentar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      post.category,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.commentCount.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Judul Postingan
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Author dan Tanggal
              Text(
                'oleh ${post.authorName} • ${DateFormat('d MMM yyyy', 'id_ID').format(post.createdAt)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
