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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Forum Diskusi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF047857), // Emerald-700
                Color(0xFF10B981), // Emerald-500
                Color(0xFF14B8A6), // Teal-500
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _farmerService.getPostsStream(),
        builder: (context, snapshot) {
          // 1. Tampilan ketika data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF14B8A6).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat diskusi...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          // 2. Tampilan jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Gagal memuat forum diskusi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // 3. Tampilan jika tidak ada data sama sekali
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.1),
                          const Color(0xFF14B8A6).withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: const Color(0xFF10B981).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Diskusi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Jadilah yang pertama memulai diskusi!\nBagikan pengalaman atau ajukan pertanyaan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 4. Tampilan utama jika data berhasil didapatkan
          final posts = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
          tooltip: 'Buat Postingan Baru',
        ),
      ),
    );
  }

  // Widget untuk menampilkan satu kartu postingan
  Widget _buildPostCard(PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD1FAE5).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForumDetailScreen(post: post),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris atas: Kategori dan Jumlah Komentar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          color: Color(0xFF047857),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.5,
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
                        const SizedBox(width: 6),
                        Text(
                          post.commentCount.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Judul Postingan
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Author dan Tanggal
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'oleh ${post.authorName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID').format(post.createdAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
