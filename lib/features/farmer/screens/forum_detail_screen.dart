// lib/features/farmer/screens/forum_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/farmer/models/comment_model.dart';
import 'package:pasaratsiri_app/features/farmer/models/post_model.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class ForumDetailScreen extends StatefulWidget {
  final PostModel post;
  const ForumDetailScreen({super.key, required this.post});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final FarmerService _farmerService = FarmerService();
  final _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isCommenting = false;

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isCommenting = true;
    });

    final result = await _farmerService.addComment(
      postId: widget.post.id,
      content: _commentController.text,
    );

    if (result == null) {
      _commentController.clear();
      // Scroll to bottom after commenting
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim komentar: $result'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isCommenting = false;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Bagian untuk menampilkan isi postingan
                SliverToBoxAdapter(child: _buildPostDetails()),
                // Judul "Komentar"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
                // Bagian untuk menampilkan daftar komentar
                _buildCommentsList(),
              ],
            ),
          ),
          // Bagian untuk input komentar
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                widget.post.authorName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(widget.post.createdAt),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            widget.post.content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<List<CommentModel>>(
      stream: _farmerService.getCommentsStream(widget.post.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Belum ada komentar.'),
              ),
            ),
          );
        }

        final comments = snapshot.data!;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCommentItem(comments[index]),
            childCount: comments.length,
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                comment.authorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM, HH:mm', 'id_ID').format(comment.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isCommenting ? null : _submitComment,
              icon: _isCommenting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
