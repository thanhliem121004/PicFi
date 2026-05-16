import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/analytics/advanced_analytics_cubit.dart';
import '../../blocs/premium/premium_cubit.dart';

class AdvancedAnalyticsScreen extends StatefulWidget {
  const AdvancedAnalyticsScreen({super.key});

  @override
  State<AdvancedAnalyticsScreen> createState() => _AdvancedAnalyticsScreenState();
}

class _AdvancedAnalyticsScreenState extends State<AdvancedAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvancedAnalyticsCubit>().loadAnalytics();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumCubit>().state.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích nâng cao'),
        actions: [
          if (!isPremium)
            GestureDetector(
              onTap: () => context.push('/premium'),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Premium', style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: BlocBuilder<AdvancedAnalyticsCubit, AdvancedAnalyticsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (!isPremium) {
              return _buildPremiumLocked();
            }
            if (state.error != null) {
              return _buildError(state.error!);
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(state),
                  const SizedBox(height: 20),
                  _buildMonthlyTrendChart(state),
                  const SizedBox(height: 20),
                  _buildCategoryDonutChart(state),
                  const SizedBox(height: 20),
                  _buildIncomeExpenseChart(state),
                  const SizedBox(height: 20),
                  _buildPredictionCard(state),
                  const SizedBox(height: 20),
                  _buildCategoryBreakdownList(state),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPremiumLocked() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.lock_rounded, size: 48, color: Color(0xFFFFD700)),
            ),
            const SizedBox(height: 24),
            const Text('Phân tích nâng cao', style: TextStyle(
              fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800,
            )),
            const SizedBox(height: 8),
            Text(
              'Nâng cấp Premium để xem biểu đồ chi tiêu,\nphân tích danh mục và dự đoán tháng sau',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 15,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => context.push('/premium'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 16, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text('Nâng cấp ngay', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
                )),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFFF6B6B)),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 16,
            )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<AdvancedAnalyticsCubit>().loadAnalytics(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(AdvancedAnalyticsState state) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.trending_down_rounded,
            value: CurrencyFormatter.formatShort(state.totalExpense),
            label: 'Tổng chi',
            color: const Color(0xFFFF6B6B),
            bgColor: const Color(0xFFFFF5F5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.trending_up_rounded,
            value: CurrencyFormatter.formatShort(state.totalIncome),
            label: 'Tổng thu',
            color: const Color(0xFF2ECC71),
            bgColor: const Color(0xFFF0FFF5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.analytics_rounded,
            value: CurrencyFormatter.formatShort(state.predictedNextMonth),
            label: 'Dự đoán',
            color: const Color(0xFF4ECDC4),
            bgColor: const Color(0xFFF0FBF9),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrendChart(AdvancedAnalyticsState state) {
    if (state.monthlyTrends.isEmpty) return const SizedBox.shrink();

    final maxExpense = state.monthlyTrends.fold<double>(0, (max, t) => t.expense > max ? t.expense : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.show_chart_rounded, size: 20, color: Color(0xFF4ECDC4)),
              ),
              const SizedBox(width: 10),
              const Text('Xu hướng chi tiêu', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxExpense / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            CurrencyFormatter.formatCompact(value),
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 10,
                              color: AppColors.outline.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= state.monthlyTrends.length) {
                          return const SizedBox.shrink();
                        }
                        final month = state.monthlyTrends[index].month;
                        final parts = month.replaceAll('Thg ', '').split(',');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(parts[0], style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: AppColors.outline.withValues(alpha: 0.6),
                          )),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: state.monthlyTrends.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.expense);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4ECDC4),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF4ECDC4),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDonutChart(AdvancedAnalyticsState state) {
    if (state.categoryBreakdown.isEmpty) return const SizedBox.shrink();

    final colors = [
      const Color(0xFFFF6B6B), const Color(0xFF4ECDC4), const Color(0xFF45B7D1),
      const Color(0xFFF7DC6F), const Color(0xFFBB8FCE), const Color(0xFF82E0AA),
      const Color(0xFFF1948A), const Color(0xFFF0B27A), const Color(0xFF85C1E9),
      const Color(0xFF5DADE2), const Color(0xFFAEB6BF), const Color(0xFFA0522D),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFBB8FCE).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart_rounded, size: 20, color: Color(0xFFBB8FCE)),
              ),
              const SizedBox(width: 10),
              const Text('Phân bổ danh mục', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: state.categoryBreakdown.take(8).toList().asMap().entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value.percentage,
                          color: colors[entry.key % colors.length],
                          radius: 40,
                          title: '${entry.value.percentage.toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: state.categoryBreakdown.take(6).toList().asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: colors[entry.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('${entry.value.percentage.toStringAsFixed(0)}%', style: const TextStyle(
                            fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w700,
                          )),
                          const SizedBox(width: 4),
                          Text(entry.value.category, style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(AdvancedAnalyticsState state) {
    if (state.monthlyTrends.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded, size: 20, color: Color(0xFF2ECC71)),
              ),
              const SizedBox(width: 10),
              const Text('Thu nhập vs Chi tiêu', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
              )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${(value / 1000000).toStringAsFixed(0)}M',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 10,
                              color: AppColors.outline.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= state.monthlyTrends.length) {
                          return const SizedBox.shrink();
                        }
                        final month = state.monthlyTrends[index].month;
                        final parts = month.replaceAll('Thg ', '').split(',');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(parts[0], style: TextStyle(
                            fontFamily: 'Inter', fontSize: 11,
                            color: AppColors.outline.withValues(alpha: 0.6),
                          )),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: state.monthlyTrends.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.income,
                        color: const Color(0xFF2ECC71),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: entry.value.expense,
                        color: const Color(0xFFFF6B6B),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: const Color(0xFF2ECC71), label: 'Thu nhập'),
              const SizedBox(width: 24),
              _LegendItem(color: const Color(0xFFFF6B6B), label: 'Chi tiêu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(AdvancedAnalyticsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF003734), Color(0xFF006A65)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006A65).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tips_and_updates_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text('Dự đoán tháng sau', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              CurrencyFormatter.formatShort(state.predictedNextMonth),
              style: const TextStyle(
                fontFamily: 'Manrope', fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white,
              ),
            ),
          ),
          if (state.budgetRecommendation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 20, color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(state.budgetRecommendation!, style: TextStyle(
                      fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.3,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownList(AdvancedAnalyticsState state) {
    if (state.categoryBreakdown.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B27A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.list_alt_rounded, size: 20, color: Color(0xFFF0B27A)),
              ),
              const SizedBox(width: 10),
              const Text('Chi tiết danh mục', style: TextStyle(
                fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w800,
              )),
            ],
          ),
          const SizedBox(height: 16),
          ...state.categoryBreakdown.map((cat) {
            final maxAmount = state.categoryBreakdown.first.amount;
            final ratio = maxAmount > 0 ? cat.amount / maxAmount : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(cat.category, style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                        )),
                      ),
                      Text('${cat.count} giao dịch', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      )),
                      const SizedBox(width: 8),
                      Text(CurrencyFormatter.formatCompact(cat.amount), style: const TextStyle(
                        fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w800,
                      )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: AppColors.outlineVariant.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        cat.percentage > 30 ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color, bgColor;

  const _SummaryCard({
    required this.icon, required this.value,
    required this.label, required this.color, required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(
            fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w800, color: color,
          )),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(
            fontFamily: 'Inter', fontSize: 11,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          )),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
        )),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(
          fontFamily: 'Inter', fontSize: 12,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        )),
      ],
    );
  }
}
