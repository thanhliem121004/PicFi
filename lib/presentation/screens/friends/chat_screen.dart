import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/chat_message.dart';
import '../../blocs/friends/friends_cubit.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({super.key, required this.friendId, required this.friendName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    context.read<FriendsCubit>().sendMessage(widget.friendId, text);
    _msgController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1200,
    );
    if (picked == null) return;
    HapticFeedback.lightImpact();
    try {
      final uid = _myUid;
      final ref = FirebaseStorage.instance
          .ref('chats/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(File(picked.path));
      final imageUrl = await ref.getDownloadURL();
      if (!mounted) return;
      context.read<FriendsCubit>().sendMessage(widget.friendId, '📷 Ảnh', imageUrl: imageUrl);
      _scrollToBottom();
    } catch (_) {}
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
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ═══ App Bar ═══
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
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
                    // Avatar with gradient ring
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
                      ),
                      child: Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        child: const Icon(Icons.person_rounded, color: Color(0xFF4ECDC4), size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.friendName, style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                          )),
                          Row(
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4ECDC4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('Đang hoạt động', style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12, color: Color(0xFF4ECDC4),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Streak badge
                    BlocBuilder<FriendsCubit, FriendsState>(
                      builder: (context, state) {
                        final friend = state.friends.where((f) => f.friendId == widget.friendId).firstOrNull;
                        final streak = friend?.streak ?? 0;
                        if (streak <= 0) return const SizedBox();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFA568), Color(0xFFFF6B6B)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Text('$streak', style: const TextStyle(
                                fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white,
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ═══ Messages — StreamBuilder from Firestore ═══
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: context.read<FriendsCubit>().getChatStream(widget.friendId),
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
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
                              child: const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: Color(0xFF4ECDC4)),
                            ),
                            const SizedBox(height: 16),
                            const Text('Bắt đầu cuộc trò chuyện!', style: TextStyle(
                              fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                            )),
                            const SizedBox(height: 6),
                            Text('Gửi tin nhắn đầu tiên cho ${widget.friendName} 👋', style: TextStyle(
                              fontFamily: 'Inter', fontSize: 14,
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            )),
                          ],
                        ),
                      );
                    }

                    // Auto-scroll when new messages arrive
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == _myUid;
                        final showAvatar = !isMe && (index == 0 || messages[index - 1].senderId != msg.senderId);
                        final showTime = index == 0 ||
                            msg.timestamp.difference(messages[index - 1].timestamp).inMinutes > 5;

                        return Column(
                          children: [
                            if (showTime)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _formatTime(msg.timestamp),
                                    style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 11,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe) ...[
                                    if (showAvatar)
                                      Container(
                                        width: 30, height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFF4ECDC4).withValues(alpha: 0.2), const Color(0xFF4ECDC4).withValues(alpha: 0.05)],
                                          ),
                                        ),
                                        child: const Icon(Icons.person_rounded, color: Color(0xFF4ECDC4), size: 16),
                                      )
                                    else
                                      const SizedBox(width: 30),
                                    const SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: isMe
                                            ? const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                              )
                                            : null,
                                        color: isMe ? null : Colors.white.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(20),
                                          topRight: const Radius.circular(20),
                                          bottomLeft: Radius.circular(isMe ? 20 : 6),
                                          bottomRight: Radius.circular(isMe ? 6 : 20),
                                        ),
                                        border: isMe ? null : Border.all(
                                          color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isMe
                                                ? const Color(0xFF006A65).withValues(alpha: 0.15)
                                                : Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                    child: Column(
                                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 6),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: msg.imageUrl!,
                                                width: 200,
                                                height: 150,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => Container(
                                                  width: 200, height: 150,
                                                  color: Colors.grey.withValues(alpha: 0.1),
                                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (msg.message != '📷 Ảnh')
                                          Text(
                                            msg.message,
                                            style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 15,
                                              color: isMe ? Colors.white : AppColors.onSurface,
                                              height: 1.4,
                                            ),
                                          ),
                                      ],
                                    ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              // ═══ Input Bar ═══
              Container(
                padding: EdgeInsets.fromLTRB(12, 10, 8, MediaQuery.of(context).padding.bottom + 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  border: Border(
                    top: BorderSide(color: const Color(0xFF4ECDC4).withValues(alpha: 0.1)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                      ),
                      child: GestureDetector(
                        onTap: _sendPhoto,
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4ECDC4), size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9F8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.1)),
                        ),
                        child: TextField(
                          controller: _msgController,
                          decoration: InputDecoration(
                            hintText: AppStrings.typeMessage,
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              fontFamily: 'Inter', fontSize: 15,
                              color: AppColors.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (msgDay == today) {
      return 'Hôm nay $time';
    } else if (today.difference(msgDay).inDays == 1) {
      return 'Hôm qua $time';
    }
    return '${dt.day}/${dt.month} $time';
  }
}
