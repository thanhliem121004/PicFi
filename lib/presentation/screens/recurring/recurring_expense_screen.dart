import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/recurring_expense_entity.dart';
import '../../blocs/recurring/recurring_cubit.dart';

class RecurringExpenseScreen extends StatefulWidget {
  const RecurringExpenseScreen({super.key});

  @override
  State<RecurringExpenseScreen> createState() => _RecurringExpenseScreenState();
}

class _RecurringExpenseScreenState extends State<RecurringExpenseScreen>
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
    final amountCtrl = TextEditingController();
    // ignore: prefer_final_locals
    var selectedInterval = RecurringInterval.monthly;
    // ignore: prefer_final_locals
    var selectedCategory = ExpenseCategory.other;
    var note = '';

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
                const Text('Thêm chi tiêu định kỳ', style: TextStyle(
                  fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                )),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF006A65).withValues(alpha: 0.15)),
                    ),
                    child: TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        hintText: '1,000,000 ₫',
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                          color: AppColors.outline.withValues(alpha: 0.3),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: RecurringInterval.values.map((interval) {
                      final isSelected = interval == selectedInterval;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedInterval = interval),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF006A65).withValues(alpha: 0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? const Color(0xFF006A65) : Colors.transparent, width: 2),
                          ),
                          child: Text(_intervalLabel(interval), style: TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF006A65) : Colors.grey.shade600,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      onChanged: (v) => note = v,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Ghi chú (không bắt buộc)',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 10),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit_note_rounded, size: 20, color: Color(0xFF4ECDC4)),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 60),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
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
                        final amount = CurrencyFormatter.parse(amountCtrl.text);
                        if (amount == null || amount <= 0) {
                          unawaited(HapticFeedback.heavyImpact());
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Vui lòng nhập số tiền hợp lệ'),
                            backgroundColor: Color(0xFFFF6B6B),
                            behavior: SnackBarBehavior.floating,
                          ));
                          return;
                        }
                        unawaited(HapticFeedback.mediumImpact());
                        await context.read<RecurringCubit>().addRecurring(
                          RecurringExpenseEntity(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                            amount: amount,
                            category: selectedCategory.name,
                            note: note.isNotEmpty ? note : null,
                            interval: selectedInterval,
                            nextDueDate: DateTime.now(),
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
                        child: const Center(child: Text('Thêm định kỳ', style: TextStyle(
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

  String _intervalLabel(RecurringInterval interval) {
    switch (interval) {
      case RecurringInterval.daily: return 'Hằng ngày';
      case RecurringInterval.weekly: return 'Hằng tuần';
      case RecurringInterval.monthly: return 'Hằng tháng';
      case RecurringInterval.yearly: return 'Hằng năm';
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
                        const Text('Chi tiêu định kỳ', style: TextStyle(
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
                    child: BlocBuilder<RecurringCubit, RecurringState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006A65)));
                        }
                        if (state.recurringExpenses.isEmpty) {
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
                                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                      ),
                                      child: const Icon(Icons.repeat_rounded, size: 36, color: Color(0xFF4ECDC4)),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text('Chưa có chi tiêu định kỳ', style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                      color: AppColors.onSurfaceVariant,
                                    )),
                                    const SizedBox(height: 8),
                                    Text('Nhấn nút + để thêm khoản chi định kỳ', style: TextStyle(
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
                              itemCount: state.recurringExpenses.length,
                              itemBuilder: (context, index) {
                                final item = state.recurringExpenses[index];
                                final category = ExpenseCategory.values.firstWhere(
                                  (c) => c.name == item.category, orElse: () => ExpenseCategory.other,
                                );
                                return Dismissible(
                                  key: Key(item.id),
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
                                    HapticFeedback.mediumImpact();
                                    unawaited(context.read<RecurringCubit>().deleteRecurring(item.id));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
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
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48, height: 48,
                                          decoration: BoxDecoration(
                                            color: category.color.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(category.icon, size: 24, color: category.color),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(category.label, style: const TextStyle(
                                                fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w700,
                                              )),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(item.intervalLabel, style: TextStyle(
                                                    fontFamily: 'Inter', fontSize: 12,
                                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                  )),
                                                  if (item.note != null) ...[
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Text('• ${item.note}', style: TextStyle(
                                                        fontFamily: 'Inter', fontSize: 12,
                                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                                                      ), overflow: TextOverflow.ellipsis),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(CurrencyFormatter.formatShort(item.amount), style: const TextStyle(
                                          fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
                                          color: Color(0xFFFF6B6B),
                                        )),
                                        const SizedBox(width: 8),
                                        Switch(
                                          value: item.isActive,
                                          activeTrackColor: const Color(0xFF4ECDC4),
                                          onChanged: (v) {
                                            HapticFeedback.selectionClick();
                                            unawaited(context.read<RecurringCubit>().toggleActive(item.id, v));
                                          },
                                        ),
                                      ],
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
        backgroundColor: const Color(0xFF006A65),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
