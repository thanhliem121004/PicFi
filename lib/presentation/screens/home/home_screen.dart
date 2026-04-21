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
import '../../blocs/auth/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardOpacity;
  late Animation<double> _listSlide;
  late Animation<double> _listOpacity;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _cardSlide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.5, curve: Curves.easeOutCubic)),
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    _listSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)),
    );
    _listOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
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
              return AnimatedBuilder(
                animation: Listenable.merge([_entryController, _pulseController]),
                builder: (context, _) {
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // ═══ App Bar ═══
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Row(
                            children: [
                              // Animated avatar with gradient ring
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF006A65), Color(0xFF4ECDC4), Color(0xFFFF6B6B)],
                                    ),
                                  ),
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.asset(
                                        'assets/images/auth_illustration.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<AuthCubit, AuthState>(
                                    builder: (context, authState) {
                                      return Text(
                                        'Xin chào, ${authState.displayName?.split(' ').last ?? 'bạn'} 👋',
                                        style: const TextStyle(
                                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      );
                                    },
                                  ),
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF006A65), Color(0xFF4ECDC4)],
                                    ).createShader(bounds),
                                    child: const Text(AppStrings.appName, style: TextStyle(
                                      fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
                                      color: Colors.white, letterSpacing: -0.5,
                                    )),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Friends button with badge
                              GestureDetector(
                                onTap: () => context.push('/friends'),
                                child: Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    border: Border.all(color: const Color(0xFF4ECDC4).withValues(alpha: 0.3)),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                  ),
                                  child: const Icon(Icons.people_alt_rounded, color: Color(0xFF4ECDC4), size: 22),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Notification
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.2)),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                                ),
                                child: Stack(
                                  children: [
                                    const Center(child: Icon(Icons.notifications_rounded, color: Color(0xFFFF6B6B), size: 22)),
                                    Positioned(
                                      right: 10, top: 10,
                                      child: Container(
                                        width: 9, height: 9,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B6B),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      // ═══ Balance Card with Gradient ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _cardOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _cardSlide.value),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006A65).withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Stack(
                                  children: [
                                    // Multi-layer gradient
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF006A65),
                                            Color(0xFF008B85),
                                            Color(0xFF4ECDC4),
                                            Color(0xFF6EDDD6),
                                          ],
                                          stops: [0.0, 0.35, 0.7, 1.0],
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.account_balance_wallet_rounded,
                                                        size: 14, color: Colors.white.withValues(alpha: 0.9)),
                                                    const SizedBox(width: 6),
                                                    Text(AppStrings.totalBalance, style: TextStyle(
                                                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                                      color: Colors.white.withValues(alpha: 0.9),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(Icons.more_horiz_rounded, size: 18, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            CurrencyFormatter.format(state.balance),
                                            style: const TextStyle(
                                              fontFamily: 'Manrope', fontSize: 36,
                                              fontWeight: FontWeight.w800, color: Colors.white,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          // Income / Expense row
                                          Container(
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(18),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(child: _BalanceStat(
                                                  label: AppStrings.income,
                                                  value: '+${CurrencyFormatter.format(state.totalIncome)}',
                                                  icon: Icons.trending_up_rounded,
                                                  color: const Color(0xFF7CF6EC),
                                                )),
                                                Container(width: 1, height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.white.withValues(alpha: 0),
                                                        Colors.white.withValues(alpha: 0.2),
                                                        Colors.white.withValues(alpha: 0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(child: _BalanceStat(
                                                  label: AppStrings.expense,
                                                  value: '-${CurrencyFormatter.format(state.totalExpense)}',
                                                  icon: Icons.trending_down_rounded,
                                                  color: const Color(0xFFFFB3B0),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Decorative elements
                                    Positioned(
                                      top: -25, right: -25,
                                      child: AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, _) => Transform.scale(
                                          scale: _pulse.value,
                                          child: Container(
                                            width: 100, height: 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(alpha: 0.06),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -20, left: 40,
                                      child: Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.04),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 20, right: 50,
                                      child: Container(
                                        width: 6, height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      // ═══ Quick Actions Row ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _cardOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _cardSlide.value * 0.6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(child: _QuickActionCard(
                                    title: AppStrings.thisMonth,
                                    subtitle: AppStrings.prettyGood,
                                    trailing: '45% ${AppStrings.budgetPercent}',
                                    progressValue: 0.45,
                                    progressColors: const [Color(0xFF4ECDC4), Color(0xFF006A65)],
                                    bgColor: const Color(0xFFF0FBF9),
                                    iconColor: const Color(0xFF4ECDC4),
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(child: _QuickActionCard(
                                    title: 'Streak 🔥',
                                    subtitle: '7 ngày',
                                    trailing: 'Tiếp tục nào!',
                                    progressValue: 0.7,
                                    progressColors: const [Color(0xFFFF6B6B), Color(0xFFF0B27A)],
                                    bgColor: const Color(0xFFFFF5F5),
                                    iconColor: const Color(0xFFFF6B6B),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // ═══ Category Quick Scroll ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _listOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _listSlide.value),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text('Danh mục', style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  )),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: ExpenseCategory.values.length,
                                    itemBuilder: (context, index) {
                                      final cat = ExpenseCategory.values[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 56, height: 56,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [cat.color.withValues(alpha: 0.15), cat.color.withValues(alpha: 0.05)],
                                                ),
                                                border: Border.all(color: cat.color.withValues(alpha: 0.2)),
                                              ),
                                              child: Icon(cat.icon, size: 24, color: cat.color),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(cat.label, style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 11,
                                              fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant,
                                            )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ═══ Recent Expenses Header ═══
                      SliverToBoxAdapter(
                        child: Opacity(
                          opacity: _listOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _listSlide.value),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(AppStrings.recentExpenses, style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface, letterSpacing: -0.3,
                                  )),
                                  GestureDetector(
                                    onTap: () => context.push('/expenses'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.08),
                                            const Color(0xFF4ECDC4).withValues(alpha: 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(AppStrings.viewAll, style: TextStyle(
                                        fontFamily: 'Inter', fontSize: 13,
                                        fontWeight: FontWeight.w600, color: AppColors.primary,
                                      )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ═══ Expense Cards ═══
                      state.expenses.isEmpty
                          ? SliverToBoxAdapter(
                              child: Opacity(
                                opacity: _listOpacity.value,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
                                      const Text('Chưa có chi tiêu nào', style: TextStyle(
                                        fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                      )),
                                      const SizedBox(height: 6),
                                      Text('Bấm nút + để thêm chi tiêu đầu tiên!', style: TextStyle(
                                        fontFamily: 'Inter', fontSize: 14,
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index >= state.expenses.length || index >= 5) return null;
                                    final expense = state.expenses[index];
                                    final category = ExpenseCategory.values.firstWhere(
                                      (c) => c.name == expense.category,
                                      orElse: () => ExpenseCategory.other,
                                    );

                                    return Opacity(
                                      opacity: _listOpacity.value,
                                      child: Transform.translate(
                                        offset: Offset(0, _listSlide.value * (1 + index * 0.15)),
                                        child: _VibrantExpenseCard(
                                          expense: expense,
                                          category: category,
                                          onTap: () => context.push('/expense-detail', extra: expense.id),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: state.expenses.length.clamp(0, 5),
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
    );
  }
}

// ═══════════════════════════════════════════════════════
// VIBRANT HOME WIDGETS
// ═══════════════════════════════════════════════════════
class _BalanceStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _BalanceStat({
    required this.label, required this.value,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 0.3, color: Colors.white.withValues(alpha: 0.6),
              )),
              Text(value, style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700,
                color: Colors.white,
              ), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title, subtitle, trailing;
  final double progressValue;
  final List<Color> progressColors;
  final Color bgColor;
  final Color iconColor;

  const _QuickActionCard({
    required this.title, required this.subtitle,
    required this.trailing, required this.progressValue,
    required this.progressColors, required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: iconColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontFamily: 'Inter', fontSize: 14,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
          )),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(
            fontFamily: 'Manrope', fontSize: 22, fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          )),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(iconColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(trailing, style: TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          )),
        ],
      ),
    );
  }
}

class _VibrantExpenseCard extends StatefulWidget {
  final dynamic expense;
  final ExpenseCategory category;
  final VoidCallback onTap;

  const _VibrantExpenseCard({
    required this.expense,
    required this.category,
    required this.onTap,
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cat.color.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: cat.color.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Category icon with gradient bg
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cat.color.withValues(alpha: 0.15), cat.color.withValues(alpha: 0.05)],
                  ),
                ),
                child: Center(child: Icon(cat.icon, color: cat.color, size: 26)),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note ?? cat.label,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w600, color: AppColors.onSurface,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
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
                        const SizedBox(width: 8),
                        Text(DateFormatter.formatRelative(expense.date), style: TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              // Amount
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
            ],
          ),
        ),
      ),
    );
  }
}
