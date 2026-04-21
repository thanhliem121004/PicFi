import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                          return const Center(child: CircularProgressIndicator(
                            color: Color(0xFF4ECDC4),
                          ));
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

                        return ListView.builder(
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('Tính năng bình luận sắp ra mắt! 💬', style: TextStyle(fontFamily: 'Inter')),
                              backgroundColor: const Color(0xFF4ECDC4),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          },
                        ),
                        const Spacer(),
                        // Fire reaction
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text('🔥🔥🔥', style: TextStyle(fontSize: 20)),
                              backgroundColor: const Color(0xFFF0B27A),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 800),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0B27A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('🔥', style: TextStyle(fontSize: 18)),
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
