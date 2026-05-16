import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../blocs/group/group_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/group_entity.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
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

  void _showAddExpenseSheet(GroupEntity group) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Thêm chi tiêu nhóm', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    hintText: 'Mô tả',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true, fillColor: const Color(0xFFF7F9F8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Số tiền',
                    prefixText: 'đ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true, fillColor: const Color(0xFFF7F9F8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      final desc = descController.text.trim();
                      final amount = double.tryParse(amountController.text);
                      if (desc.isEmpty || amount == null || amount <= 0) return;
                      HapticFeedback.mediumImpact();
                      final memberIds = group.members.map((m) => m.userId).toList();
                      context.read<GroupCubit>().addGroupExpense(
                        groupId: widget.groupId,
                        description: desc,
                        amount: amount,
                        paidBy: uid,
                        splitType: SplitType.equal,
                        memberIds: memberIds,
                      );
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF006A65).withValues(alpha: 0.25), blurRadius: 12)],
                      ),
                      child: const Center(child: Text('Thêm chi tiêu', style: TextStyle(
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
        child: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, state) {
            final group = state.groups.where((g) => g.id == widget.groupId).firstOrNull;
            if (group == null) {
              return const Center(child: Text('Nhóm không tồn tại'));
            }

            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            final myMember = group.members.where((m) => m.userId == uid).firstOrNull;
            final balance = myMember?.balance ?? 0;

            return SafeArea(
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
                        Text(group.name, style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
                        )),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showAddExpenseSheet(group),
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
                  const SizedBox(height: 16),

                  Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideUp.value * 0.5),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tổng chi tiêu', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    )),
                                    const SizedBox(height: 4),
                                    Text(CurrencyFormatter.format(group.totalAmount), style: const TextStyle(
                                      fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    )),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Số dư của tôi', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    )),
                                    const SizedBox(height: 4),
                                    Text(
                                      balance >= 0
                                          ? '+${CurrencyFormatter.format(balance)}'
                                          : CurrencyFormatter.format(balance),
                                      style: TextStyle(
                                        fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                                        color: balance >= 0 ? Colors.white : const Color(0xFFFF6B6B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        Text('Thành viên', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                        )),
                        const SizedBox(height: 8),
                        ...group.members.map((member) {
                          return Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideUp.value),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (member.displayName ?? '').isNotEmpty
                                              ? (member.displayName ?? '')[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                                            color: Color(0xFF006A65),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(member.displayName ?? 'Unknown', style: const TextStyle(
                                            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                                          )),
                                          Text(
                                            member.userId == uid ? 'Bạn' : 'Đã chi ${CurrencyFormatter.format(member.totalPaid)}',
                                            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: member.balance >= 0
                                            ? const Color(0xFF4ECDC4).withValues(alpha: 0.08)
                                            : const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        member.balance >= 0
                                            ? 'Được ${CurrencyFormatter.format(member.balance)}'
                                            : 'Nợ ${CurrencyFormatter.format(member.balance.abs())}',
                                        style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                                          color: member.balance >= 0
                                              ? const Color(0xFF006A65)
                                              : const Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
