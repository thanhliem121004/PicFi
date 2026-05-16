import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _markAsRead(String notifId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notifId)
        .update({'isRead': true});
  }

  Future<void> _deleteNotification(String notifId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notifId)
        .delete();
  }

  Future<void> _clearAll() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa tất cả thông báo', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: const Color(0xFF006A65),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final relatedId = data['relatedId'] as String?;

    switch (type) {
      case 'expense_shared':
        if (relatedId != null) context.push('/expense-detail/$relatedId');
        break;
      case 'friend_request':
        context.push('/friends');
        break;
      case 'budget_alert':
        context.push('/profile');
        break;
    }
  }

  String _formatTimestamp(Timestamp ts) {
    final now = DateTime.now();
    final date = ts.toDate();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'expense_shared': return Icons.receipt_long_rounded;
      case 'friend_request': return Icons.person_add_rounded;
      case 'budget_alert': return Icons.account_balance_wallet_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'expense_shared': return const Color(0xFF4ECDC4);
      case 'friend_request': return const Color(0xFF45B7D1);
      case 'budget_alert': return const Color(0xFFFF6B6B);
      default: return const Color(0xFF9B59B6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FBF9),
              Color(0xFFFFF8F0),
              Color(0xFFF5F0FF),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFF4ECDC4).withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
                      ).createShader(bounds),
                      child: const Text('Thông báo', style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      )),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _clearAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_sweep_rounded, size: 16, color: Color(0xFFFF6B6B)),
                            SizedBox(width: 4),
                            Text(AppStrings.clearAll, style: TextStyle(
                              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B6B),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Notifications list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_userId)
                      .collection('notifications')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('Không thể tải thông báo', style: TextStyle(fontFamily: 'Inter', fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4ECDC4)));
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [const Color(0xFF4ECDC4).withValues(alpha: 0.15), const Color(0xFFFF6B6B).withValues(alpha: 0.1)],
                                ),
                              ),
                              child: const Icon(Icons.notifications_off_rounded, size: 36, color: Color(0xFF4ECDC4)),
                            ),
                            const SizedBox(height: 16),
                            const Text(AppStrings.noNotifications, style: TextStyle(
                              fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                            )),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final id = doc.id;
                        final type = data['type'] as String? ?? '';
                        final title = data['title'] as String? ?? '';
                        final body = data['body'] as String? ?? '';
                        final isRead = data['isRead'] as bool? ?? false;
                        final createdAt = data['createdAt'] as Timestamp? ?? Timestamp.now();

                        return Dismissible(
                          key: Key(id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRead ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: Icon(
                              isRead ? Icons.delete_rounded : Icons.check_rounded,
                              color: Colors.white, size: 28,
                            ),
                          ),
                          onDismissed: (_) {
                            HapticFeedback.lightImpact();
                            if (isRead) {
                              _deleteNotification(id);
                            } else {
                              _markAsRead(id);
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              if (!isRead) _markAsRead(id);
                              _onNotificationTap(data);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isRead
                                      ? Colors.transparent
                                      : _typeColor(type).withValues(alpha: 0.15),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isRead ? 0.02 : 0.05),
                                    blurRadius: 10, offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          color: _typeColor(type).withValues(alpha: 0.1),
                                        ),
                                        child: Icon(_typeIcon(type), size: 24, color: _typeColor(type)),
                                      ),
                                      if (!isRead)
                                        Positioned(
                                          top: 0, right: 0,
                                          child: Container(
                                            width: 10, height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _typeColor(type),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 15,
                                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                            color: AppColors.onSurface,
                                          ),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          body,
                                          style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 13,
                                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                          ),
                                          maxLines: 2, overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTimestamp(createdAt),
                                    style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 11,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
