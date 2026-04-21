import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/friends/friends_cubit.dart';
import '../../blocs/auth/auth_cubit.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  static const _friendColors = [
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFF9B59B6),
    Color(0xFFF0B27A),
    Color(0xFF45B7D1),
    Color(0xFF006A65),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
              Color(0xFFFFF0F0),
              Color(0xFFF0FBF9),
              Color(0xFFF5F0FF),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocListener<FriendsCubit, FriendsState>(
            listener: (context, state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
                      child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error!, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                  ]),
                  backgroundColor: const Color(0xFFFF6B6B),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ));
                context.read<FriendsCubit>().clearMessages();
              }
              if (state.successMessage != null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.2)),
                      child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.successMessage!, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white))),
                  ]),
                  backgroundColor: const Color(0xFF006A65),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ));
                context.read<FriendsCubit>().clearMessages();
              }
            },
            child: BlocBuilder<FriendsCubit, FriendsState>(
              builder: (context, state) {
                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // ═══ Header ═══
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                                  ).createShader(bounds),
                                  child: const Text(AppStrings.friends, style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  )),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showAddFriendDialog(context),
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4ECDC4), Color(0xFF006A65)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3), blurRadius: 10),
                                      ],
                                    ),
                                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),

                        // ═══ My PicFi ID Card ═══
                        SliverToBoxAdapter(
                          child: Opacity(
                            opacity: _fadeIn.value,
                            child: BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, authState) {
                                final myId = authState.picfiId ?? 'Đang tải...';
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF006A65).withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('PicFi ID của bạn', style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                                              color: Colors.white.withValues(alpha: 0.7),
                                            )),
                                            const SizedBox(height: 2),
                                            Text(myId, style: const TextStyle(
                                              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                                              color: Colors.white, letterSpacing: 1.5,
                                            )),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: myId));
                                          HapticFeedback.mediumImpact();
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: const Text('Đã copy PicFi ID! 📋', style: TextStyle(fontFamily: 'Inter')),
                                            backgroundColor: const Color(0xFF4ECDC4),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            duration: const Duration(seconds: 2),
                                          ));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                                              SizedBox(width: 6),
                                              Text('Copy', style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),

                        // ═══ Friend Requests ═══
                        if (state.requests.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Opacity(
                              opacity: _fadeIn.value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    const Text(AppStrings.friendRequest, style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                    )),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFF0B27A)]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${state.requests.length}', style: const TextStyle(
                                        fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final request = state.requests[index];
                                  final color = _friendColors[index % _friendColors.length];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: color.withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48, height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]),
                                          ),
                                          child: Icon(Icons.person_rounded, color: color, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(request.friendName, style: const TextStyle(
                                                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                                              )),
                                              Text(request.friendEmail ?? '', style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                              )),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            context.read<FriendsCubit>().acceptRequest(request.id);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                                              borderRadius: BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                                              ],
                                            ),
                                            child: const Text(AppStrings.accept, style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                childCount: state.requests.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],

                        // ═══ Friends List Header ═══
                        SliverToBoxAdapter(
                          child: Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideUp.value),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                    const Text('${AppStrings.friends} & Streak', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                    )),
                                    const Spacer(),
                                    Text('${state.friends.length} bạn', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 13,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),

                        // ═══ Empty state ═══
                        if (state.friends.isEmpty)
                          SliverToBoxAdapter(
                            child: Opacity(
                              opacity: _fadeIn.value,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 72, height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [const Color(0xFF4ECDC4).withValues(alpha: 0.15), const Color(0xFFFF6B6B).withValues(alpha: 0.1)],
                                        ),
                                      ),
                                      child: const Icon(Icons.people_alt_rounded, size: 32, color: Color(0xFF4ECDC4)),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Chưa có bạn bè nào', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                    )),
                                    const SizedBox(height: 6),
                                    Text('Chia sẻ PicFi ID để thêm bạn bè!', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    )),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () => _showAddFriendDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Text('Thêm bạn bè', style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
                                        )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // ═══ Friend Cards ═══
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= state.friends.length) return null;
                                final friend = state.friends[index];
                                final color = _friendColors[index % _friendColors.length];

                                return Opacity(
                                  opacity: _fadeIn.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _slideUp.value * (1 + index * 0.15)),
                                    child: GestureDetector(
                                      onTap: () => context.push('/chat', extra: {
                                        'friendId': friend.friendId,
                                        'friendName': friend.friendName,
                                      }),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(color: color.withValues(alpha: 0.1)),
                                          boxShadow: [
                                            BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: friend.streak > 0
                                                    ? LinearGradient(colors: [color, color.withValues(alpha: 0.5)])
                                                    : null,
                                                border: friend.streak == 0
                                                    ? Border.all(color: color.withValues(alpha: 0.3), width: 2)
                                                    : null,
                                              ),
                                              child: Container(
                                                width: 48, height: 48,
                                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                                child: Icon(Icons.person_rounded, color: color, size: 24),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(friend.friendName, style: const TextStyle(
                                                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                                                  )),
                                                  const SizedBox(height: 2),
                                                  Text(friend.friendEmail ?? 'Đang hoạt động', style: TextStyle(
                                                    fontFamily: 'Inter', fontSize: 13,
                                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                  )),
                                                ],
                                              ),
                                            ),
                                            if (friend.streak > 0)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(colors: [Color(0xFFFFA568), Color(0xFFFF6B6B)]),
                                                  borderRadius: BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2), blurRadius: 8),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Text('🔥', style: TextStyle(fontSize: 14)),
                                                    const SizedBox(width: 4),
                                                    Text('${friend.streak}', style: const TextStyle(
                                                      fontFamily: 'Manrope', fontSize: 15, fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 36, height: 36,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: color.withValues(alpha: 0.08),
                                              ),
                                              child: Icon(Icons.chat_bubble_rounded, size: 16, color: color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: state.friends.length,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [const Color(0xFF4ECDC4).withValues(alpha: 0.15), const Color(0xFF006A65).withValues(alpha: 0.1)],
                  ),
                ),
                child: const Icon(Icons.person_add_rounded, size: 28, color: Color(0xFF4ECDC4)),
              ),
              const SizedBox(height: 16),
              const Text('Thêm bạn bè', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 6),
              Text('Nhập PicFi ID của bạn bè (VD: PF-A3B7K9)', style: TextStyle(
                fontFamily: 'Inter', fontSize: 14,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              )),
              const SizedBox(height: 20),
              // Input field
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'PF-______',
                    hintStyle: TextStyle(
                      fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppColors.outline.withValues(alpha: 0.3),
                      letterSpacing: 2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Send button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    final id = controller.text.trim();
                    if (id.isEmpty) return;
                    HapticFeedback.mediumImpact();
                    Navigator.pop(ctx);
                    context.read<FriendsCubit>().sendFriendRequestByPicfiId(id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Center(
                      child: Text('Gửi lời mời kết bạn 🎉', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
