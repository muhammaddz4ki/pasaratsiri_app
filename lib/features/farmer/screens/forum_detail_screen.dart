// lib/features/farmer/screens/forum_detail_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/farmer/models/comment_model.dart';
import 'package:pasaratsiri_app/features/farmer/models/post_model.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class ForumDetailScreen extends StatefulWidget {
  final String postId;
  const ForumDetailScreen({super.key, required this.postId});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  final FarmerService _farmerService = FarmerService();
  final _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isCommenting = false;
  CommentModel? _replyingToComment;

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isCommenting = true);

    final result = await _farmerService.addComment(
      postId: widget.postId,
      content: _commentController.text.trim(),
      parentCommentId: _replyingToComment?.id,
    );

    if (mounted) {
      if (result == null) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
        setState(() {
          _replyingToComment = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim komentar: $result'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isCommenting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PostModel>(
      stream: _farmerService.getPostStream(widget.postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Postingan')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Gagal memuat postingan: ${snapshot.error}'),
            ),
          );
        }

        final post = snapshot.data!;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildSliverAppBar(post),
                    SliverToBoxAdapter(child: _buildPostDetails(post)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          'Komentar (${post.commentCount})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    _buildCommentsList(post.id),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ), // Spasi di bawah
                  ],
                ),
              ),
              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(PostModel post) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.green.shade700,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
        centerTitle: false,
        title: Text(
          post.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8.0, color: Colors.black54)],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        background: (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Icon(
                        Icons.broken_image_rounded,
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[Colors.transparent, Colors.black87],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: Colors.green.shade600),
      ),
    );
  }

  Widget _buildPostDetails(PostModel post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isLikedByMe =
        currentUser != null && post.likes.contains(currentUser.uid);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                post.authorName,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const Spacer(),
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(post.createdAt),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              InkWell(
                onTap: () => _farmerService.togglePostLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 18,
                      color: isLikedByMe
                          ? Colors.blue.shade700
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likeCount} Suka',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentCount} Komentar',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(String postId) {
    return StreamBuilder<List<CommentModel>>(
      stream: _farmerService.getCommentsStream(postId),
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

        final allComments = snapshot.data!;
        final topLevelComments = allComments
            .where((c) => c.parentCommentId == null)
            .toList();
        final repliesMap = <String, List<CommentModel>>{};

        for (var comment in allComments) {
          if (comment.parentCommentId != null) {
            repliesMap
                .putIfAbsent(comment.parentCommentId!, () => [])
                .add(comment);
          }
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final comment = topLevelComments[index];
            final replies = repliesMap[comment.id] ?? [];
            return Column(
              children: [
                _buildCommentItem(comment),
                if (replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 8.0),
                    child: Column(
                      children: replies
                          .map((reply) => _buildCommentItem(reply))
                          .toList(),
                    ),
                  ),
              ],
            );
          }, childCount: topLevelComments.length),
        );
      },
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isLiked =
        currentUser != null && comment.likes.contains(currentUser.uid);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: comment.parentCommentId == null
            ? Colors.white
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
          Text(
            comment.content,
            style: const TextStyle(color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _farmerService.toggleCommentLike(
                    postId: widget.postId,
                    commentId: comment.id,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 18,
                          color: isLiked
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comment.likeCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _replyingToComment = comment;
                    });
                    _commentFocusNode.requestFocus();
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Balas',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          // --- PERBAIKAN: 'const' dihapus dari sini ---
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToComment != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  bottom: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Membalas kepada @${_replyingToComment!.authorName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          _replyingToComment = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
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
          ],
        ),
      ),
    );
  }
}
