import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
  final _scrollController = ScrollController();
  DocumentSnapshot? _lastFeedDoc;
  bool _hasMoreFeed = true;
  bool _isLoadingMoreFeed = false;
  final List<QueryDocumentSnapshot> _allFeedDocs = [];

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreFeed();
    }
  }

  Future<void> _loadMoreFeed() async {
    if (!_hasMoreFeed || _isLoadingMoreFeed || _lastFeedDoc == null) return;
    setState(() => _isLoadingMoreFeed = true);
    try {
      final snapshot = await _firestore
          .collection('feed')
          .orderBy('sharedAt', descending: true)
          .startAfterDocument(_lastFeedDoc!)
          .limit(20)
          .get();
      final docs = snapshot.docs;
      if (docs.isNotEmpty) {
        _lastFeedDoc = docs.last;
        _hasMoreFeed = docs.length >= 20;
        setState(() {
          _allFeedDocs.addAll(docs);
          _isLoadingMoreFeed = false;
        });
      } else {
        setState(() {
          _hasMoreFeed = false;
          _isLoadingMoreFeed = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingMoreFeed = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
                          .limit(20)
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

                        final streamDocs = snapshot.data?.docs ?? [];
                        if (streamDocs.isNotEmpty && _allFeedDocs.isEmpty) {
                          _lastFeedDoc = streamDocs.last;
                          _hasMoreFeed = streamDocs.length >= 20;
                          _allFeedDocs.addAll(streamDocs);
                        } else if (streamDocs.isEmpty && _allFeedDocs.isNotEmpty) {
                          // Keep existing docs if stream returns empty (e.g. filter)
                        }
                        final docs = _allFeedDocs.isNotEmpty ? _allFeedDocs : streamDocs;

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
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/add-expense');
                                    },
                                    child: Container(
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
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: docs.length + (_isLoadingMoreFeed ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= docs.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF4ECDC4))),
                              );
                            }
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

class _FeedCardState extends State<_FeedCard> with TickerProviderStateMixin {
  bool _fired = false;
  int _fireCount = 0;
  bool _liked = false;
  int _likesCount = 0;
  bool _showHeartAnim = false;
  StreamSubscription? _reactionsSub;
  late AnimationController _heartAnimController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _likesCount = (widget.data['likes'] as num?)?.toInt() ?? 0;
    
    // Check if user already liked/fired
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

    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInBack)), weight: 40),
    ]).animate(_heartAnimController);
  }

  @override
  void dispose() {
    _reactionsSub?.cancel();
    _heartAnimController.dispose();
    super.dispose();
  }

  void _likePost() {
    if (_liked) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _liked = true;
      _likesCount += 1;
      _showHeartAnim = true;
    });
    _heartAnimController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _showHeartAnim = false);
    });
    FirebaseFirestore.instance
        .collection('feed')
        .doc(widget.docId)
        .update({'likes': FieldValue.increment(1)});
  }

  void _toggleLike() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_liked) {
        _liked = false;
        _likesCount = (_likesCount - 1).clamp(0, 999999);
        FirebaseFirestore.instance
            .collection('feed')
            .doc(widget.docId)
            .update({'likes': FieldValue.increment(-1)});
      } else {
        _liked = true;
        _likesCount += 1;
        _showHeartAnim = true;
        _heartAnimController.forward(from: 0.0).then((_) {
          if (mounted) setState(() => _showHeartAnim = false);
        });
        FirebaseFirestore.instance
            .collection('feed')
            .doc(widget.docId)
            .update({'likes': FieldValue.increment(1)});
      }
    });
  }

  Future<void> _toggleFire() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final category = data['category'] as String? ?? 'other';
    final note = data['note'] as String? ?? '';
    final userName = data['userName'] as String? ?? 'Ai đó';
    final sharedAt = (data['sharedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final emoji = data['emoji'] as String? ?? '💸';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (imageUrl != null && imageUrl.isNotEmpty
                    ? Colors.black
                    : cardColors[gradientIdx][0])
                .withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // 1. Core AspectRatio background
            GestureDetector(
              onDoubleTap: _likePost,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: const Color(0xFF0F1413),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(0xFF4ECDC4),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: cardColors[gradientIdx],
                            ),
                          ),
                          child: Center(
                            child: Icon(cat.icon, size: 80, color: Colors.white.withValues(alpha: 0.7)),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: cardColors[gradientIdx],
                          ),
                        ),
                        child: Center(
                          child: Opacity(
                            opacity: 0.1,
                            child: Icon(cat.icon, size: 180, color: Colors.white),
                          ),
                        ),
                      ),
              ),
            ),

            // 2. Linear Gradient Shader overlays for text legibility
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black54,
                      ],
                      stops: [0.0, 0.25, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 3. User Capsule (Top-Left)
            Positioned(
              top: 14,
              left: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.isMe ? 'Bạn' : userName,
                              style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _timeAgo(sharedAt),
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Comments Floating Capsule (Top-Right)
            Positioned(
              top: 14,
              right: 14,
              child: _FloatingGlassButton(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCommentSheet(context, widget.docId);
                },
              ),
            ),

            // 5. Expense Details Overlay (Bottom-Left)
            Positioned(
              bottom: 14,
              left: 14,
              right: 80, // Leave space for reaction buttons on the right
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          child: Icon(cat.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.label,
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '-${CurrencyFormatter.formatShort(amount)}',
                                style: const TextStyle(
                                  fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Locket-style caption overlay on top of the image
            if (note.isNotEmpty)
              Positioned(
                bottom: 82,
                left: 20,
                right: 80, // Leave space for emoji sticker on the right
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // 6. Floating Category Emoji Sticker (Bottom-Right, slightly above fire button)
            Positioned(
              bottom: 74,
              right: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),

            // 7. Floating Heart Reaction / Like (Bottom-Right, next to fire button or above it)
            Positioned(
              bottom: 130,
              right: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _FloatingGlassButton(
                    icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    iconColor: _liked ? const Color(0xFFFF6B6B) : Colors.white,
                    bgColor: _liked ? const Color(0xFFFF6B6B).withValues(alpha: 0.25) : null,
                    onTap: _toggleLike,
                  ),
                  if (_likesCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_likesCount',
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 8. Floating Fire Reaction (Bottom-Right)
            Positioned(
              bottom: 14,
              right: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    scale: _fired ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    child: _FloatingGlassButton(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: _fired ? const Color(0xFFFF9F43) : Colors.white,
                      bgColor: _fired ? const Color(0xFFFF9F43).withValues(alpha: 0.3) : null,
                      onTap: _toggleFire,
                    ),
                  ),
                  if (_fireCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F43),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_fireCount',
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 9. Double-tap Heart Pop Animation
            if (_showHeartAnim)
              Positioned.fill(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _heartScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartScale.value,
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFF6B6B),
                          size: 110,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
        final sheetDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: sheetDark ? const Color(0xFF0F1413) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bình luận',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: sheetDark ? Colors.white : Colors.black,
                ),
              ),
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
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: sheetDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Chưa có bình luận nào',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                color: sheetDark ? Colors.grey.shade500 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: sheetDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        final data = comments[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
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
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: sheetDark ? Colors.white70 : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      data['text'] ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: sheetDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                                      ),
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
                        color: sheetDark ? const Color(0xFF1B2221) : const Color(0xFFF7F9F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: commentCtrl,
                        style: TextStyle(color: sheetDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: sheetDark ? Colors.grey.shade600 : Colors.grey.shade400,
                          ),
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
                      width: 44,
                      height: 44,
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

class _FloatingGlassButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? bgColor;
  final VoidCallback onTap;

  const _FloatingGlassButton({
    required this.icon,
    this.iconColor = Colors.white,
    this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor ?? Colors.black.withValues(alpha: 0.4),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
