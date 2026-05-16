import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/savings_goal_entity.dart';
import '../../blocs/savings/savings_goal_cubit.dart';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

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

  void _showAddSheet() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final selectedIcon = ValueNotifier<String>('🎯');

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
                  margin: const EdgeInsets.only(top: 12),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Mục tiêu tiết kiệm mới', style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 16),
                ValueListenableBuilder<String>(
                  valueListenable: selectedIcon,
                  builder: (_, icon, __) => Text(icon, style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: ['🎯', '🏠', '✈️', '🚗', '🎓', '💍', '📱', '💻', '🏥', '🎁'].map((emoji) {
                      return GestureDetector(
                        onTap: () { selectedIcon.value = emoji; setSheetState(() {}); },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: selectedIcon.value == emoji
                                ? const Color(0xFF006A65).withValues(alpha: 0.12) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedIcon.value == emoji ? const Color(0xFF006A65) : Colors.transparent, width: 2),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF006A65).withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Tên mục tiêu',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF006A65).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.flag_rounded, size: 20, color: Color(0xFF006A65)),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 60),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF006A65).withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        hintText: '10,000,000 ₫',
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800,
                          color: AppColors.outline.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () async {
                        if (nameCtrl.text.trim().isEmpty) {
                          unawaited(HapticFeedback.heavyImpact());
                          return;
                        }
                        final target = CurrencyFormatter.parse(targetCtrl.text);
                        if (target == null || target <= 0) {
                          unawaited(HapticFeedback.heavyImpact());
                          return;
                        }
                        unawaited(HapticFeedback.mediumImpact());
                        await context.read<SavingsGoalCubit>().addGoal(
                          SavingsGoalEntity(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                            name: nameCtrl.text.trim(),
                            targetAmount: target,
                            icon: selectedIcon.value,
                            createdAt: DateTime.now(),
                          ),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF006A65), Color(0xFF4ECDC4)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006A65).withValues(alpha: 0.25),
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(child: Text('Tạo mục tiêu', style: TextStyle(
                          fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
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

  void _showContributeSheet(SavingsGoalEntity goal) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              )),
              const SizedBox(height: 20),
              Text('Nạp tiền vào "${goal.name}"', style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                ),
                child: TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    hintText: 'Số tiền nạp',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final amount = CurrencyFormatter.parse(amountCtrl.text);
                    if (amount == null || amount <= 0) {
                      unawaited(HapticFeedback.heavyImpact());
                      return;
                    }
                    unawaited(HapticFeedback.mediumImpact());
                    await context.read<SavingsGoalCubit>().contribute(goal.id, amount);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF006A65)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(child: Text('Nạp tiền', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                    ))),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF006A65).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, size: 22, color: Color(0xFF006A65)),
                          ),
                        ),
                        const Spacer(),
                        const Text('Mục tiêu tiết kiệm', style: TextStyle(
                          fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        )),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<SavingsGoalCubit, SavingsGoalState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006A65)));
                        }
                        if (state.goals.isEmpty) {
                          return Opacity(
                            opacity: _fadeIn.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideUp.value),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF0B27A).withValues(alpha: 0.1),
                                      ),
                                      child: const Icon(Icons.track_changes_rounded, size: 36, color: Color(0xFFF0B27A)),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Chưa có mục tiêu nào', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                    )),
                                    const SizedBox(height: 8),
                                    Text('Tạo mục tiêu tiết kiệm để bắt đầu', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14,
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: state.goals.length,
                              itemBuilder: (context, index) {
                                final goal = state.goals[index];
                                final pct = (goal.progress * 100).toStringAsFixed(0);
                                return Dismissible(
                                  key: Key(goal.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6B6B),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                                  ),
                                  onDismissed: (_) {
                                    unawaited(HapticFeedback.mediumImpact());
                                    unawaited(context.read<SavingsGoalCubit>().deleteGoal(goal.id));
                                  },
                                  child: GestureDetector(
                                    onTap: () => _showContributeSheet(goal),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 10, offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 48, height: 48,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF0B27A).withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Center(child: Text(goal.icon ?? '🎯', style: const TextStyle(fontSize: 22))),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(goal.name, style: const TextStyle(
                                                      fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                                                    )),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${CurrencyFormatter.formatShort(goal.currentAmount)} / ${CurrencyFormatter.formatShort(goal.targetAmount)}',
                                                      style: TextStyle(
                                                        fontFamily: 'Inter', fontSize: 13,
                                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text('$pct%', style: const TextStyle(
                                                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                                                color: Color(0xFF006A65),
                                              )),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: LinearProgressIndicator(
                                              value: goal.progress,
                                              backgroundColor: const Color(0xFFF0B27A).withValues(alpha: 0.12),
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF0B27A)),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: const Color(0xFFF0B27A),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
