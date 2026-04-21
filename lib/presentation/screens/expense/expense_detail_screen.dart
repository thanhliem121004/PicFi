import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../blocs/expense/expense_cubit.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final expense = state.expenses.firstWhere(
          (e) => e.id == expenseId,
          orElse: () => state.expenses.first,
        );
        final category = ExpenseCategory.values.firstWhere(
          (c) => c.name == expense.category,
          orElse: () => ExpenseCategory.other,
        );

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Center(
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 22),
                ),
              ),
            ),
            title: const Text(AppStrings.detail, style: TextStyle(
              fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w700,
            )),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                ),
                child: const Icon(Icons.more_vert_rounded, color: AppColors.onSurface, size: 22),
              ),
            ],
          ),
          body: Column(
            children: [
              // ═══ Image Area ═══
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        category.color.withValues(alpha: 0.08),
                        category.color.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    category.color.withValues(alpha: 0.2),
                                    category.color.withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                              child: Icon(category.icon, size: 42, color: category.color),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              expense.note ?? category.label,
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 16,
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category badge
                      Positioned(
                        left: 16, bottom: 16,
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: category.color, shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: category.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: Icon(category.icon, size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.onSurface.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category.label.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5, color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16, bottom: 16,
                        child: Text(
                          CurrencyFormatter.formatCompact(expense.amount),
                          style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 28,
                            fontWeight: FontWeight.w800, color: AppColors.expense,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ═══ Details Card ═══
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: AppStrings.date,
                        value: DateFormatter.formatFull(expense.date),
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryContainer.withValues(alpha: 0.2),
                      ),
                      Divider(height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      _DetailRow(
                        icon: Icons.location_on_rounded,
                        label: AppStrings.location,
                        value: expense.location ?? 'Chưa cập nhật',
                        iconColor: AppColors.secondary,
                        iconBg: AppColors.secondaryContainer.withValues(alpha: 0.2),
                      ),
                      Divider(height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      // Note
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                            ),
                            child: Icon(Icons.notes_rounded, size: 20, color: AppColors.tertiary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppStrings.note, style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 13,
                                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                )),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F9F8),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    expense.note ?? 'Không có ghi chú',
                                    style: const TextStyle(
                                      fontFamily: 'Inter', fontSize: 15,
                                      color: AppColors.onSurface, height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.delete_rounded,
                              label: AppStrings.delete,
                              color: AppColors.error,
                              bgColor: AppColors.errorContainer.withValues(alpha: 0.2),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                context.read<ExpenseCubit>().deleteExpense(expense.id);
                                context.pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GradientActionButton(
                              icon: Icons.edit_rounded,
                              label: AppStrings.edit,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              fontFamily: 'Inter', fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            )),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            )),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon, required this.label,
    required this.color, required this.bgColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: widget.color),
              const SizedBox(width: 8),
              Text(widget.label, style: TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                color: widget.color,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GradientActionButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  State<_GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<_GradientActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.label, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
