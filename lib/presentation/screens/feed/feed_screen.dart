import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/shimmer_loading.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0F0),
              Color(0xFFF0FBF9),
              Color(0xFFF5F0FF),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _entryController,
            builder: (context, _) {
              return Column(
                children: [
                  // ═══ Header ═══
                  Opacity(
                    opacity: _fadeIn.value,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
                            ).createShader(bounds),
                            child: const Text('Bảng tin', style: TextStyle(
                              fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                  const Color(0xFFF0B27A).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_rounded, size: 16, color: Color(0xFFFF6B6B)),
                                SizedBox(width: 4),
                                Text('Bạn bè', style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ═══ Feed List ═══
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('feed')
                          .orderBy('sharedAt', descending: true)
                          .limit(50)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return ShimmerLoading(
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: 4,
                              itemBuilder: (_, __) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ShimmerPlaceholder(height: 340, borderRadius: 24),
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return Opacity(
                            opacity: _fadeIn.value,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 100, height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                                          const Color(0xFFF0B27A).withValues(alpha: 0.1),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(Icons.dynamic_feed_rounded, size: 44, color: Color(0xFFFF6B6B)),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Bảng tin trống', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                                  )),
                                  const SizedBox(height: 8),
                                  Text('Chia sẻ chi tiêu để bạn bè cùng xem nhé!', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 15,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                  )),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.share_rounded, size: 18, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Thêm chi tiêu & chia sẻ', style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: const Color(0xFF4ECDC4),
                          onRefresh: () async {
                            await Future.delayed(const Duration(milliseconds: 500));
                          },
                          child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final isMe = data['userId'] == uid;

                            return Opacity(
                              opacity: _fadeIn.value,
                              child: Transform.translate(
                                offset: Offset(0, _slideUp.value * (1 + index * 0.1).clamp(1.0, 2.0)),
                                child: _FeedCard(
                                  data: data,
                                  isMe: isMe,
                                  docId: docs[index].id,
                                ),
                              ),
                            );
                          },
                        ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
class _FeedCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final String docId;

  const _FeedCard({required this.data, required this.isMe, required this.docId});

  @override
  State<_FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<_FeedCard> {
  bool _liked = false;
  bool _fired = false;
  int _fireCount = 0;
  StreamSubscription? _reactionsSub;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _reactionsSub = FirebaseFirestore.instance
          .collection('feed')
          .doc(widget.docId)
          .collection('reactions')
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;
        final docs = snapshot.docs;
        final count = docs.length;
        final hasFired = docs.any((d) => d.id == uid);
        setState(() {
          _fireCount = count;
          _fired = hasFired;
        });
      });
    }
  }

  @override
  void dispose() {
    _reactionsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final category = data['category'] as String? ?? 'other';
    final note = data['note'] as String? ?? '';
    final userName = data['userName'] as String? ?? 'Ai đó';
    final userPicfiId = data['userPicfiId'] as String? ?? '';
    final sharedAt = (data['sharedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final emoji = data['emoji'] as String? ?? '💸';
    final likes = (data['likes'] as num?)?.toInt() ?? 0;
    final imageUrl = data['imageUrl'] as String?;

    final cat = ExpenseCategory.values.firstWhere(
      (c) => c.name == category,
      orElse: () => ExpenseCategory.other,
    );

    final cardColors = [
      [const Color(0xFF006A65), const Color(0xFF4ECDC4)],
      [const Color(0xFF9B59B6), const Color(0xFF6C5CE7)],
      [const Color(0xFFFF6B6B), const Color(0xFFF0B27A)],
      [const Color(0xFF45B7D1), const Color(0xFF4ECDC4)],
    ];
    final gradientIdx = userName.hashCode.abs() % cardColors.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColors[gradientIdx][0].withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header gradient
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: cardColors[gradientIdx],
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isMe ? 'Bạn' : userName,
                          style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (userPicfiId.isNotEmpty)
                          Text('@$userPicfiId', style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          )),
                      ],
                    ),
                  ),
                  Text(
                    _timeAgo(sharedAt),
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Photo (if exists)
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 200, color: const Color(0xFFF7F9F8),
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4ECDC4))),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cat.color.withValues(alpha: 0.15), cat.color.withValues(alpha: 0.05)],
                          ),
                        ),
                        child: Icon(cat.icon, color: cat.color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.isNotEmpty ? note : cat.label,
                              style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(cat.label, style: TextStyle(
                                fontFamily: 'Inter', fontSize: 11,
                                fontWeight: FontWeight.w600, color: cat.color,
                              )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '-${CurrencyFormatter.formatShort(amount)}',
                              style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w800,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Action row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Like
                        _ActionChip(
                          icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          label: '${likes + (_liked ? 1 : 0)}',
                          color: const Color(0xFFFF6B6B),
                          isActive: _liked,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() => _liked = !_liked);
                            if (_liked) {
                              FirebaseFirestore.instance
                                  .collection('feed')
                                  .doc(widget.docId)
                                  .update({'likes': FieldValue.increment(1)});
                            } else {
                              FirebaseFirestore.instance
                                  .collection('feed')
                                  .doc(widget.docId)
                                  .update({'likes': FieldValue.increment(-1)});
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        // Comment
                        _ActionChip(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Bình luận',
                          color: const Color(0xFF4ECDC4),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showCommentSheet(context, widget.docId);
                          },
                        ),
                        const Spacer(),
                        // Fire reaction
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            final ref = FirebaseFirestore.instance
                                .collection('feed')
                                .doc(widget.docId)
                                .collection('reactions')
                                .doc(uid);
                            if (_fired) {
                              await ref.delete();
                            } else {
                              await ref.set({
                                'emoji': '🔥',
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _fired
                                  ? const Color(0xFFF0B27A).withValues(alpha: 0.25)
                                  : const Color(0xFFF0B27A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔥', style: TextStyle(fontSize: 18)),
                                if (_fireCount > 0) ...[
                                  const SizedBox(width: 4),
                                  Text('$_fireCount', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                    color: _fired ? const Color(0xFFF0B27A) : AppColors.onSurfaceVariant,
                                  )),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentSheet(BuildContext context, String postId) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 16),
              const Text('Bình luận', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('feed')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    final comments = snapshot.data?.docs ?? [];
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Chưa có bình luận nào', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 15,
                              color: Colors.grey.shade500,
                            )),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final data = comments[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                                ),
                                child: const Icon(Icons.person_rounded, size: 20, color: Color(0xFF4ECDC4)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['userName'] ?? 'Ai đó',
                                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['text'] ?? '',
                                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final text = commentCtrl.text.trim();
                      if (text.isEmpty) return;
                      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final userName = widget.data['userName'] as String? ?? 'Ai đó';
                      await FirebaseFirestore.instance
                          .collection('feed')
                          .doc(postId)
                          .collection('comments')
                          .add({
                        'userId': uid,
                        'userName': userName,
                        'text': text,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      commentCtrl.clear();
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    if (diff.inDays < 7) return '${diff.inDays}d trước';
    return '${dt.day}/${dt.month}';
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon, required this.label,
    required this.color, this.isActive = false, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? color : AppColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
              color: isActive ? color : AppColors.onSurfaceVariant,
            )),
          ],
        ),
      ),
    );
  }
}
