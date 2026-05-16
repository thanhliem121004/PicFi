import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/group/group_cubit.dart';
import '../../blocs/friends/friends_cubit.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/friend_entity.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    String? selectedEmoji;
    final List<FriendEntity> selectedFriends = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Tạo nhóm mới', style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Tên nhóm',
                      prefixIcon: const Icon(Icons.group_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F9F8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text('Chọn bạn bè:', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: BlocBuilder<FriendsCubit, FriendsState>(
                    builder: (context, fState) {
                      final friends = fState.friends;
                      if (friends.isEmpty) {
                        return Center(
                          child: Text('Thêm bạn bè trước nhé!',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey.shade500)),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: friends.map((f) {
                          final isSelected = selectedFriends.any((sf) => sf.friendId == f.friendId);
                          return CheckboxListTile(
                            title: Text(f.friendName, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
                            value: isSelected,
                            activeColor: const Color(0xFF006A65),
                            onChanged: (val) {
                              setSheetState(() {
                                if (val == true) {
                                  selectedFriends.add(f);
                                } else {
                                  selectedFriends.removeWhere((sf) => sf.friendId == f.friendId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        HapticFeedback.mediumImpact();
                        context.read<GroupCubit>().createGroup(name, selectedEmoji, selectedFriends);
                        Navigator.pop(ctx);
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
                        child: const Center(child: Text('Tạo nhóm', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                        ))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF0FBF9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                    const Spacer(),
                    const Text('Nhóm chi tiêu', style: TextStyle(
                      fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                    )),
                    const Spacer(),
                    GestureDetector(
                      onTap: _showCreateGroupDialog,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<GroupCubit, GroupState>(
                  builder: (context, state) {
                    if (state.isLoading && state.groups.isEmpty) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)));
                    }
                    if (state.groups.isEmpty) {
                      return Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideUp.value),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72, height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                  ),
                                  child: const Icon(Icons.group_add_rounded,
                                      size: 32, color: Color(0xFF4ECDC4)),
                                ),
                                const SizedBox(height: 16),
                                const Text('Chưa có nhóm nào', style: TextStyle(
                                  fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                )),
                                const SizedBox(height: 8),
                                Text('Tạo nhóm để chia chi tiêu với bạn bè!',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                                      color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final groups = state.groups;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final myMember = group.members.where((m) => m.userId == _getUid()).firstOrNull;
                        final balance = myMember?.balance ?? 0;
                        return Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * (1 + index * 0.1)),
                            child: _GroupCard(
                              group: group,
                              balance: balance,
                              onTap: () => context.push('/group-detail', extra: group.id),
                              onLongPress: () {
                                HapticFeedback.mediumImpact();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa nhóm'),
                                    content: Text('Xóa nhóm "${group.name}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                                      TextButton(onPressed: () {
                                        context.read<GroupCubit>().deleteGroup(group.id);
                                        Navigator.pop(ctx);
                                      }, child: const Text('Xóa', style: TextStyle(color: Color(0xFFFF6B6B)))),
                                    ],
                                  ),
                                );
                              },
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

  String? _getUid() {
    try {
      return context.read<GroupCubit>().hashCode.toString();
    } catch (_) {
      return null;
    }
  }
}

class _GroupCard extends StatelessWidget {
  final GroupEntity group;
  final double balance;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GroupCard({
    required this.group, required this.balance,
    required this.onTap, required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                ),
              ),
              child: Center(
                child: Text(group.emoji ?? '👥', style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 4),
                  Text('${group.members.length} thành viên · ${group.totalExpenses} chi tiêu',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: balance >= 0
                    ? const Color(0xFF4ECDC4).withValues(alpha: 0.08)
                    : const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                balance >= 0
                    ? '+${CurrencyFormatter.format(balance)}'
                    : CurrencyFormatter.format(balance),
                style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800,
                  color: balance >= 0 ? const Color(0xFF006A65) : const Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
