import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/expense/expense_cubit.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _slideUp = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entryController.dispose();
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
              Color(0xFFF0FBF9),
              Color(0xFFFFF8F0),
              Color(0xFFF5F0FF),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final grouped = context.read<ExpenseCubit>().getGroupedByDate();

              return AnimatedBuilder(
                animation: _entryController,
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
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF4ECDC4), Color(0xFF006A65)],
                                ).createShader(bounds),
                                child: const Text('Lịch sử', style: TextStyle(
                                  fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '${state.expenses.length} giao dịch',
                                  style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                    color: Color(0xFF4ECDC4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // ═══ Search Bar ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 16, right: 8),
                                    child: Icon(Icons.search_rounded, color: const Color(0xFF4ECDC4), size: 22),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(minWidth: 46),
                                  hintText: AppStrings.searchExpense,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15,
                                    color: AppColors.outline.withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // ═══ Category Filter Chips ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                _ColorChip(
                                  label: AppStrings.all,
                                  isSelected: _selectedCategory == 'all',
                                  color: const Color(0xFF006A65),
                                  onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedCategory = 'all'); },
                                ),
                                ...ExpenseCategory.values.take(6).map((cat) =>
                                  _ColorChip(
                                    label: cat.label,
                                    isSelected: _selectedCategory == cat.name,
                                    color: cat.color,
                                    onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedCategory = cat.name); },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      // ═══ Empty state ═══
                      if (grouped.isEmpty)
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
                                    width: 64, height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [const Color(0xFF4ECDC4).withValues(alpha: 0.15), const Color(0xFFFF6B6B).withValues(alpha: 0.1)],
                                      ),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, size: 28, color: Color(0xFF4ECDC4)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text('Chưa có giao dịch nào', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                  )),
                                  const SizedBox(height: 6),
                                  Text('Thêm chi tiêu đầu tiên ngay!', style: TextStyle(
                                    fontFamily: 'Inter', fontSize: 14,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ═══ Grouped Expense List ═══
                      ...grouped.entries.map((entry) {
                        final dayTotal = entry.value.fold<double>(0, (sum, e) => sum + e.amount);
                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Opacity(
                                opacity: _fadeIn.value,
                                child: Transform.translate(
                                  offset: Offset(0, _slideUp.value),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(entry.key, style: const TextStyle(
                                            fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                            color: Color(0xFF006A65),
                                          )),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('-${CurrencyFormatter.format(dayTotal)}', style: const TextStyle(
                                            fontFamily: 'Manrope', fontSize: 13, fontWeight: FontWeight.w700,
                                            color: Color(0xFFFF6B6B),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final expense = entry.value[index];
                                    final category = ExpenseCategory.values.firstWhere(
                                      (c) => c.name == expense.category,
                                      orElse: () => ExpenseCategory.other,
                                    );
                                    return _VibrantExpenseCard(
                                      expense: expense,
                                      category: category,
                                      onTap: () => context.push('/expense-detail', extra: expense.id),
                                    );
                                  },
                                  childCount: entry.value.length,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ColorChip({
    required this.label, required this.isSelected,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)]) : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            border: isSelected ? null : Border.all(color: color.withValues(alpha: 0.15)),
            boxShadow: isSelected ? [
              BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

class _VibrantExpenseCard extends StatefulWidget {
  final dynamic expense;
  final ExpenseCategory category;
  final VoidCallback onTap;

  const _VibrantExpenseCard({
    required this.expense, required this.category, required this.onTap,
  });

  @override
  State<_VibrantExpenseCard> createState() => _VibrantExpenseCardState();
}

class _VibrantExpenseCardState extends State<_VibrantExpenseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cat.color.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: cat.color.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                      expense.note ?? cat.label,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '-${CurrencyFormatter.format(expense.amount)}',
                  style: const TextStyle(
                    fontFamily: 'Manrope', fontSize: 15,
                    fontWeight: FontWeight.w800, color: Color(0xFFFF6B6B),
                  ),
                ),
              ),
              if (expense.imageUrl != null) ...[
                const SizedBox(width: 10),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image_rounded, color: Color(0xFF4ECDC4), size: 20),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
