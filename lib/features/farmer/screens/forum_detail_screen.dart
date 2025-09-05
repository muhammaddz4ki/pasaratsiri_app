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

  // Define the emerald color palette
  final Color emeraldPrimary = const Color(0xFF10B981); // Emerald-500
  final Color emeraldSecondary = const Color(0xFF14B8A6); // Teal-500
  final Color emeraldDark = const Color(0xFF047857); // Emerald-700
  final Color emeraldLight = const Color(0xFFD1FAE5); // Emerald-100
  final Color emeraldUltraLight = const Color(0xFFECFDF5); // Emerald-50

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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        title: const Text('Detail Diskusi'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [emeraldPrimary, emeraldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.8],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality
            },
          ),
        ],
      ),
      backgroundColor: emeraldUltraLight,
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      children: [
                        Text(
                          'Komentar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: emeraldDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: emeraldLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: StreamBuilder<List<CommentModel>>(
                            stream: _farmerService.getCommentsStream(
                              widget.post.id,
                            ),
                            builder: (context, snapshot) {
                              final count = snapshot.hasData
                                  ? snapshot.data!.length
                                  : 0;
                              return Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: emeraldDark,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bagian untuk menampilkan daftar komentar
                _buildCommentsList(),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, emeraldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: emeraldPrimary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: emeraldDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: emeraldUltraLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, size: 16, color: emeraldDark),
              ),
              const SizedBox(width: 8),
              Text(
                widget.post.authorName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: emeraldDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: emeraldUltraLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: emeraldDark,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(widget.post.createdAt),
                style: TextStyle(
                  fontSize: 14,
                  color: emeraldDark.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: emeraldLight, height: 1, thickness: 1),
          const SizedBox(height: 16),
          Text(
            widget.post.content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          // Post metrics (likes, comments, etc.)
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 18,
                color: emeraldDark.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                '12 Suka',
                style: TextStyle(
                  fontSize: 14,
                  color: emeraldDark.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.comment_outlined,
                size: 18,
                color: emeraldDark.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              StreamBuilder<List<CommentModel>>(
                stream: _farmerService.getCommentsStream(widget.post.id),
                builder: (context, snapshot) {
                  final count = snapshot.hasData ? snapshot.data!.length : 0;
                  return Text(
                    '$count Komentar',
                    style: TextStyle(
                      fontSize: 14,
                      color: emeraldDark.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ],
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
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(emeraldPrimary),
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: emeraldLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada komentar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: emeraldDark.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jadilah yang pertama berkomentar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [emeraldPrimary, emeraldSecondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  comment.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: emeraldDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM, HH:mm', 'id_ID').format(comment.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              comment.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  'Suka',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.reply,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  'Balas',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [emeraldPrimary, emeraldSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: emeraldUltraLight,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [emeraldPrimary, emeraldSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: emeraldPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isCommenting ? null : _submitComment,
                icon: _isCommenting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
