import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/expense_categories.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/expense/expense_cubit.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F0FF),
              Color(0xFFF0FBF9),
              Color(0xFFFFF8F0),
              Color(0xFFEFF5F3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<ExpenseCubit, ExpenseState>(
            builder: (context, state) {
              final categoryStats = context.read<ExpenseCubit>().getCategoryStats();
              final totalExpense = categoryStats.values.fold<double>(0, (s, v) => s + v);

              return AnimatedBuilder(
                animation: _entryController,
                builder: (context, _) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // ═══ Header ═══
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                          child: Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF9B59B6), Color(0xFF4ECDC4)],
                                ).createShader(bounds),
                                child: const Text('Thống kê', style: TextStyle(
                                  fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha: 0.15)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF9B59B6)),
                                    SizedBox(width: 6),
                                    Text('Tháng này', style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                      color: Color(0xFF9B59B6),
                                    )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ═══ Total Expense Card ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF9B59B6), Color(0xFF6C5CE7), Color(0xFF4ECDC4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9B59B6).withValues(alpha: 0.3),
                                  blurRadius: 25,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: -20, right: -20,
                                  child: Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(AppStrings.totalExpense, style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        )),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text('📊', style: TextStyle(fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        CurrencyFormatter.format(totalExpense),
                                        style: const TextStyle(
                                          fontFamily: 'Manrope', fontSize: 34, fontWeight: FontWeight.w800,
                                          color: Colors.white, letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF7CF6EC)),
                                              const SizedBox(width: 4),
                                              Text('+12% so với tháng trước', style: TextStyle(
                                                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                                                color: Colors.white.withValues(alpha: 0.9),
                                              )),
                                            ],
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
                        const SizedBox(height: 20),

                        // ═══ Pie Chart Card ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF9B59B6).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(AppStrings.expenseStructure, style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                  )),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 50,
                                        sections: categoryStats.entries.map((entry) {
                                          final cat = ExpenseCategory.values.firstWhere(
                                            (c) => c.name == entry.key, orElse: () => ExpenseCategory.other,
                                          );
                                          final pct = totalExpense > 0 ? (entry.value / totalExpense * 100) : 0.0;
                                          return PieChartSectionData(
                                            value: entry.value,
                                            color: cat.color,
                                            title: '${pct.round()}%',
                                            titleStyle: const TextStyle(
                                              fontFamily: 'Inter', fontSize: 12,
                                              fontWeight: FontWeight.w700, color: Colors.white,
                                            ),
                                            radius: 44,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Legend
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: categoryStats.entries.map((entry) {
                                      final cat = ExpenseCategory.values.firstWhere(
                                        (c) => c.name == entry.key, orElse: () => ExpenseCategory.other,
                                      );
                                      final pct = totalExpense > 0 ? (entry.value / totalExpense * 100).round() : 0;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: cat.color.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(width: 8, height: 8,
                                              decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle)),
                                            const SizedBox(width: 6),
                                            Text('${cat.label} $pct%', style: TextStyle(
                                              fontFamily: 'Inter', fontSize: 12,
                                              fontWeight: FontWeight.w600, color: cat.color,
                                            )),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Weekly Bar Chart ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 1.3),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF4ECDC4).withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(AppStrings.weeklyExpense, style: TextStyle(
                                    fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w700,
                                  )),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 160,
                                    child: BarChart(
                                      BarChartData(
                                        barGroups: _computeWeeklyBars(state.expenses),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final labels = _barLabels;
                                                final colors = _barColors;
                                                return SideTitleWidget(
                                                  meta: meta,
                                                  child: Text(labels[value.toInt() % labels.length], style: TextStyle(
                                                    fontFamily: 'Inter', fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: colors[value.toInt() % colors.length],
                                                  )),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        gridData: const FlGridData(show: false),
                                        barTouchData: BarTouchData(enabled: false),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ Top Categories ═══
                        Opacity(
                          opacity: _fadeIn.value,
                          child: Transform.translate(
                            offset: Offset(0, _slideUp.value * 1.5),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(AppStrings.topCategories, style: TextStyle(
                                        fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w700,
                                      )),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFF9B59B6).withValues(alpha: 0.08), const Color(0xFF4ECDC4).withValues(alpha: 0.08)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(AppStrings.viewAll, style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                                          color: Color(0xFF9B59B6),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...categoryStats.entries.take(3).map((entry) {
                                  final cat = ExpenseCategory.values.firstWhere(
                                    (c) => c.name == entry.key, orElse: () => ExpenseCategory.other,
                                  );
                                  final pct = totalExpense > 0 ? (entry.value / totalExpense * 100).round() : 0;
                                  final count = state.expenses.where((e) => e.category == entry.key).length;

                                  return Container(
                                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: cat.color.withValues(alpha: 0.1)),
                                      boxShadow: [
                                        BoxShadow(color: cat.color.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48, height: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
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
                                                  Text(cat.label, style: const TextStyle(
                                                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
                                                  )),
                                                  Text('$count ${AppStrings.transactions} · $pct%', style: TextStyle(
                                                    fontFamily: 'Inter', fontSize: 13,
                                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                                  )),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: cat.color.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                CurrencyFormatter.format(entry.value),
                                                style: TextStyle(
                                                  fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w700,
                                                  color: cat.color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: pct / 100,
                                            backgroundColor: cat.color.withValues(alpha: 0.08),
                                            valueColor: AlwaysStoppedAnimation(cat.color),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static const _barLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _barColors = [
    Color(0xFF4ECDC4), Color(0xFF9B59B6), Color(0xFFFF6B6B), Color(0xFFF0B27A),
    Color(0xFF45B7D1), Color(0xFF006A65), Color(0xFF6C5CE7),
  ];

  List<BarChartGroupData> _computeWeeklyBars(List<dynamic> expenses) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon ... 7=Sun
    final monday = now.subtract(Duration(days: weekday - 1));
    final mondayStart = DateTime(monday.year, monday.month, monday.day);
    final sundayEnd = mondayStart.add(const Duration(days: 7));

    final dayTotals = List.filled(7, 0.0);
    int maxVal = 0;

    for (final expense in expenses) {
      final d = expense.date;
      if (d.isBefore(mondayStart) || d.isAfter(sundayEnd)) continue;
      final dayIndex = d.weekday - 1; // Mon=0 ... Sun=6
      dayTotals[dayIndex] += (expense.amount as num).toDouble();
    }

    for (final v in dayTotals) {
      if (v > maxVal) maxVal = v.toInt();
    }

    final scale = maxVal > 0 ? maxVal / 8.0 : 1.0;

    return List.generate(7, (i) {
      final val = dayTotals[i] / scale;
      final isMax = dayTotals[i] >= maxVal && maxVal > 0;
      return _makeBar(i, val > 0 ? val : 0.5, _barColors[i], highlighted: isMax);
    });
  }

  BarChartGroupData _makeBar(int x, double y, Color color, {bool highlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [color.withValues(alpha: highlighted ? 1 : 0.4), color],
          ),
          width: 32,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }
}
